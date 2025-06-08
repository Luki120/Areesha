import Combine
import UIKit

protocol FinishedListViewViewModelDelegate: AnyObject {
	func didSelect(trackedTVShow: TrackedTVShow)
}

/// View model class for `FinishedListView`
final class FinishedListViewViewModel: NSObject {
	private var sortedShows = [TrackedTVShow]()
	private var subscriptions: Set<AnyCancellable> = []
	weak var delegate: FinishedListViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<TrackedTVShowListCell, TrackedTVShowCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, TrackedTVShowCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TrackedTVShowCellViewModel>

	private var dataSource: DataSource!

	private enum Section {
		case main
	}

	override init() {
		super.init()

		TrackedTVShowManager.sharedInstance.$filteredTrackedTVShows
			.sink { [unowned self] filteredTrackedTVShows in
				sortedShows = filteredTrackedTVShows.sorted { $0.rating ?? 0 > $1.rating ?? 0 }
				applyDiffableDataSourceSnapshot(withModels: sortedShows)
			}
			.store(in: &subscriptions)

		fetchRatedShows()
	}

	private func fetchRatedShows() {
		guard let url = URL(string: Service.Constants.ratedShowsURL) else { return }

		var urlRequest = URLRequest(url: url)
		urlRequest.allHTTPHeaderFields = [
			"accept": "application/json",
			"Authorization": "Bearer \(_Constants.token)"
		]

		Service.sharedInstance.fetchTVShows(request: urlRequest, expecting: RatedTVShowResult.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { ratedShows, _ in
				TrackedTVShowManager.sharedInstance.updateRatings(with: ratedShows.results)
			}
			.store(in: &subscriptions)
	}
}

// ! UICollectionView

extension FinishedListViewViewModel: UICollectionViewDelegate {
	private func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.viewModel = viewModel
			cell.viewModel?.listType = .finished
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot(withModels: sortedShows)
	}

	private func applyDiffableDataSourceSnapshot(withModels models: [TrackedTVShow]) {
		guard let dataSource else { return }

		let mappedModels = models.map(TrackedTVShowCellViewModel.init(_:))

		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(mappedModels)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(trackedTVShow: sortedShows[indexPath.item])
	}
}

// ! Public

extension FinishedListViewViewModel {
	/// Function to delete an item from the collection view at the given index path
	/// - Parameters:
	///		- at: The index path for the item
	func deleteItem(at indexPath: IndexPath) {
		TrackedTVShowManager.sharedInstance.deleteTrackedTVShow(at: indexPath.item, isFilteredArray: true)
	}

	/// Function to setup the diffable data source for the collection view
	///	- Parameters:
	///		- for: The collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		setupCollectionViewDiffableDataSource(for: collectionView)
	}
}
