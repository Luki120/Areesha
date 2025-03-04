import Combine
import UIKit


protocol FinishedTrackedTVShowListViewViewModelDelegate: AnyObject {
	func didSelect(trackedTVShow: TrackedTVShow)
}

/// View model class for FinishedTrackedTVShowListView
final class FinishedTrackedTVShowListViewViewModel: NSObject {

	private var subscriptions: Set<AnyCancellable> = []

	weak var delegate: FinishedTrackedTVShowListViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<TrackedTVShowCollectionViewListCell, TrackedTVShowCollectionViewCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, TrackedTVShowCollectionViewCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, TrackedTVShowCollectionViewCellViewModel>

	private var dataSource: DataSource!

	private enum Sections {
		case main
	}

	override init() {
		super.init()

		TrackedTVShowManager.sharedInstance.$filteredTrackedTVShows
			.sink { [unowned self] filteredTrackedTVShows in
				applyDiffableDataSourceSnapshot(withModels: filteredTrackedTVShows)
			}
			.store(in: &subscriptions)
	}

}

// ! UICollectionView

extension FinishedTrackedTVShowListViewViewModel: UICollectionViewDelegate {

	private func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.viewModel = viewModel
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot(withModels: TrackedTVShowManager.sharedInstance.filteredTrackedTVShows)
	}

	private func applyDiffableDataSourceSnapshot(withModels models: [TrackedTVShow]) {
		guard let dataSource else { return }

		let mappedModels = models
			.map(TrackedTVShowCollectionViewCellViewModel.init(_:))

		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(mappedModels)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(trackedTVShow: TrackedTVShowManager.sharedInstance.filteredTrackedTVShows[indexPath.item])
	}

}

// ! Public

extension FinishedTrackedTVShowListViewViewModel {

	/// Function to delete an item from the collection view at the given index path
	/// - Parameters:
	///		- at: The index path for the item
	func deleteItem(at indexPath: IndexPath) {
		TrackedTVShowManager.sharedInstance.removeTrackedTVShow(at: indexPath.item, isFilteredArray: true)
	}

	/// Function to setup the diffable data source for the collection view
	///	- Parameters:
	///		- for: The collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		setupCollectionViewDiffableDataSource(for: collectionView)
	}

}
