import UIKit

/// Base class to handle a generic UICollectionViewDiffableDataSource
class BaseViewModel<Cell: UICollectionViewCell & Configurable>: NSObject {

	// ! UICollectionViewDiffableDataSource

	typealias ViewModel = Cell.ViewModel
	private typealias CellRegistration = UICollectionView.CellRegistration<Cell, ViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, ViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, ViewModel>

	private var dataSource: DataSource!

	@frozen private enum Sections {
		case main
	}

	/// Closure that takes two generic arguments & returns nothing to configure the cell's registration
	var onCellRegistration: ((Cell, ViewModel) -> Void)!
	/// Array of view model objects
	var viewModels = [ViewModel]()
	/// Ordered set of view model objects
	var orderedViewModels = OrderedSet<ViewModel>()

	private let collectionView: UICollectionView

	/// Designated initializer
	/// - Parameters:
	///		- collectionView: The collection view for which to setup the diffable data source
	init(collectionView: UICollectionView) {
		self.collectionView = collectionView
		super.init()
		awake()
		setupCollectionViewDiffableDataSource()
	}

	/// Function available to subclasses to perform any custom initialization before setting up the data source
	func awake() {}

	// ! Private

	private func setupCollectionViewDiffableDataSource() {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			self.onCellRegistration(cell, viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot(isOrderedSet: Bool = false) {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(isOrderedSet ? Array(orderedViewModels) : viewModels)
		dataSource.apply(snapshot)
	}

}

extension BaseViewModel {

	// ! Public

	/// Function to apply the snapshot to the diffable data source
	/// - Parameters:
	///		- isOrderedSet: A boolean to determine wether it's an ordered set or an array
	func applySnapshot(isOrderedSet: Bool = false) {
		applyDiffableDataSourceSnapshot(isOrderedSet: isOrderedSet)
	}

}
