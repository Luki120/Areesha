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

	private typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
	private typealias CellRegistration = UICollectionView.CellRegistration<TrackedTVShowCollectionViewListCell, TrackedTVShowCollectionViewCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, TrackedTVShowCollectionViewCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TrackedTVShowCollectionViewCellViewModel>

	private var dataSource: DataSource!

	private enum Section: String {
		case currentlyWatching = "Currently watching"
		case returningSeries = "Returning series"

		var title: String { rawValue }
	}

	override init() {
		super.init()

		trackedManager.$trackedTVShows
			.sink { [unowned self] trackedTVShows in
				applyDiffableDataSourceSnapshot(withModels: trackedTVShows.filter { $0.isFinished == false })
			}
			.store(in: &subscriptions)
	}

	private func getModelIndex(for indexPath: IndexPath) -> Int? {
		let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
		let relevantShows: [TrackedTVShow]

		switch section {
			case .currentlyWatching:
				relevantShows = trackedManager.trackedTVShows.filter { $0.isFinished == false && !$0.isReturningSeries }

			case .returningSeries:
				relevantShows = trackedManager.trackedTVShows.filter { $0.isReturningSeries }
		}

		guard indexPath.item < relevantShows.count else { return nil }

		let selectedShow = relevantShows[indexPath.item]
		return trackedManager.trackedTVShows.firstIndex(where: { $0 == selectedShow })
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
		setupSupplementaryRegistration()
	}

	private func setupSupplementaryRegistration() {
		let headerRegistration = HeaderRegistration(
			elementKind: UICollectionView.elementKindSectionHeader
		) { headerView, _, indexPath in
			let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

			var configuration = headerView.defaultContentConfiguration()
			var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()

			backgroundConfiguration.backgroundColor = .clear
			configuration.text = section.title

			headerView.backgroundConfiguration = backgroundConfiguration
			headerView.contentConfiguration = configuration
		}

		dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
			return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
		}
	}

	private func applyDiffableDataSourceSnapshot(withModels models: [TrackedTVShow]) {
		guard let dataSource else { return }

		let currentlyWatchingModels = models
			.filter { !$0.isFinished && !$0.isReturningSeries }
			.map(TrackedTVShowCollectionViewCellViewModel.init(_:))

		let returningShowsModels = models
			.filter { $0.isReturningSeries }
			.map(TrackedTVShowCollectionViewCellViewModel.init(_:))

		var snapshot = Snapshot()
		snapshot.appendSections([.currentlyWatching, .returningSeries])
		snapshot.appendItems(currentlyWatchingModels, toSection: .currentlyWatching)
		snapshot.appendItems(returningShowsModels, toSection: .returningSeries)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		switch indexPath.section {
			case 0:
				let trackedTVShows = trackedManager.trackedTVShows.filter { !$0.isFinished && !$0.isReturningSeries }
				delegate?.didSelect(trackedTVShow: trackedTVShows[indexPath.item])

			case 1:
				let trackedTVShows = trackedManager.trackedTVShows.filter { $0.isReturningSeries }
				delegate?.didSelect(trackedTVShow: trackedTVShows[indexPath.item])

			default: break
		}
	}

}

// ! Public

extension CurrentlyWatchingTrackedTVShowListViewViewModel {

	/// Function to delete an item from the collection view at the given index path
	/// - Parameters:
	///		- at: The index path for the item
	func deleteItem(at indexPath: IndexPath) {
		guard let index = getModelIndex(for: indexPath),
			let item = dataSource.itemIdentifier(for: indexPath) else { return }

		trackedManager.deleteTrackedTVShow(at: index)

		var snapshot = dataSource.snapshot()
		snapshot.deleteItems([item])
		dataSource.apply(snapshot)
	}

	/// Function to mark a tv show as finished
	/// - Parameters:
	///		- at: The index path for the item
	func finishedShow(at indexPath: IndexPath) {
		guard let index = getModelIndex(for: indexPath) else { return }

		trackedManager.finishedShow(at: index) { [weak self] isShowAdded in
			if isShowAdded { self?.delegate?.didShowToastView() }
		}
	}

	/// Function to mark a currently watching show as returning series
	/// - Parameters:
	///		- at: The index path for the tv show
	///		- toggle: Boolean value to toggle between returning series or currently watching
	func markShowAsReturningSeries(at indexPath: IndexPath, toggle: Bool = true) {
		guard let index = getModelIndex(for: indexPath) else { return }

		trackedManager.markShowAsReturningSeries(at: index, toggle: toggle)
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows)
	}

	/// Function to setup the diffable data source for the collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		setupCollectionViewDiffableDataSource(for: collectionView)
	}

	/// Function to sort the tv show models according to the given option
	/// - Parameters:
	///		- withOption: The option
	func didSortDataSource(withOption option: TrackedTVShowManager.SortOption) {
		trackedManager.didSortModels(withOption: option)
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows)
	}

}
