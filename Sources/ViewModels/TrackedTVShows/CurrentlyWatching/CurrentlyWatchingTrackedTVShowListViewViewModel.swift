import Combine
import UIKit


protocol CurrentlyWatchingTrackedTVShowListViewViewModelDelegate: AnyObject {
	func didSelect(trackedTVShow: TrackedTVShow)
	func didShowToastView()
}

/// View model class for CurrentlyWatchingTrackedTVShowListView
final class CurrentlyWatchingTrackedTVShowListViewViewModel: NSObject {

	private let trackedManager: TrackedTVShowManager = .sharedInstance
	private var subscriptions: Set<AnyCancellable> = []

	weak var delegate: CurrentlyWatchingTrackedTVShowListViewViewModelDelegate?

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

		trackedManager.$trackedTVShows
			.sink { [unowned self] trackedTVShows in
				applyDiffableDataSourceSnapshot(withModels: trackedTVShows.filter { $0.isFinished == false })
			}
			.store(in: &subscriptions)
	}

}

// ! UICollectionView

extension CurrentlyWatchingTrackedTVShowListViewViewModel: UICollectionViewDelegate {

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
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows.filter { $0.isFinished == false })
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

		let trackedTVShows = trackedManager.trackedTVShows.filter { $0.isFinished == false }
		delegate?.didSelect(trackedTVShow: trackedTVShows[indexPath.item])
	}

}

// ! Public

extension CurrentlyWatchingTrackedTVShowListViewViewModel {

	/// Function to delete an item from the collection view at the given index path
	/// - Parameters:
	///		- at: The index path for the item
	func deleteItem(at indexPath: IndexPath) {
		trackedManager.removeTrackedTVShow(at: indexPath.item)
	}

	/// Function to mark a tv show as finished
	/// - Parameters:
	///		- at: The index path for the item
	func finishedShow(at indexPath: IndexPath) {
		trackedManager.finishedShow(at: indexPath.item) { isShowAdded in
			if isShowAdded { self.delegate?.didShowToastView() }
		}
	}

	/// Function to setup the diffable data source for the collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		setupCollectionViewDiffableDataSource(for: collectionView)
	}

	/// Function sort the tv show models according to the given option
	/// - Parameters:
	///		- withOption: The option
	func didSortDataSource(withOption option: TrackedTVShowManager.SortOption) {
		trackedManager.didSortModels(withOption: option)

		let mappedModels = trackedManager.trackedTVShows
			.map(TrackedTVShowCollectionViewCellViewModel.init(_:))

		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(mappedModels)
		dataSource.apply(snapshot)
	}

}
