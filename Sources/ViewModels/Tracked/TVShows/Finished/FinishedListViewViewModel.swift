import Combine
import UIKit

@MainActor
protocol FinishedListViewViewModelDelegate: AnyObject {
	func didSelect(trackedTVShow: TrackedTVShow)
}

/// View model class for `FinishedListView`
@MainActor
final class FinishedListViewViewModel: BaseViewModel<TrackedTVShowListCell> {
	private var sortedShows = [TrackedTVShow]()
	private var subscriptions: Set<AnyCancellable> = []
	weak var delegate: FinishedListViewViewModelDelegate?

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)

		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}

		TrackedTVShowManager.sharedInstance.$filteredTrackedTVShows
			.sink { [unowned self] filteredTrackedTVShows in
				sortedShows = filteredTrackedTVShows.sorted { $0.rating ?? 0 > $1.rating ?? 0 }
				applySnapshot(from: sortedShows) {
					var viewModel = TrackedTVShowCellViewModel($0)
					viewModel.listType = .finished
					return viewModel
				}
			}
			.store(in: &subscriptions)

		Task {
			await fetchRatedShows()
		}
	}

	func fetchRatedShows(ignoringCache: Bool = false) async {
		guard let baseURL = URL(string: Service.Constants.ratedShowsURL) else { return }

		var allRatedShows = [RatedTVShow]()
		var currentPage = 1
		var totalPages = 1

		repeat {
			var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
			urlComponents?.queryItems = [URLQueryItem(name: "page", value: "\(currentPage)")]

			guard let url = urlComponents?.url else { break }
			let urlRequest = await Service.sharedInstance.makeRequest(for: url)

			if !ignoringCache {
				await Service.sharedInstance.fetchTVShows(request: urlRequest, expecting: RatedTVShowResult.self)
					.receive(on: DispatchQueue.main)
					.sink(receiveCompletion: { _ in }) { ratedShows, _ in
						allRatedShows.append(contentsOf: ratedShows.results)
						totalPages = ratedShows.totalPages
						TrackedTVShowManager.sharedInstance.updateRatings(with: allRatedShows)
					}
					.store(in: &subscriptions)
			}
			else {
				await Service.sharedInstance.fetchTVShows(request: urlRequest, expecting: RatedTVShowResult.self)
					.receive(on: DispatchQueue.main)
					.sink(receiveCompletion: { _ in }) { ratedShows in
						allRatedShows.append(contentsOf: ratedShows.results)
						totalPages = ratedShows.totalPages
						TrackedTVShowManager.sharedInstance.updateRatings(with: allRatedShows)
					}
					.store(in: &subscriptions)
			}

			currentPage += 1

		} while currentPage <= totalPages
	}
}

// ! UICollectionViewDelegate

extension FinishedListViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(trackedTVShow: sortedShows[indexPath.item])
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard let collectionView = scrollView as? UICollectionView else { return }

		if collectionView.refreshControl!.isRefreshing {
			collectionView.refreshControl?.endRefreshing()
		}
	}
}

// ! Public

extension FinishedListViewViewModel {
	/// Function to delete an item from the collection view
	/// - Parameter indexPath: The `IndexPath` for the item
	func deleteItem(at indexPath: IndexPath) {
		TrackedTVShowManager.sharedInstance.deleteTrackedTVShow(at: indexPath.item, isFilteredArray: true)
	}
}
