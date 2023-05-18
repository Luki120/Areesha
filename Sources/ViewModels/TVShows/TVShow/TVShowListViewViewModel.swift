import Combine
import UIKit


protocol TVShowListViewViewModelDelegate: AnyObject {
	func didLoadTVShows()
	func didSelect(tvShow: TVShow)
}

/// View model class for TopRatedTVShowsCollectionViewCell's collection view
final class TVShowListViewViewModel: BaseViewModel<TVShowCollectionViewCell> {

	private var tvShows = [TVShow]() {
		didSet {
			for tvShow in tvShows {
				let imageURLString = "\(Service.Constants.baseImageURL)w500/\(tvShow.posterPath ?? "")"
				guard let url = URL(string: imageURLString) else { return }
				let viewModel = TVShowCollectionViewCellViewModel(imageURL: url)

				if !viewModels.contains(viewModel) {
					viewModels.append(viewModel)
				}
			}
		}
	}

	private var subscriptions = Set<AnyCancellable>()

	weak var delegate: TVShowListViewViewModelDelegate?

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)
		onCellRegistration = { cell, viewModel in
			Task {
				await cell.configure(with: viewModel)
			}
		}
	}

	private func fetchTVShows(withURL url: URL?) {
		guard let url = url else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: APIResponse.self)
			.catch { _ in Just(APIResponse(results: [])) }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] tvShows in
				self?.tvShows = tvShows.results
				self?.delegate?.didLoadTVShows()
			}
			.store(in: &subscriptions)
	}

}

extension TVShowListViewViewModel {

	// ! Public

	/// Function to fetch the current top rated tv shows
	func fetchTopRatedTVShows() {
		fetchTVShows(withURL: URL(string: Service.Constants.topRatedTVShowsURL))
	}

	/// Function to fetch the current trending tv shows of the day
	func fetchTrendingTVShows() {
		fetchTVShows(withURL: URL(string: Service.Constants.trendingTVShowsURL))
	}

}

// ! UICollectionViewDelegate

extension TVShowListViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(tvShow: tvShows[indexPath.item])
	}

}
