import Combine
import UIKit

@MainActor
protocol RatedMoviesViewViewModelDelegate: AnyObject {
	func didTap(movie: RatedMovie)
}

/// View model class for `RatedMoviesView`
@MainActor
final class RatedMoviesViewViewModel: BaseViewModel<RatedMovieCell> {
	private var subscriptions = Set<AnyCancellable>()
	weak var delegate: RatedMoviesViewViewModelDelegate?

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)

		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}

		Task {
			await fetchRatedMovies()
		}
	}

	func fetchRatedMovies() async {
		guard let url = URL(string: Service.Constants.ratedMoviesURL) else { return }

		var urlRequest = URLRequest(url: url)
		urlRequest.allHTTPHeaderFields = [
			"accept": "application/json",
			"Authorization": "Bearer \(_Constants.token)"
		]

		let result: (RatedMovieResult, Bool)? = try? await Service.sharedInstance.fetchTVShows(
			request: urlRequest, 
			expecting: RatedMovieResult.self
		).async()

		let initialRatedMovies = result?.0.results ?? []

		let updatedRatedMovies = await withTaskGroup(
			of: RatedMovie?.self,
			returning: [RatedMovie].self
		) { group in
			for ratedMovie in initialRatedMovies {
				group.addTask {
					let result = try? await Service.sharedInstance.fetchDetails(
						for: ratedMovie.id, 
						isMovie: true, 
						expecting: Movie.self
					).async()

					var updatedRatedMovie = ratedMovie
					updatedRatedMovie.movie = result?.0
					return updatedRatedMovie
				}
			}

			var results: [RatedMovie] = []
			for await ratedMovie in group {
				if let ratedMovie {
					results.append(ratedMovie)
				}
			}
			return results
		}

		viewModels = updatedRatedMovies.map {
			let viewModel = RatedMovieCellViewModel($0)
			viewModel.credits = $0.movie?.credits
			viewModel.imageURL = Service.imageURL(.ratedMoviePoster($0))
			return viewModel
		}
		.sorted { ($0.leadActorName, -$0.rating) < ($1.leadActorName, -$1.rating) }

		await MainActor.run {
			applySnapshot()
		}
	}
}

private extension Publisher {
	func async() async throws -> Output where Output: Sendable {
		try await withCheckedThrowingContinuation { continuation in
			var cancellable: AnyCancellable?
			cancellable = first()
				.sink(receiveCompletion: { completion in
					switch completion {
						case .finished: break
						case .failure(let error): continuation.resume(throwing: error)
					}
					cancellable?.cancel()
				}) { value in
					continuation.resume(returning: value)
					cancellable?.cancel()
				}
		}
	}
}

// ! UICollectionViewDelegate

extension RatedMoviesViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		let cellViewModel = viewModels[indexPath.item]
		delegate?.didTap(movie: cellViewModel.ratedMovie)
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard let collectionView = scrollView as? UICollectionView else { return }

		if collectionView.refreshControl!.isRefreshing {
			collectionView.refreshControl?.endRefreshing()
		}
	}
}
