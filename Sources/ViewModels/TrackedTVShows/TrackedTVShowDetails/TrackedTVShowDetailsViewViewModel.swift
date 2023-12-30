import UIKit

/// View model class for TrackedTVShowDetailsView
final class TrackedTVShowDetailsViewViewModel {

	var title: String { return trackedTVShow.episode.name ?? "" }

	private var episodeDetailsCellViewModel: TrackedTVShowDetailsEpisodeDetailsTableViewCellViewModel {
		return .init(
			episodeNumber: trackedTVShow.episode.episodeNumber ?? 0,
			episodeAirDateText: trackedTVShow.episode.airDate ?? ""
		)
	}
	private var overviewCellViewModel: TrackedTVShowDetailsOverviewTableViewCellViewModel {
		return .init(overviewText: trackedTVShow.episode.overview ?? "")
	}

	// ! UITableViewDiffableDataSource

	private enum CellType: Hashable {
		case episodeDetails(viewModel: TrackedTVShowDetailsEpisodeDetailsTableViewCellViewModel)
		case overview(viewModel: TrackedTVShowDetailsOverviewTableViewCellViewModel)
	}

	private var cells: [CellType] {
		return [
			.episodeDetails(viewModel: episodeDetailsCellViewModel),
			.overview(viewModel: overviewCellViewModel)
		]
	}

	@frozen private enum Sections {
		case main
	}

	private typealias DataSource = UITableViewDiffableDataSource<Sections, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, CellType>

	private var dataSource: DataSource!

	private let trackedTVShow: TrackedTVShow

	/// Designated initializer
	/// - Parameters:
	///		- trackedTVShow: The tracked tv show model object
	init(trackedTVShow: TrackedTVShow) {
		self.trackedTVShow = trackedTVShow
	}

	private func setupHeaderViewModel() -> TrackedTVShowDetailsEpisodeDetailsHeaderViewViewModel {
		guard let url = Service.imageURL(.episodeStill(trackedTVShow.episode), size: "w1280") else { fatalError() }

		return .init(imageURL: url, episodeNameText: trackedTVShow.episode.name ?? "")
	}

}

// ! TableView

extension TrackedTVShowDetailsViewViewModel {

	/// Function to setup the table view's header
	/// - Parameters:
	///		- view: The view that owns the table view, therefore the header
	func setupEpisodeHeaderView(forView view: UIView) -> TrackedTVShowDetailsEpisodeDetailsHeaderView {
		let headerView = TrackedTVShowDetailsEpisodeDetailsHeaderView(addRatingsLabel: false)
		headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160)
		headerView.configure(with: setupHeaderViewModel())
		return headerView
	}

	/// Function to setup the table view's diffable data source
	/// - Parameters:
	///		- tableView: The table view
	func setupTrackedTVShowDetailsTableView(_ tableView: UITableView) {
		dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, _ in
			guard let self else { return nil }

			switch cells[indexPath.row] {
				case .episodeDetails(let episodeDetailsCellViewModel):
					let cell: TrackedTVShowDetailsEpisodeDetailsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: episodeDetailsCellViewModel)
					return cell

				case .overview(let overviewCellViewModel):
					let cell: TrackedTVShowDetailsOverviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: overviewCellViewModel)
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

}
