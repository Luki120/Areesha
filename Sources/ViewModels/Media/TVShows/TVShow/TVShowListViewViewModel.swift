import Combine
import UIKit

@MainActor
protocol TVShowListViewViewModelDelegate: AnyObject {
	func didLoadTVShows()
	func didSelect(tvShow: TVShow)
	func didSelect(movie: Movie)
}

/// View model class for TopRatedTVShowsCell's collection view
@MainActor
final class TVShowListViewViewModel: NSObject {
	private var movieCellModels = [MovieCellViewModel]()
	private var tvShowCellModels = [TVShowCellViewModel]()

	private var movies = [Movie]() {
		didSet {
			movieCellModels = movies.compactMap { movie in
				return MovieCellViewModel(imageURL: Service.imageURL(for: movie, type: .poster))
			}
		}
	}

	private var tvShows = [TVShow]() {
		didSet {
			tvShowCellModels = tvShows.compactMap { tvShow in
				return TVShowCellViewModel(imageURL: Service.imageURL(for: tvShow, type: .poster))
			}
		}
	}

	private var subscriptions = Set<AnyCancellable>()
	weak var delegate: TVShowListViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private enum CellType: Hashable {
		case topRated(TVShowCellViewModel)
		case trendingMovies(MovieCellViewModel)
	}

	private enum Section {
		case main
	}

	private typealias TVShowCellRegistration = UICollectionView.CellRegistration<TVShowCell, TVShowCellViewModel>
	private typealias MovieCellRegistration = UICollectionView.CellRegistration<MovieCell, MovieCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellType>

	private var dataSource: DataSource!

	private func fetch(withURL url: URL?) {
		guard let url else { return }

		Task {
			await Service.sharedInstance.fetch(withURL: url, expecting: APIResponse.self)
				.catch { _ in Just(APIResponse(results: [])) }
				.receive(on: DispatchQueue.main)
				.sink { [weak self] tvShows in
					self?.tvShows = tvShows.results
					self?.delegate?.didLoadTVShows()
				}
				.store(in: &subscriptions)
		}
	}
}

// ! Public

extension TVShowListViewViewModel {
	/// Function to fetch the current top rated tv shows
	func fetchTopRatedTVShows() {
		fetch(withURL: URL(string: Service.Constants.topRatedTVShowsURL))
	}

	/// Function to fetch the current trending tv shows of the day
	func fetchTrendingTVShows() {
		fetch(withURL: URL(string: Service.Constants.trendingTVShowsURL))
	}

	/// Function to fetch the current trending movies of the day
	func fetchTrendingMovies() {
		guard let url = URL(string: Service.Constants.trendingMoviesURL) else { return }

		Task {
			await Service.sharedInstance.fetch(withURL: url, expecting: MovieResponse.self)
				.catch { _ in Just(MovieResponse(results: [])) }
				.receive(on: DispatchQueue.main)
				.sink { [weak self] movies in
					guard let self else { return }
					self.movies = movies.results
					delegate?.didLoadTVShows()

					Task {
						await fetchAllMovieDetails(for: self.movies)
					}
				}
				.store(in: &subscriptions)
		}
	}

	private func fetchAllMovieDetails(for movies: [Movie]) async {
		await withTaskGroup { group in
			movies.forEach { movie in
				group.addTask { [weak self] in
					let result = try? await Service.sharedInstance.fetchDetails(
						for: movie.id,
						isMovie: true,
						expecting: Movie.self
					).async()

					guard let movie = result?.0 else { return }

					if let index = await self?.movies.firstIndex(where: { $0.id == movie.id }) {
						await self?.update(movie: movie, at: index)
					}
				}
			}
		}
	}

	private func update(movie: Movie, at index: Int) {
		self.movies[index] = movie 
	}
}

// ! UICollectionView

extension TVShowListViewViewModel: UICollectionViewDelegate {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The `UICollectionView`
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		let tvShowCellRegistration = TVShowCellRegistration { cell, _, viewModel in
			cell.configure(with: viewModel)
		}
		let movieCellRegistration = MovieCellRegistration { cell, _, viewModel in
			cell.configure(with: viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, cellType in
			switch cellType {
				case .topRated(let viewModel):
					return collectionView.dequeueConfiguredReusableCell(
						using: tvShowCellRegistration,
						for: indexPath,
						item: viewModel
					)

				case .trendingMovies(let viewModel):
					return collectionView.dequeueConfiguredReusableCell(
						using: movieCellRegistration,
						for: indexPath,
						item: viewModel
					)
			}
		}
	}

	/// Function to apply the diffable data source snapshot
	func applySnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(tvShowCellModels.map { .topRated($0) }, toSection: .main)
		snapshot.appendItems(movieCellModels.map { .trendingMovies($0) }, toSection: .main)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		switch dataSource.snapshot().itemIdentifiers[indexPath.item] {
			case .topRated: delegate?.didSelect(tvShow: tvShows[indexPath.item])
			case .trendingMovies: delegate?.didSelect(movie: movies[indexPath.item])
		}
	}
}
