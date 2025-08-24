import Combine
import UIKit

@MainActor
protocol SeasonsViewViewModelDelegate: AnyObject {
	func didLoadTVShowSeasons()
	func didSelect(season: Season, from tvShow: TVShow)
	func shouldAnimateNoSeasonsLabel(isDataSourceEmpty: Bool)
}

/// View model class for `SeasonsView`
@MainActor
final class SeasonsViewViewModel: NSObject {
	var title: String { return tvShow.name }

	private var subscriptions = Set<AnyCancellable>()
	private var viewModels = OrderedSet<SeasonCellViewModel>()

	private var seasons = [Season]() {
		didSet {
			viewModels += seasons.compactMap { season in
				let url = Service.imageURL(for: season, type: .poster)
				return SeasonCellViewModel(imageURL: url, seasonName: season.name ?? "")
			}
		}
	}

	weak var delegate: SeasonsViewViewModelDelegate?

	private let tvShow: TVShow

	/// Designated initializer
	/// - Parameter tvShow: The `TVShow` model object
	init(tvShow: TVShow) {
		self.tvShow = tvShow
		super.init()

		Task {
			await Service.sharedInstance.fetchDetails(for: tvShow.id, expecting: TVShow.self)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { _ in }) { [weak self] tvShow, _ in
					guard let self else { return }
					guard let seasons = tvShow.seasons else { return }
					self.seasons = seasons.filter { $0[keyPath: \.name!].contains("Specials") == false }

					delegate?.didLoadTVShowSeasons()
					delegate?.shouldAnimateNoSeasonsLabel(isDataSourceEmpty: viewModels.isEmpty)
				}
				.store(in: &subscriptions)
		}
	}
}

// ! UICollectionView

extension SeasonsViewViewModel: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModels.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell: SeasonCell = collectionView.dequeueReusableCell(for: indexPath)
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
