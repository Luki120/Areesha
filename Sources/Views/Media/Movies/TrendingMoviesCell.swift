import UIKit

/// Class to represent the trending movies cell
final class TrendingMoviesCell: TopRatedTVShowsCell {
	override func setupViewModel(_ viewModel: TVShowListViewViewModel) {
		viewModel.fetchTrendingMovies()
	}
}
