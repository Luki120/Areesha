import Combine
import UIKit


protocol SeasonsViewViewModelDelegate: AnyObject {
	func didLoadTVShowSeasons()
	func didSelect(season: Season, from tvShow: TVShow)
}

/// View model class for SeasonsView
final class SeasonsViewViewModel: NSObject {

	var title: String { return tvShow.name }

	private var subscriptions = Set<AnyCancellable>()
	private var viewModels = OrderedSet<SeasonCollectionViewCellViewModel>()

	private var seasons = [Season]() {
		didSet {
			viewModels += seasons.compactMap { season in
				guard let url = Service.imageURL(.seasonPoster(season)),
					let seasonName = season.name else { return nil }
				return SeasonCollectionViewCellViewModel(imageURL: url, seasonNameText: seasonName)
			}
		}
	}

	weak var delegate: SeasonsViewViewModelDelegate?

	private let tvShow: TVShow

	/// Designated initializer
	/// - Parameters:
	///     - tvShow: The tv show model object
	init(tvShow: TVShow) {
		self.tvShow = tvShow
		super.init()
		fetchTVShowSeasons()
	}

	// ! Private

	private func fetchTVShowSeasons() {
		let urlString = "\(Service.Constants.baseURL)tv/\(tvShow.id)?\(Service.Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }	

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: TVShow.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] tvShow in
				guard let seasons = tvShow.seasons else { return }
				self?.seasons = seasons.filter { $0[keyPath: \.name!].contains("Specials") == false }
				self?.delegate?.didLoadTVShowSeasons()
			}
			.store(in: &subscriptions)
	}

}

// ! UICollectionView

extension SeasonsViewViewModel: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModels.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: SeasonCollectionViewCell.identifier,
			for: indexPath
		) as? SeasonCollectionViewCell else {
			return UICollectionViewCell()
		}
		cell.configure(with: viewModels[indexPath.item])
		return cell
	}

}

extension SeasonsViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(season: seasons[indexPath.item], from: tvShow)
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard let collectionView = scrollView as? UICollectionView else { return }
		collectionView.focusCenterItem(animated: true)
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard let collectionView = scrollView as? UICollectionView else { return }
		if !decelerate { // if decelerate, we'll handle in `scrollViewDidEndDecelerating`
			collectionView.focusCenterItem(animated: true)
		}
	}

}

private extension UICollectionView {

	func focusCenterItem(animated: Bool) {
		var contentCenter = contentOffset
		contentCenter.x += center.x
		contentCenter.y += center.y

		// try to get the cell in the center,
		// if there's not one then find the closest cell
		guard let indexPath = indexPathForItem(at: contentCenter) ?? {
			indexPathsForVisibleItems
				.compactMap { indexPath -> (indexPath: IndexPath, distance: Double)? in
					guard let cell = cellForItem(at: indexPath),
						  let cellSuperview = cell.superview else { return nil }
					let relative = convert(cell.center, from: cellSuperview)
					// distance from the center of the cell to the center of the scroll view
					return (indexPath, abs(relative.x - contentCenter.x))
				}
				.min { lhs, rhs in
					lhs.distance < rhs.distance
				}
				.map(\.indexPath)
		}() else { return }
		scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
	}

}
