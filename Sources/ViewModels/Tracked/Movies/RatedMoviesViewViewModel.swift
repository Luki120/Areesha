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
	}

	/// Async function to fetch rated movies
	/// - Parameter completion: `@escaping` closure that takes no arguments & returns nothing
	func fetchRatedMovies(completion: @escaping () -> Void = {}) async {
		let accountId = UserDefaults.standard.integer(forKey: "accountId")
		let sessionId = UserDefaults.standard.string(forKey: "sessionId") ?? ""

		let ratedMovies = await fetchAllRatedMovies(accountId: accountId, sessionId: sessionId)
		let updatedRatedMovies = await fetchMovieDetails(for: ratedMovies)

		viewModels = updatedRatedMovies.map {
			var viewModel = RatedMovieCellViewModel($0)
			viewModel.imageURL = Service.imageURL(for: $0, type: .poster)
			return viewModel
		}
		.sorted { ($0.leadActorName, -$0.rating) < ($1.leadActorName, -$1.rating) }

		applySnapshot()
		completion()
	}

	nonisolated
	private func fetchAllRatedMovies(accountId: Int, sessionId: String) async -> [RatedMovie] {
		guard let baseURL = URL(
			string: "\(Service.Constants.baseURL)account/\(accountId)/rated/movies?\(Service.Constants.apiKey)&session_id=\(sessionId)") else {
			return []
		}

		var allRatedMovies = [RatedMovie]()
		var currentPage = 1
		var totalPages = 1

		repeat {
			var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
			urlComponents?.queryItems?.append(.init(name: "page", value: "\(currentPage)"))

			guard let url = urlComponents?.url else { break }
			let urlRequest = await Service.sharedInstance.makeRequest(for: url)

			let result: (RatedMovieResult, Bool)? = try? await Service.sharedInstance.fetch(
				request: urlRequest,
				expecting: RatedMovieResult.self
			).async()

			guard let response = result?.0 else { break }

			allRatedMovies.append(contentsOf: response.results)
			totalPages = response.totalPages
			currentPage += 1

		} while currentPage <= totalPages

		return allRatedMovies
	}

	nonisolated
	private func fetchMovieDetails(for ratedMovies: [RatedMovie]) async -> [RatedMovie] {
		await withTaskGroup(of: RatedMovie.self, returning: [RatedMovie].self) { group in
			ratedMovies.forEach { ratedMovie in
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

			var results = [RatedMovie]()
			for await ratedMovie in group {
				results.append(ratedMovie)
			}
			return results
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
