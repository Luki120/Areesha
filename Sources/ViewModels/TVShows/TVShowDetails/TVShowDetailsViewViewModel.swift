import Combine
import UIKit

/// View model class for TVShowDetailsView
final class TVShowDetailsViewViewModel: NSObject {

	let tvShow: TVShow

	private var headerViewViewModel: TVShowDetailsHeaderViewViewModel!
	private var genreCellViewModel = TVShowDetailsGenreTableViewCellViewModel()
	private var overviewCellViewModel: TVShowDetailsOverviewTableViewCellViewModel!
	private var castCellViewModel = TVShowDetailsCastTableViewCellViewModel()
	private var networksCellViewModel = TVShowDetailsNetworksTableViewCellViewModel()

	private var castCrewNames = [String]()
	private var castCrew = [Cast]() {
		didSet {
			for cast in castCrew {
				if !castCrewNames.contains(cast.name) {
					castCrewNames.append(cast.name)
				}
			}
			castCellViewModel = .init(castText: "Cast", castCrewText: castCrewNames.joined(separator: ", "))
		}
	}

	private var networksNames = [String]()
	private var networks = [Network]() {
		didSet {
			for network in networks {
				if !networksNames.contains(network.name) {
					networksNames.append(network.name)
				}
			}
			networksCellViewModel = .init(
				networksTitleText: "Networks",
				networksNamesText: networksNames.joined(separator: ", ")
			)
		}
	}

	private var animatingDifferences = false
	private var subscriptions = Set<AnyCancellable>()

	var title: String { return tvShow.name }

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
	private var snapshot: Snapshot!

	/// Designated initializer
	/// - Parameters:
	///     - tvShow: the tv show model object
	init(tvShow: TVShow) {
		self.tvShow = tvShow
		super.init()
		setupModels()
		fetchTVShowCast()
		fetchTVShowDetails()
	}

	// ! Private

	private func setupModels() {
		cells = [
			.genre(viewModel: genreCellViewModel),
			.overview(viewModel: .init(overviewText: tvShow.overview ?? "")),
			.cast(viewModel: castCellViewModel),
			.networks(viewModel: networksCellViewModel)
		]

		guard let url = URL(string: "\(Service.Constants.baseImageURL)w1280/\(tvShow.backdropPath ?? "")") else {
			return
		}
		headerViewViewModel = .init(imageURL: url)
	}

	private func fetchTVShowCast() {
		let urlString = "\(Service.Constants.baseURL)tv/\(tvShow.id)/credits?api_key=\(Service.Constants.apiKey)&language=en-US"
		guard let url = URL(string: urlString) else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: Credits.self) { isFromCache in
			self.animatingDifferences = !isFromCache ? true : false
		}
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { _ in }) { [weak self] credits in
			self?.castCrew = credits.cast
			self?.reloadSnapshot(self?.animatingDifferences ?? false)
		}
		.store(in: &subscriptions)
	}

	private func fetchTVShowDetails() {
		let urlString = "\(Service.Constants.baseURL)tv/\(tvShow.id)?api_key=\(Service.Constants.apiKey)&language=en-US"
		guard let url = URL(string: urlString) else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: TVShow.self) { isFromCache in
			self.animatingDifferences = !isFromCache ? true : false
		}
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { _ in }) { [weak self] tvShow in
			guard let self = self else { return }

			let episodeRunTimes = tvShow.episodeRunTime ?? []
			let episodeRunTimeValues = episodeRunTimes.map { String($0) }

			let episodeAverageDurationText = episodeRunTimes.isEmpty ? "" : String(describing: episodeRunTimeValues.joined(separator: ", ")) + " min"

			let genres = tvShow.genres ?? []
			let genresNames = genres.map(\.name)

			self.networks = tvShow.networks ?? []

			self.genreCellViewModel = .init(
				genreText: genresNames.joined(separator: ", "),
				episodeAverageDurationText: episodeAverageDurationText,
				lastAirDateText: tvShow.lastAirDate,
				statusText: tvShow.status,
				voteAverageText: String(describing: tvShow.voteAverage?.round(to: 1) ?? 0) + "/10"
			)

			self.reloadSnapshot(self.animatingDifferences)
		}
		.store(in: &subscriptions)
	}

}

// ! TableView

extension TVShowDetailsViewViewModel {

	/// Function to setup the table view's header
	/// - Parameters:
	///     - view: the view that owns the table view, therefore the header
	func setupHeaderView(forView view: UIView) -> TVShowDetailsHeaderView {
		let headerView = TVShowDetailsHeaderView()
		headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160)
		headerView.configure(with: headerViewViewModel)
		return headerView
	}

	/// Function to setup the table view's diffable data source
	/// - Parameters:
	///     - tableView: the table view
	func setupTableView(_ tableView: UITableView) {
		dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, _ -> UITableViewCell? in
			guard let self = self else { return nil }

			switch self.cells[indexPath.row] {
				case .genre:
					let cell: TVShowDetailsGenreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: self.genreCellViewModel)
					return cell

				case .overview(let overviewCellViewModel):
					let cell: TVShowDetailsOverviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: overviewCellViewModel)
					return cell

				case .cast:
					let cell: TVShowDetailsCastTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: self.castCellViewModel)
					return cell

				case .networks:
					let cell: TVShowDetailsNetworksTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: self.networksCellViewModel)
					return cell
			}
		}

		applySnapshot()
	}

	private func applySnapshot() {
		snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(cells)

		dataSource.apply(snapshot, animatingDifferences: true)
	}

	private func reloadSnapshot(_ animatingDifferences: Bool) {
		var snapshot = dataSource.snapshot()
		snapshot.reconfigureItems(cells)

		dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
	}

}
