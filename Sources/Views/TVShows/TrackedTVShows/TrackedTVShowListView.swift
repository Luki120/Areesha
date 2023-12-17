import UIKit


protocol TrackedTVShowListViewDelegate: AnyObject {
	func trackedTVShowListView(
		_ trackedTVShowListView: TrackedTVShowListView,
		didSelect trackedTVShow: TrackedTVShow
	)
}

/// Class to represent the tracked tv shows list view
final class TrackedTVShowListView: UIView {

	private lazy var viewModel = TrackedTVShowListViewViewModel()

	private lazy var trackedTVShowsListCollectionView: UICollectionView = {
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
		collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()

	weak var delegate: TrackedTVShowListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		viewModel.delegate = self
		viewModel.setupDiffableDataSource(for: trackedTVShowsListCollectionView)
		addSubview(trackedTVShowsListCollectionView)
		trackedTVShowsListCollectionView.delegate = viewModel
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToSafeAreas(trackedTVShowsListCollectionView)
	}

}

// ! TrackedTVShowListViewViewModelDelegate

extension TrackedTVShowListView: TrackedTVShowListViewViewModelDelegate {

	func didSelect(trackedTVShow: TrackedTVShow) {
		delegate?.trackedTVShowListView(self, didSelect: trackedTVShow)
	}

}
