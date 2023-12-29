import Combine
import UIKit

/// View model class for TVShowDetailsView
final class TVShowDetailsViewViewModel {

	var title: String { return tvShow.name }

	private var headerViewViewModel: TVShowDetailsHeaderViewViewModel!
	private var genreCellViewModel = TVShowDetailsGenreTableViewCellViewModel()
	private var overviewCellViewModel: TVShowDetailsOverviewTableViewCellViewModel!
	private var castCellViewModel = TVShowDetailsCastTableViewCellViewModel()
	private var networksCellViewModel = TVShowDetailsNetworksTableViewCellViewModel()

	private var subscriptions = Set<AnyCancellable>()

	// ! UITableViewDiffableDataSource

	private enum CellType: Hashable {
		case genre(viewModel: TVShowDetailsGenreTableViewCellViewModel)
		case overview(viewModel: TVShowDetailsOverviewTableViewCellViewModel)
		case cast(viewModel: TVShowDetailsCastTableViewCellViewModel)
		case networks(viewModel: TVShowDetailsNetworksTableViewCellViewModel)
	}

	private var cells = [CellType]()

	@frozen private enum Sections: Hashable {
		case main
	}

	private typealias DataSource = UITableViewDiffableDataSource<Sections, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, CellType>

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

		guard let url = Service.imageURL(.showBackdrop(tvShow), size: "w1280") else { return }

		let ratingsText = String(describing: tvShow.voteAverage?.round(to: 1) ?? 0) + "/10"
		headerViewViewModel = .init(imageURL: url, tvShowNameText: tvShow.name, ratingsText: ratingsText)
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

				let episodeRunTimes = tvShow.episodeRunTime ?? []
				let episodeRunTimeValues = episodeRunTimes.map { String($0) }

				let episodeAverageDurationText = episodeRunTimes.isEmpty ? "" : String(describing: episodeRunTimeValues.joined(separator: ", ")) + " min"

				let genres = tvShow.genres ?? []
				let genresNames = genres.map(\.name)

				updateNetworkNames(with: tvShow.networks ?? [])

				genreCellViewModel = .init(
					genreText: genresNames.joined(separator: ", "),
					episodeAverageDurationText: episodeAverageDurationText,
					lastAirDateText: tvShow.lastAirDate,
					statusText: tvShow.status
				)

				reloadSnapshot(animatingDifferences: !isFromCache)
			}
			.store(in: &subscriptions)
	}

	private func updateCastCrewNames(with castCrew: [Cast]) {
		let castCrewNames = OrderedSet(castCrew.map(\.name))
		let castCrewText = castCrewNames.isEmpty ? "Unknown" : castCrewNames.joined(separator: ", ")

		castCellViewModel = .init(castText: "Cast", castCrewText: castCrewText)
	}

	private func updateNetworkNames(with networks: [Network]) {
		let networksNames = OrderedSet(networks.map(\.name))
		networksCellViewModel = .init(
			networksTitleText: "Networks",
			networksNamesText: networksNames.joined(separator: ", ")
		)
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
		headerView.configure(with: headerViewViewModel)
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
					let cell: TVShowDetailsGenreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: genreCellViewModel)
					return cell

				case .overview(let overviewCellViewModel):
					let cell: TVShowDetailsOverviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: overviewCellViewModel)
					return cell

				case .cast:
					let cell: TVShowDetailsCastTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: castCellViewModel)
					return cell

				case .networks:
					let cell: TVShowDetailsNetworksTableViewCell = tableView.dequeueReusableCell(for: indexPath)
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
