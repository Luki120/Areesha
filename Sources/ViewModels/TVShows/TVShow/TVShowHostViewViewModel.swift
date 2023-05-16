import UIKit


protocol TVShowHostViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
}

/// View model class for TVShowHostView
final class TVShowHostViewViewModel: NSObject {

	var topHeaderView: TopHeaderView!
	weak var delegate: TVShowHostViewViewModelDelegate?
	private var collectionView: UICollectionView!

	/// Function to scroll the tv shows list collection view to the top when tapping a tab bar item
	func scrollToTop() {
		// credits ⇝ https://stackoverflow.com/a/56380938
		var visibleCells: [UICollectionViewCell] {
			return collectionView.visibleCells.filter { cell in
				let cellRect = collectionView.convert(cell.frame, to: collectionView.superview)
				return collectionView.frame.contains(cellRect)
			}
		}
		visibleCells.forEach {
			let cell = $0 as? TopRatedTVShowsCollectionViewCell
			cell?.collectionView.setContentOffset(
				CGPoint(x: 0, y: -(cell?.collectionView.safeAreaInsets.top ?? 0)),
				animated: true
			)
		}
	}

}

// ! UICollectionView

extension TVShowHostViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 2
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		self.collectionView = collectionView
		switch indexPath.item {
			case 0:
				guard let cell = collectionView.dequeueReusableCell(
					withReuseIdentifier: TopRatedTVShowsCollectionViewCell.identifier,
					for: indexPath
				) as? TopRatedTVShowsCollectionViewCell else {
					return UICollectionViewCell()
				}
				cell.delegate = self
				return cell

			case 1:
				guard let cell = collectionView.dequeueReusableCell(
					withReuseIdentifier: TrendingTVShowsCollectionViewCell.identifier,
					for: indexPath
				) as? TrendingTVShowsCollectionViewCell else {
					return UICollectionViewCell()
				}
				cell.delegate = self
				return cell

			default: return UICollectionViewCell()
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		topHeaderView.transparentViewLeadingAnchorConstraint.constant = scrollView.contentOffset.x / 2
	}

	func scrollViewWillEndDragging(
		_ scrollView: UIScrollView,
		withVelocity velocity: CGPoint,
		targetContentOffset: UnsafeMutablePointer<CGPoint>
	) {
		let index = targetContentOffset.pointee.x / topHeaderView.frame.width
		let indexPath = IndexPath(item: Int(index), section: 0)
		topHeaderView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
	}

}

// ! TopRatedTVShowsCollectionViewCellDelegate

extension TVShowHostViewViewModel: TopRatedTVShowsCollectionViewCellDelegate {

	func topRatedTVShowsCollectionViewCell(
		_ topRatedTVShowsCollectionViewCell: TopRatedTVShowsCollectionViewCell,
		didSelect tvShow: TVShow
	) {
		delegate?.didSelect(tvShow: tvShow)
	}

}
