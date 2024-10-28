import UIKit


protocol TrackedTVShowListViewDelegate: AnyObject {
	func trackedTVShowListView(
		_ trackedTVShowListView: TrackedTVShowListView,
		didSelectItemAt indexPath: IndexPath
	)
}

/// Class to represent the tracked tv shows list view
final class TrackedTVShowListView: UIView {

	private lazy var viewModel = TrackedTVShowListViewViewModel()

	private lazy var trackedTVShowsListCollectionView: UICollectionView = {
		var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
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
		addSubview(trackedTVShowsListCollectionView)
		pinViewToAllEdges(trackedTVShowsListCollectionView)
		trackedTVShowsListCollectionView.delegate = viewModel

		viewModel.delegate = self
		viewModel.setupCollectionViewDiffableDataSource(for: trackedTVShowsListCollectionView)
	}

}

// ! TrackedTVShowListViewViewModelDelegate

extension TrackedTVShowListView: TrackedTVShowListViewViewModelDelegate {

	func didSelectItemAt(indexPath: IndexPath) {
		delegate?.trackedTVShowListView(self, didSelectItemAt: indexPath)
	}

}
