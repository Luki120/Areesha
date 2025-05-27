import Combine
import UIKit

/// View model class for `TVShowDetailsView`
final class TVShowDetailsViewViewModel {
	var title: String { return tvShow.name }

	private var genreCellViewModel = TVShowDetailsGenreCellViewModel()
	private var overviewCellViewModel: TVShowDetailsOverviewCellViewModel!
	private var castCellViewModel = TVShowDetailsCastCellViewModel()
	private var networksCellViewModel = TVShowDetailsNetworksCellViewModel()

	private var subscriptions = Set<AnyCancellable>()

	// ! UITableViewDiffableDataSource

	private enum CellType: Hashable {
		case genre(viewModel: TVShowDetailsGenreCellViewModel)
		case overview(viewModel: TVShowDetailsOverviewCellViewModel)
		case cast(viewModel: TVShowDetailsCastCellViewModel)
		case networks(viewModel: TVShowDetailsNetworksCellViewModel)
	}

	private var cells = [CellType]()

	private enum Section {
		case main
	}

	private typealias DataSource = UITableViewDiffableDataSource<Section, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellType>

	private var dataSource: DataSource!

	let tvShow: TVShow

	/// Designated initializer
	/// - Parameters:
	///		- tvShow: The tv show model object
	init(tvShow: TVShow) {
		self.tvShow = tvShow
		setupModels()
		fetchTVShowCast()
		fetchTVShowDetails()
	}

	// ! Private

	private func setupModels() {
		cells = [
			.genre(viewModel: genreCellViewModel),
			.overview(viewModel: .init(overviewText: tvShow.overview)),
			.cast(viewModel: castCellViewModel),
			.networks(viewModel: networksCellViewModel)
		]
	}

	private func setupHeaderViewModel() -> TVShowDetailsHeaderViewViewModel {
		let ratingsText = String(describing: tvShow.voteAverage?.round(to: 1) ?? 0) + "/10"

		guard let url = Service.imageURL(.showBackdrop(tvShow), size: "w1280") else {
			return .init(
				imageURL: Bundle.main.url(forResource: "Placeholder", withExtension: "jpg"),
				tvShowNameText: tvShow.name,
				ratingsText: ratingsText
			)
		}

		return .init(imageURL: url, tvShowNameText: tvShow.name, ratingsText: ratingsText)
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
		let urlString = "\(Service.Constants.baseURL)tv/\(tvShow.id)?\(Service.Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: TVShow.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] tvShow, isFromCache in
				guard let self else { return }

				updateGenresNames(with: tvShow.genres ?? [], for: tvShow)
				updateNetworkNames(with: tvShow.networks ?? [])

				reloadSnapshot(animatingDifferences: !isFromCache)
			}
			.store(in: &subscriptions)
	}

	private func updateGenresNames(with genres: [Genre], for tvShow: TVShow) {
		let episodeRunTimes = tvShow.episodeRunTime ?? []
		let episodeRunTimeValues = episodeRunTimes.map { String($0) }

		let episodeAverageDurationText = episodeRunTimes.isEmpty ? "" : String(describing: episodeRunTimeValues.joined(separator: ", ")) + " min"

		let genresNames = genres.map(\.name)

		genreCellViewModel = .init(
			genreText: genresNames.joined(separator: ", "),
			episodeAverageDurationText: episodeAverageDurationText,
			lastAirDateText: tvShow.lastAirDate,
			statusText: tvShow.status
		)
	}

	private func updateCastCrewNames(with castCrew: [Cast]) {
		let castCrewNames = OrderedSet(castCrew.map(\.name))
		let castCrewText = castCrewNames.isEmpty ? "Unknown" : castCrewNames.joined(separator: ", ")

		castCellViewModel = .init(castText: "Cast", castCrewText: castCrewText)
	}

	private func updateNetworkNames(with networks: [Network]) {
		let networksNames = OrderedSet(networks.map(\.name))
		let networksNamesText = networksNames.isEmpty ? "Unknown" : networksNames.joined(separator: ", ")

		networksCellViewModel = .init(networksTitleText: "Networks", networksNamesText: networksNamesText)
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

				case .overview(let overviewCellViewModel):
					let cell: TVShowDetailsOverviewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: overviewCellViewModel)
					return cell

				case .cast:
					let cell: TVShowDetailsCastCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: castCellViewModel)
					return cell

				case .networks:
					let cell: TVShowDetailsNetworksCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: networksCellViewModel)
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
