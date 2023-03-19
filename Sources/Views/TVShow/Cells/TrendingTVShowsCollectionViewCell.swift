import UIKit

/// Class to represent the trending tv shows collection view cell
final class TrendingTVShowsCollectionViewCell: TopRatedTVShowsCollectionViewCell {

	override func setupViewModel(_ viewModel: TVShowListViewViewModel) {
		viewModel.fetchTrendingTVShows()
	}

}
