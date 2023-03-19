import UIKit

/// Base class to handle a generic UICollectionViewDiffableDataSource
class BaseViewModel<Cell: UICollectionViewCell & Configurable>: NSObject {

	// ! UICollectionViewDiffableDataSource

	typealias ViewModel = Cell.ViewModel
	private typealias CellRegistration = UICollectionView.CellRegistration<Cell, ViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, ViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, ViewModel>

	private var dataSource: DataSource!
	private var snapshot: Snapshot!

	@frozen private enum Sections {
		case main
	}

	/// Closure that takes two generic arguments & returns nothing to configure the cell's registration
	var onCellRegistration: ((Cell, ViewModel) -> Void)!
	/// Array of view model objects
	var viewModels = [ViewModel]()

	private let collectionView: UICollectionView

	/// Designated initializer
	/// - Parameters:
	///     - collectionView: the collection view for which to setup the diffable data source
	init(collectionView: UICollectionView) {
		self.collectionView = collectionView
		super.init()
		setupCollectionViewDiffableDataSource()
	}

	// ! Private

	private func setupCollectionViewDiffableDataSource() {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			self.onCellRegistration(cell, viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier -> UICollectionViewCell? in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(viewModels)
		dataSource.apply(snapshot, animatingDifferences: true)
	}

}

extension BaseViewModel {

	// ! Public

	/// Function to setup the diffable data source
	func setupDiffableDataSource() {
		setupCollectionViewDiffableDataSource()
	}

	/// Function to apply the snapshot to the diffable data source
	func applySnapshot() {
		applyDiffableDataSourceSnapshot()
	}

}
