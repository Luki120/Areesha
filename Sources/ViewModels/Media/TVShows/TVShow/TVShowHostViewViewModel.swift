import UIKit

@MainActor
protocol TVShowHostViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
	func didSelect(movie: Movie)
}

/// View model class for `TVShowHostView`
@MainActor
final class TVShowHostViewViewModel: NSObject {
	weak var delegate: TVShowHostViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private enum Section {
		case main
	}

	private enum Item: Hashable {
		case topRated, trending, trendingMovies
	}

	private typealias TopRatedCellRegistration = UICollectionView.CellRegistration<TopRatedTVShowsCell, Item>
	private typealias TrendingCellRegistration = UICollectionView.CellRegistration<TrendingTVShowsCell, Item>
	private typealias TrendingMoviesCellRegistration = UICollectionView.CellRegistration<TrendingMoviesCell, Item>

	private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

	private var dataSource: DataSource!
}

// ! UICollectionView

extension TVShowHostViewViewModel {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		let topRatedCellRegistration = TopRatedCellRegistration { cell, _, _ in
			cell.delegate = self
		}
		let trendingCellRegistration = TrendingCellRegistration { cell, _, _ in
			cell.delegate = self
		}
		let trendingMoviesCellRegistration = TrendingMoviesCellRegistration { cell, _, _ in
			cell.delegate = self
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
			switch item {
				case .topRated:
					return collectionView.dequeueConfiguredReusableCell(
						using: topRatedCellRegistration,
						for: indexPath,
						item: item
					)

				case .trending:
					return collectionView.dequeueConfiguredReusableCell(
						using: trendingCellRegistration,
						for: indexPath,
						item: item
					)

				case .trendingMovies:
					return collectionView.dequeueConfiguredReusableCell(
						using: trendingMoviesCellRegistration,
						for: indexPath,
						item: item
					)
			}
		}
		applySnapshot()
	}

	private func applySnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems([.topRated, .trending, .trendingMovies], toSection: .main)
		dataSource.apply(snapshot)
	}
}

// ! TopRatedTVShowsCellDelegate

extension TVShowHostViewViewModel: TopRatedTVShowsCellDelegate {
	func topRatedTVShowsCell(_ topRatedTVShowsCell: TopRatedTVShowsCell, didSelect tvShow: TVShow) {
		delegate?.didSelect(tvShow: tvShow)
	}

	func topRatedTVShowsCell(_ topRatedTVShowsCell: TopRatedTVShowsCell, didSelect movie: Movie) {
		delegate?.didSelect(movie: movie)
	}
}
