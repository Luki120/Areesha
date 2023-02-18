import Combine
import UIKit

/// View model class for ARTVShowDetailsViewViewModel
final class ARTVShowDetailsViewViewModel: NSObject {

	private let tvShow: TVShow

	private var headerViewViewModel: ARTVShowDetailsHeaderViewViewModel!
	private var genreCellViewModel = ARTVShowDetailsGenreTableViewCellViewModel()
	private var overviewCellViewModel: ARTVShowDetailsOverviewTableViewCellViewModel!
	private var castCellViewModel = ARTVShowDetailsCastTableViewCellViewModel()
	private var networksCellViewModel = ARTVShowDetailsNetworksTableViewCellViewModel()

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

	private var genreText = ""
	private var episodeAverageDurationText = ""

	private var episodeRunTimeValues = [String]()
	private var episodeRunTimes = [Int]()

	private var genresNames = [String]()
	private var genres = [Genres]()

	private var networksNames = [String]()
	private var networks = [Networks]() {
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
		case genre(viewModel: ARTVShowDetailsGenreTableViewCellViewModel)
		case overview(viewModel: ARTVShowDetailsOverviewTableViewCellViewModel)
		case cast(viewModel: ARTVShowDetailsCastTableViewCellViewModel)
		case networks(viewModel: ARTVShowDetailsNetworksTableViewCellViewModel)
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
	}

	// ! Private

	private func setupModels() {
		cells = [
			.genre(viewModel: genreCellViewModel),
			.overview(viewModel: .init(overviewText: tvShow.overview ?? "")),
			.cast(viewModel: castCellViewModel),
			.networks(viewModel: networksCellViewModel)
		]

		guard let url = URL(string: "\(ARService.Constants.baseImageURL)w1280/\(tvShow.backdrop_path ?? "")") else {
			return
		}
		headerViewViewModel = .init(imageURL: url)
	}

	private func fetchTVShowCast() {
		let urlString = "\(ARService.Constants.baseURL)tv/\(tvShow.id)/credits?api_key=\(ARService.Constants.apiKey)&language=en-US"
		guard let url = URL(string: urlString) else { return }

		ARService.sharedInstance.fetchTVShows(withURL: url, expecting: Credits.self) { isFromCache in
			self.animatingDifferences = !isFromCache ? true : false
		}
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { _ in }) { [weak self] credits in
			self?.castCrew = credits.cast
			self?.reloadSnapshot(self?.animatingDifferences ?? false)
		}
		.store(in: &subscriptions)
	}

	private func fetchCurrentTVShowDetails() {
		let urlString = "\(ARService.Constants.baseURL)tv/\(tvShow.id)?api_key=\(ARService.Constants.apiKey)&language=en-US"
		guard let url = URL(string: urlString) else { return }

		ARService.sharedInstance.fetchTVShows(withURL: url, expecting: TVShow.self) { isFromCache in
			self.animatingDifferences = !isFromCache ? true : false
		}
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { _ in }) { [weak self] tvShow in
			guard let self = self else { return }

			self.episodeRunTimes = tvShow.episode_run_time ?? []
			self.episodeRunTimeValues = self.episodeRunTimes.map { String($0) }
			self.episodeAverageDurationText = self.episodeRunTimeValues.joined(separator: ", ")

			self.genres = tvShow.genres ?? []
			self.genresNames = self.genres.map(\.name)
			self.genreText = self.genresNames.joined(separator: ", ")

			self.networks = tvShow.networks ?? []

			self.genreCellViewModel = .init(
				genreText: self.genreText,
				episodeAverageDurationText: self.episodeAverageDurationText,
				lastAirDateText: tvShow.last_air_date,
				statusText: tvShow.status
			)

			self.reloadSnapshot(self.animatingDifferences)
		}
		.store(in: &subscriptions)
	}

}

extension ARTVShowDetailsViewViewModel {

	// ! Public

	/// Function to get additional details for the specified TV show id
	func fetchTVShowDetails() {
		fetchTVShowCast()
		fetchCurrentTVShowDetails()
	}

}

// ! TableView

extension ARTVShowDetailsViewViewModel {

	/// Function to setup the table view's header
	/// - Parameters:
	///     - view: the view that owns the table view, therefore the header
	func setupHeaderView(forView view: UIView) -> ARTVShowDetailsHeaderView {
		let headerView = ARTVShowDetailsHeaderView()
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
					let cell: ARTVShowDetailsGenreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: self.genreCellViewModel)
					return cell

				case .overview(let overviewCellViewModel):
					let cell: ARTVShowDetailsOverviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: overviewCellViewModel)
					return cell

				case .cast:
					let cell: ARTVShowDetailsCastTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: self.castCellViewModel)
					return cell

				case .networks:
					let cell: ARTVShowDetailsNetworksTableViewCell = tableView.dequeueReusableCell(for: indexPath)
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
