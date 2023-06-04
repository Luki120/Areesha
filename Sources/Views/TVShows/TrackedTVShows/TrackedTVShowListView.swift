import UIKit

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

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		viewModel.setupDiffableDataSource(for: trackedTVShowsListCollectionView)
		addSubview(trackedTVShowsListCollectionView)
		trackedTVShowsListCollectionView.delegate = viewModel
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToSafeAreas(trackedTVShowsListCollectionView)
	}

}
