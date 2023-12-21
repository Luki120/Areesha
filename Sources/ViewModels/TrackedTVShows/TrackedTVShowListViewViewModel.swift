import Combine
import UIKit

protocol TrackedTVShowListViewViewModelDelegate: AnyObject {
	func didSelect(trackedTVShow: TrackedTVShow)
}

/// View model class for TrackedTVShowListView
final class TrackedTVShowListViewViewModel: NSObject {

	private let trackedManager: TrackedTVShowManager = .sharedInstance
	private var subscriptions: Set<AnyCancellable> = []

	weak var delegate: TrackedTVShowListViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<TrackedTVShowCollectionViewListCell, TrackedTVShowCollectionViewListCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, TrackedTVShowCollectionViewListCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, TrackedTVShowCollectionViewListCellViewModel>

	private var dataSource: DataSource!

	@frozen private enum Sections {
		case main
	}

	override init() {
		super.init()

		trackedManager.$trackedTVShows
			.sink { [unowned self] trackedTVShows in
				applyDiffableDataSourceSnapshot(withModels: trackedTVShows)
			}
			.store(in: &subscriptions)
	}

}

// ! UICollectionView

extension TrackedTVShowListViewViewModel: UICollectionViewDelegate {

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
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows)
	}

	private func applyDiffableDataSourceSnapshot(withModels models: [TrackedTVShow]) {
		guard let dataSource else { return }

		let mappedModels = models
			.map(TrackedTVShowCollectionViewListCellViewModel.init(_:))

		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(mappedModels)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(trackedTVShow: trackedManager.trackedTVShows[indexPath.item])
	}

}

// ! Public

extension TrackedTVShowListViewViewModel {

	/// Function to delete an item from the collection view at the given index path
	/// - Parameters:
	///		- at: The index path for the item
	func deleteItem(at indexPath: IndexPath) {
		trackedManager.removeTrackedTVShow(at: indexPath.item)
	}

	/// Function to setup the diffable data source for the collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		setupCollectionViewDiffableDataSource(for: collectionView)
	}

	func didSortDataSource(withOption option: TrackedTVShowManager.SortOption) {
		trackedManager.didSortModels(withOption: option)

		let mappedModels = trackedManager.trackedTVShows
			.map(TrackedTVShowCollectionViewListCellViewModel.init(_:))

 		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(mappedModels)
		dataSource.apply(snapshot)
	}

}
