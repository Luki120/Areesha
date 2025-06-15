import Combine
import Foundation
import UIKit.UIImage

/// View model class for `TVShowRatingView`
final class TVShowRatingViewViewModel: NSObject {
	private var viewModels = [RatingCellViewModel]()
	private var subscriptions = Set<AnyCancellable>()
	private var currentRating: Double = 0

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<RatingCell, RatingCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, RatingCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RatingCellViewModel>

	private var dataSource: DataSource!

	private enum Section {
		case main
	}

	let tvShow: TVShow

	/// Designated initializer
	/// - Parameter tvShow: The tv show model object
	init(tvShow: TVShow) {
		self.tvShow = tvShow
		super.init()

		for _ in 1...5 {
			viewModels.append(.init())
		}
	}
}

// ! Public

extension TVShowRatingViewViewModel {
	/// Function to add a rating for a given TV show
	/// - Parameter completion: `@escaping` closure that takes no arguments & returns nothing
	func addRating(completion: @escaping () -> Void) {
		Service.sharedInstance.addRating(for: tvShow, rating: currentRating * 2)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { _ in 
				completion()
			}
			.store(in: &subscriptions)
	}

	/// Function to fetch the tv show's poster image in different sizes
	/// - Parameter completion: `@escaping` closure that takes an array of `UIImage` objects as argument & returns nothing
	func fetchTVShowImages(completion: @escaping ([UIImage]) async -> ()) {
		Task.detached(priority: .background) {
			guard let imageURL = Service.imageURL(.showPoster(self.tvShow), size: "w1280"),
				let backgroundImage = try? await ImageManager.sharedInstance.fetchImage(imageURL) else { return }

			guard let imageURL = Service.imageURL(.showPoster(self.tvShow)),
				let posterImage = try? await ImageManager.sharedInstance.fetchImage(imageURL) else { return }

			await completion([backgroundImage, posterImage])
		}
	}
}

// ! UICollectionView

extension TVShowRatingViewViewModel: UICollectionViewDelegate {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The collection view
	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.configure(with: viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(viewModels)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		let fullRating = Double(indexPath.item + 1)
		let halfRating = Double(indexPath.item) + 0.5

		currentRating = currentRating == fullRating ? halfRating : fullRating
		updateStarImage()
	}

	private func updateStarImage() {
		for (index, _) in viewModels.enumerated() {
			let starPosition = Double(index + 1)

			if currentRating >= starPosition {
				viewModels[index].image = "star.fill"
			}
			else if currentRating >= starPosition - 0.5 {
				viewModels[index].image = "star.leadinghalf.fill"
			}
			else {
				viewModels[index].image = "star"
			}
		}
		applyDiffableDataSourceSnapshot()
	}
}
