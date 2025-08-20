import Combine
import UIKit

@MainActor
protocol FinishedListViewViewModelDelegate: AnyObject {
	func didSelect(ratedTVShow: RatedTVShow)
}

/// View model class for `FinishedListView`
@MainActor
final class FinishedListViewViewModel: BaseViewModel<TrackedTVShowListCell> {
	private var ratedShows = [RatedTVShow]() {
		didSet {
			ratedShows.sort { $0.rating > $1.rating }
		}
	}

	private var subscriptions: Set<AnyCancellable> = []
	weak var delegate: FinishedListViewViewModelDelegate?

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)

		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}

		Task {
			await fetchRatedShows()
		}
	}

	func fetchRatedShows() async {
		guard let baseURL = URL(string: Service.Constants.ratedShowsURL) else { return }

		var currentPage = 1
		var totalPages = 1

		repeat {
			var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
			urlComponents?.queryItems = [URLQueryItem(name: "page", value: "\(currentPage)")]

			guard let url = urlComponents?.url else { break }
			let urlRequest = await Service.sharedInstance.makeRequest(for: url)

			let result: (RatedTVShowResult, Bool)? = try? await Service.sharedInstance.fetch(
				request: urlRequest,
				expecting: RatedTVShowResult.self
			).async()

			guard let response = result?.0 else { break }
			totalPages = response.totalPages

			for updatedShow in response.results {
				if let index = ratedShows.firstIndex(where: { $0.id == updatedShow.id }) {
					ratedShows[index].rating = updatedShow.rating
				}
			}

			let newItems = response.results.filter { newShow in
				!ratedShows.contains { $0.id == newShow.id }
			}
			ratedShows.append(contentsOf: newItems)
			ratedShows.forEach { fetchDetails(for: $0) }

			applySnapshot(from: ratedShows)
			currentPage += 1

		} while currentPage <= totalPages
	}

	private func fetchDetails(for ratedShow: RatedTVShow) {
		Task {
			await Service.sharedInstance.fetchDetails(for: ratedShow.id, expecting: TVShow.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] tvShow, _ in
				guard let index = self?.ratedShows.firstIndex(where: { $0.id == tvShow.id }) else { return }
				self?.ratedShows[index].tvShow = tvShow
			}
			.store(in: &subscriptions)		
		}
	}

	private func applySnapshot(from models: [RatedTVShow]) {
		applySnapshot(from: models) {
			var viewModel = TrackedTVShowCellViewModel($0)
			viewModel.imageURL = Service.imageURL(.mediaPoster($0.backgroundCoverImage))
			viewModel.listType = .finished
			return viewModel
		}
	}
}

// ! UICollectionViewDelegate

extension FinishedListViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(ratedTVShow: ratedShows[indexPath.item])
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard let collectionView = scrollView as? UICollectionView else { return }

		if collectionView.refreshControl!.isRefreshing {
			collectionView.refreshControl?.endRefreshing()
		}
	}
}
