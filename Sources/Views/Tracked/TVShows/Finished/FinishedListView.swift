import UIKit

@MainActor
protocol FinishedListViewDelegate: AnyObject {
	func finishedListView(_ finishedListView: FinishedListView, didSelect trackedTVShow: TrackedTVShow)
}

/// Class to represent the finished tracked tv shows list view
final class FinishedListView: UIView {
	private lazy var viewModel = FinishedListViewViewModel(collectionView: finishedListCollectionView)
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: "Finished")

	private lazy var finishedListCollectionView: UICollectionView = {
		var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
		layoutConfig.showsSeparators = false
		layoutConfig.trailingSwipeActionsConfigurationProvider = { indexPath in
			let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
				self.viewModel.deleteItem(at: indexPath)
				completion(true)
			}
			return UISwipeActionsConfiguration(actions: [deleteAction])
		}

		let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
		collectionView.refreshControl = refreshControl
		collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
		return collectionView
	}()

	private var refreshControl = UIRefreshControl()

	weak var delegate: FinishedListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		viewModel.delegate = self
		addSubview(finishedListCollectionView)
		pinViewToSafeAreas(finishedListCollectionView)
		finishedListCollectionView.delegate = viewModel
	}

	@objc
	private func didPullToRefresh() {
		Task {
			await viewModel.fetchRatedShows(ignoringCache: true)
		}
	}
}

// ! FinishedListViewViewModelDelegate

extension FinishedListView: FinishedListViewViewModelDelegate {
	func didSelect(trackedTVShow: TrackedTVShow) {
		delegate?.finishedListView(self, didSelect: trackedTVShow)
	}
}
