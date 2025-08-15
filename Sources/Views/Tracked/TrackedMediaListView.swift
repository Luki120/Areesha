import UIKit

@MainActor
protocol TrackedMediaListViewDelegate: AnyObject {
	func trackedMediaListView(
		_ trackedMediaListView: TrackedMediaListView,
		didSelectItemAt indexPath: IndexPath
	)
}

/// Class to represent the tracked media list view
final class TrackedMediaListView: UIView {
	private lazy var viewModel = TrackedMediaListViewViewModel(collectionView: trackedMediaListCollectionView)

	private lazy var trackedMediaListCollectionView: UICollectionView = {
		var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
		collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()

	weak var delegate: TrackedMediaListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(trackedMediaListCollectionView)
		pinViewToAllEdges(trackedMediaListCollectionView)
		trackedMediaListCollectionView.delegate = viewModel

		viewModel.delegate = self
	}
}

// ! TrackedMediaListViewViewModelDelegate

extension TrackedMediaListView: TrackedMediaListViewViewModelDelegate {
	func didSelectItem(at indexPath: IndexPath) {
		delegate?.trackedMediaListView(self, didSelectItemAt: indexPath)
	}
}
