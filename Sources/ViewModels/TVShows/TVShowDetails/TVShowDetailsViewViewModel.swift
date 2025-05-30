import Combine
import UIKit

/// View model class for `TVShowDetailsView`
final class TVShowDetailsViewViewModel {
	var title: String { return tvShow.name }

	private var genreCellViewModel = TVShowDetailsGenreCellViewModel()
	private var overviewCellViewModel: TVShowDetailsOverviewCellViewModel!
	private var castCellViewModel = TVShowDetailsCastCellViewModel()

	enum WatchProvidersState {
		case empty
		case available([TVShowDetailsProvidersCellViewModel])
	}

	private var watchProvidersState: WatchProvidersState = .available([])

	private var watchProvider: WatchProvider? {
		didSet {
			guard let arRegion = watchProvider?.results["AR"] else {
				watchProvidersState = .empty
				return
			}

			let providers = Set((arRegion.additionals ?? []) + (arRegion.flatrate ?? []))

			let viewModels: [TVShowDetailsProvidersCellViewModel] = providers.compactMap { watchOption in
				guard let url = Service.imageURL(.watchProviderLogo(watchOption), size: "w200") else { return nil }
				return TVShowDetailsProvidersCellViewModel(imageURL: url)
			}
			watchProvidersState = .available(viewModels)
		}
	}

	private var subscriptions = Set<AnyCancellable>()

	// ! UITableViewDiffableDataSource

	private enum CellType {
		case genre, description, cast, providers
	}

	private enum Section {
		case main
	}

	private let cells: [CellType] = [.genre, .description, .cast, .providers]

	private typealias DataSource = UITableViewDiffableDataSource<Section, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellType>

	private var dataSource: DataSource!

	let tvShow: TVShow

	/// Designated initializer
	/// - Parameters:
	///		- tvShow: The tv show model object
	init(tvShow: TVShow) {
		self.tvShow = tvShow
		fetchTVShowCast()
		fetchTVShowDetails()
		fetchTVShowWatchProviders()

		overviewCellViewModel = .init(description: tvShow.description)
	}

	// ! Private

	private func setupHeaderViewModel() -> TVShowDetailsHeaderViewViewModel {
		let rating = String(describing: tvShow.voteAverage?.round(to: 1) ?? 0) + "/10"

		guard let url = Service.imageURL(.showBackdrop(tvShow), size: "w1280") else {
			return .init(
				imageURL: Bundle.main.url(forResource: "Placeholder", withExtension: "jpg"),
				tvShowName: tvShow.name,
				rating: rating
			)
		}

		return .init(imageURL: url, tvShowName: tvShow.name, rating: rating)
	}

	private func fetchTVShowCast() {
		let urlString = "\(Service.Constants.baseURL)tv/\(tvShow.id)/credits?\(Service.Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: Credits.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] credits, isFromCache in
				self?.updateCastCrewNames(with: credits.cast)
				self?.reloadSnapshot(animatingDifferences: !isFromCache)
			}
			.store(in: &subscriptions)
	}

	private func fetchTVShowDetails() {
		Service.sharedInstance.fetchTVShowDetails(
			for: tvShow,
			storeIn: &subscriptions
		) { [weak self] tvShow, isFromCache in
			guard let self else { return }	

			updateGenresNames(with: tvShow.genres ?? [], for: tvShow)
			reloadSnapshot(animatingDifferences: !isFromCache)
		}
	}

	private func fetchTVShowWatchProviders() {
		let urlString = "\(Service.Constants.baseURL)tv/\(tvShow.id)/watch/providers?\(Service.Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: WatchProvider.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] watchProvider, isFromCache in
				guard let self else { return }

				self.watchProvider = watchProvider
				reloadSnapshot(animatingDifferences: !isFromCache)
			}
			.store(in: &subscriptions)
	}

	private func updateGenresNames(with genres: [Genre], for tvShow: TVShow) {
		let episodeAverageDurations = tvShow.episodeAverageDurations ?? []
		let episodeAverageDurationsValues = episodeAverageDurations.map { String($0) }

		let episodeAverageDuration = episodeAverageDurations.isEmpty ? "" : String(describing: episodeAverageDurationsValues.joined(separator: ", ")) + " min"

		let genresNames = genres.map(\.name)

		genreCellViewModel = .init(
			genre: genresNames.joined(separator: ", "),
			episodeAverageDuration: episodeAverageDuration,
			lastAirDate: tvShow.lastAirDate,
			status: tvShow.status
		)
	}

	private func updateCastCrewNames(with castCrew: [Cast]) {
		let castCrewNames = OrderedSet(castCrew.map(\.name))
		let castCrewText = castCrewNames.isEmpty ? "Unknown" : castCrewNames.joined(separator: ", ")

		castCellViewModel = .init(cast: "Cast", castCrew: castCrewText)
	}
}

// ! TableView

extension TVShowDetailsViewViewModel {
	/// Function to setup the table view's header
	/// - Parameters:
	///		- view: The view that owns the table view, therefore the header
	func setupHeaderView(forView view: UIView) -> TVShowDetailsHeaderView {
		let headerView = TVShowDetailsHeaderView()
		headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160)
		headerView.configure(with: setupHeaderViewModel())
		return headerView
	}

	/// Function to setup the table view's diffable data source
	/// - Parameters:
	///		- tableView: The table view
	func setupTableView(_ tableView: UITableView) {
		dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, _ in
			guard let self else { return nil }

			switch cells[indexPath.row] {
				case .genre:
					let cell: TVShowDetailsGenreCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: genreCellViewModel)
					return cell

				case .description:
					let cell: TVShowDetailsOverviewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: overviewCellViewModel)
					return cell

				case .cast:
					let cell: TVShowDetailsCastCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: castCellViewModel)
					return cell

				case .providers:
					let cell: TVShowDetailsProvidersCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: watchProvidersState)
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
