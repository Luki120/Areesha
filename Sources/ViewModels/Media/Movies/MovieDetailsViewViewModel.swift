import Combine
import UIKit

/// View model class for `MovieDetailsView`
final class MovieDetailsViewViewModel: WatchProviderPresentable {
	var title: String { movie.title }

	private var keyInfoCellViewModel: MovieDetailsKeyInfoCellViewModel {
		return .init(
			airDate: movie.releaseDate ?? "",
			director: movie.credits?.crew.first { $0.job == "Director" }?.name ?? "",
			duration: movie.runtime ?? 0
		)
	}

	private var genreCellViewModel: MovieDetailsGenreCellViewModel {
		let genres = movie.genres?.map(\.name) ?? []
		return .init(genre: genres.joined(separator: ", "), revenue: movie.revenue ?? 0)
	}

	private var descriptionCellViewModel: MovieDetailsDescriptionCellViewModel {
		.init(description: movie.description)
	}

	private var castCellViewModel: MovieDetailsCastCellViewModel {
		let cast = movie.credits?.cast.map(\.name) ?? []
		return .init(cast: cast.joined(separator: ", "))
	}

	private var providersState: WatchProvidersState = .available([])

	private var watchProvider: WatchProvider? {
		didSet {
			providersState = makeState(from: watchProvider)
		}
	}

	private var subscriptions = Set<AnyCancellable>()

	// ! UITableViewDiffableDataSource

	private enum CellType {
		case keyInfo, genre, description, cast, providers
	}

	private enum Section {
		case main
	}

	private let cells: [CellType] = [.keyInfo, .genre, .description, .cast, .providers]

	private typealias DataSource = UITableViewDiffableDataSource<Section, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellType>

	private var dataSource: DataSource!

	let movie: Movie

	/// Designated initializer
	/// - Parameter movie: The `Movie` model object
	init(movie: Movie) {
		self.movie = movie

		Task {
			await fetchMovieWatchProviders()
		}
	}

	private func fetchMovieWatchProviders() async {
		let urlString = "\(Service.Constants.baseURL)movie/\(movie.id)/watch/providers?\(Service.Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }

		await Service.sharedInstance.fetchTVShows(withURL: url, expecting: WatchProvider.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] watchProvider, isFromCache in
				guard let self else { return }

				self.watchProvider = watchProvider
				reloadSnapshot(animatingDifferences: !isFromCache)
			}
			.store(in: &subscriptions)
	}

	// ! Private

	private func setupHeaderViewModel() -> TVShowDetailsHeaderViewViewModel {
		let average = movie.voteAverage?.round(to: 1) ?? 0
		let isWholeNumber = average.truncatingRemainder(dividingBy: 1) == 0

		let rating =
			isWholeNumber
			? String(format: "%.0f/10", average)
			: String(describing: average) + "/10"

		guard let url = Service.imageURL(.movieBackdrop(movie), size: "w1280") else {
			return .init(
				imageURL: Bundle.main.url(forResource: "Placeholder", withExtension: "jpg"),
				tvShowName: movie.title,
				rating: rating
			)
		}

		return .init(imageURL: url, tvShowName: movie.title, rating: rating)
	}
}

// ! TableView

extension MovieDetailsViewViewModel {
	/// Function to setup the table view's header
	/// - Parameter view: The view that owns the table view, therefore the header
	func setupHeaderView(forView view: UIView) -> TVShowDetailsHeaderView {
		let headerView = TVShowDetailsHeaderView()
		headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160)
		headerView.configure(with: setupHeaderViewModel())
		return headerView
	}

	/// Function to setup the table view's diffable data source
	/// - Parameter tableView: The `UITableView`
	func setupTableView(_ tableView: UITableView) {
		dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, _ in
			guard let self else { return nil }

			switch cells[indexPath.row] {
				case .keyInfo:
					let cell: MovieDetailsKeyInfoCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: keyInfoCellViewModel)
					return cell

				case .genre:
					let cell: MovieDetailsGenreCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: genreCellViewModel)
					return cell

				case .description:
					let cell: MovieDetailsDescriptionCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: descriptionCellViewModel)
					return cell

				case .cast:
					let cell: MovieDetailsCastCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: castCellViewModel)
					return cell

				case .providers:
					let cell: MovieDetailsProvidersCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: providersState)
					return cell
			}
		}
		applySnapshot()
	}

	private func applySnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(cells)
		dataSource.apply(snapshot)
	}

	private func reloadSnapshot(animatingDifferences: Bool) {
		var snapshot = dataSource.snapshot()
		if #available(iOS 15.0, *) { snapshot.reconfigureItems(cells) }
		else { snapshot.reloadItems(cells) }

		dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
	}
}
