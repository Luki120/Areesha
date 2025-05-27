import UIKit


protocol TVShowHostViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
}

/// View model class for `TVShowHostView`
final class TVShowHostViewViewModel: NSObject {
	weak var delegate: TVShowHostViewViewModelDelegate?
}

// ! UICollectionViewDataSource

extension TVShowHostViewViewModel: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 2
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch indexPath.item {
			case 0:
				let cell: TopRatedTVShowsCell = collectionView.dequeueReusableCell(for: indexPath)
				cell.delegate = self
				return cell

			case 1:
				let cell: TrendingTVShowsCell = collectionView.dequeueReusableCell(for: indexPath)
				cell.delegate = self
				return cell

			default: return UICollectionViewCell()
		}
	}
}

// ! TopRatedTVShowsCellDelegate

extension TVShowHostViewViewModel: TopRatedTVShowsCellDelegate {
	func topRatedTVShowsCell(_ topRatedTVShowsCell: TopRatedTVShowsCell,didSelect tvShow: TVShow) {
		delegate?.didSelect(tvShow: tvShow)
	}
}
