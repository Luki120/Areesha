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

	/// Function to fetch a request token
	///	- Parameter completion: `@escaping` closure that takes a `String` & returns nothing
	func fetchRequestToken(completion: @escaping (String) -> ()) {
		Task {
			await viewModel.fetchRequestToken(completion: completion)
		}
	}

	/// Function to create a session id
	///	- Parameter requestToken: A `String` that represents the request token
	func createSessionId(requestToken: String) {
		Task {
			await viewModel.createSessionId(requestToken: requestToken)
		}
	}
}

// ! TrackedMediaListViewViewModelDelegate

extension TrackedMediaListView: TrackedMediaListViewViewModelDelegate {
	func didSelectItem(at indexPath: IndexPath) {
		delegate?.trackedMediaListView(self, didSelectItemAt: indexPath)
	}
}
