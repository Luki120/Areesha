import UIKit

/// View model class for `TrackedTVShowDetailsView`
@MainActor
final class TrackedTVShowDetailsViewViewModel {
	var title: String { return trackedTVShow.episode.name ?? "" }
	var tvShow: TVShow { return trackedTVShow.tvShow }

	private var episodeDetailsCellViewModel: TrackedTVShowDetailsCellViewModel {
		return .init(
			episodeNumber: trackedTVShow.episode.number ?? 0,
			episodeAirDate: trackedTVShow.episode.airDate ?? ""
		)
	}
	private var descriptionCellViewModel: TVShowDetailsDescriptionCellViewModel {
		return .init(description: trackedTVShow.episode.description ?? "")
	}

	// ! UITableViewDiffableDataSource

	private enum CellType: Hashable {
		case episodeDetails(viewModel: TrackedTVShowDetailsCellViewModel)
		case description(viewModel: TVShowDetailsDescriptionCellViewModel)
	}

	private var cells: [CellType] {
		return [
			.episodeDetails(viewModel: episodeDetailsCellViewModel),
			.description(viewModel: descriptionCellViewModel)
		]
	}

	private enum Section {
		case main
	}

	private typealias DataSource = UITableViewDiffableDataSource<Section, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellType>

	private var dataSource: DataSource!

	private let trackedTVShow: TrackedTVShow

	/// Designated initializer
	/// - Parameter trackedTVShow: The `TrackedTVShow` model object
	init(trackedTVShow: TrackedTVShow) {
		self.trackedTVShow = trackedTVShow
	}

	private func setupHeaderViewModel() -> TrackedTVShowDetailsHeaderViewViewModel {
		guard let url = Service.imageURL(.episodeStill(trackedTVShow.episode), size: "w1280") else {
			return .init(
				imageURL: Bundle.main.url(forResource: "Placeholder", withExtension: "jpg"),
				episodeName: trackedTVShow.episode.name ?? ""
			)
		}

		return .init(imageURL: url, episodeName: trackedTVShow.episode.name ?? "")
	}
}

// ! TableView

extension TrackedTVShowDetailsViewViewModel {
	/// Function to setup the table view's header
	/// - Parameter view: The view that owns the table view, therefore the header
	func setupEpisodeHeaderView(forView view: UIView) -> TrackedTVShowDetailsHeaderView {
		let headerView = TrackedTVShowDetailsHeaderView(addRatingsLabel: false)
		headerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160)
		headerView.configure(with: setupHeaderViewModel())
		return headerView
	}

	/// Function to setup the table view's diffable data source
	/// - Parameter tableView: The table view
	func setupTrackedTVShowDetailsTableView(_ tableView: UITableView) {
		dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, _ in
			guard let self else { return nil }

			switch cells[indexPath.row] {
				case .episodeDetails(let episodeDetailsCellViewModel):
					let cell: TrackedTVShowDetailsCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: episodeDetailsCellViewModel)
					return cell

				case .description(let descriptionCellViewModel):
					let cell: TrackedTVShowDetailsDescriptionCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: descriptionCellViewModel)
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
