import Combine
import UIKit


protocol ARTVShowListViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
}

/// View model class for ARTVShowListView
final class ARTVShowListViewViewModel: ARBaseViewModel<ARTVShowCollectionViewCell> {

	private var tvShows = [TVShow]() {
		didSet {
			for tvShow in tvShows {
				let imageURLString = "\(ARService.Constants.baseImageURL)w500/\(tvShow.poster_path ?? "")"
				guard let url = URL(string: imageURLString) else { return }
				let viewModel = ARTVShowCollectionViewCellViewModel(imageURL: url)

				if !viewModels.contains(viewModel) {
					viewModels.append(viewModel)
				}
			}
		}
	}

	private var subscriptions = Set<AnyCancellable>()

	weak var delegate: ARTVShowListViewViewModelDelegate?

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)
		onCellRegistration = { cell, viewModel in
			Task {
				await cell.configure(with: viewModel)
			}
		}
	}

}

extension ARTVShowListViewViewModel {

	// ! Public

	/// Function to get the top rated TV shows
	func fetchTVShows() {
		guard let url = URL(string: ARService.Constants.topRatedTVShowsURL) else { return }

		ARService.sharedInstance.fetchTVShows(withURL: url, expecting: APIResponse.self)
			.catch { _ in Just(APIResponse(results: [])) }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] tvShows in
				self?.tvShows = tvShows.results
				self?.applySnapshot()
			}
			.store(in: &subscriptions)
	}

}

// ! UICollectionViewDelegate

extension ARTVShowListViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(tvShow: tvShows[indexPath.row])
	}

}
