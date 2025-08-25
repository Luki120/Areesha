import UIKit

/// Base class to handle a generic `UICollectionViewDiffableDataSource`
@MainActor
class BaseViewModel<Cell: UICollectionViewCell & Configurable>: NSObject {
	// ! UICollectionViewDiffableDataSource

	typealias ViewModel = Cell.ViewModel
	private typealias CellRegistration = UICollectionView.CellRegistration<Cell, ViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, ViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ViewModel>

	private var dataSource: DataSource!

	private enum Section {
		case main
	}

	/// Closure that takes `(Cell, ViewModel)` & returns nothing to configure the cell's registration
	var onCellRegistration: ((Cell, ViewModel) -> Void)!
	/// Array of view model objects
	var viewModels = [ViewModel]()
	/// Ordered set of view model objects
	var orderedViewModels = OrderedSet<ViewModel>()

	private var collectionView: UICollectionView?

	/// Default initializer, useful if the collection view isn't available at initialization
	override init() {
		super.init()
		awake()
	}

	/// Designated initializer
	/// - Parameter collectionView: The collection view for which to setup the diffable data source
	init(collectionView: UICollectionView) {
		self.collectionView = collectionView
		super.init()
		awake()
		setupDiffableDataSource()
	}

	/// Function available to subclasses to perform any custom initialization before setting up the data source
	func awake() {}

	/// Function to bind the view model to a collection view and set up the diffable data source
	///	- Parameter collectionView: The `UICollectionView` to bind to
	func bind(to collectionView: UICollectionView) {
		self.collectionView = collectionView
		setupDiffableDataSource()
	}

	// ! Private

	private func setupDiffableDataSource() {
		guard let collectionView else {
			assertionFailure("Collection view is nil")
			return
		}

		let cellRegistration = CellRegistration { cell, _, viewModel in
			guard let onCellRegistration = self.onCellRegistration else {
				assertionFailure("You must setup a cell registration calling `onCellRegistration`")
				return
			}
			onCellRegistration(cell, viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			return collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
		}
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot(isOrderedSet: Bool = false) {
		guard let dataSource else { return }

		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(isOrderedSet ? Array(orderedViewModels) : viewModels)
		dataSource.apply(snapshot)
	}
}

// ! Public

extension BaseViewModel {
	/// Function to apply the snapshot to the diffable data source
	/// - Parameter isOrderedSet: A `Bool` to determine wether it's an ordered set or an array
	func applySnapshot(isOrderedSet: Bool = false) {
		applyDiffableDataSourceSnapshot(isOrderedSet: isOrderedSet)
	}

	/// Function to apply the snapshot to the diffable data source using a transformed array of models
	///	- Parameters:
	///		- models: The source array of `Model` objects
	///		- transform: A closure that transforms each `Model` into a `ViewModel` object
	func applySnapshot<Model>(from models: [Model], using transform: (Model) -> ViewModel) {
		let viewModels = models.map(transform)
		self.viewModels = viewModels
		applySnapshot()
	}
}
