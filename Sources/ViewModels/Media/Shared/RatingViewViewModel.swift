import Combine
import Foundation
import UIKit.UIImage

/// View model class for `RatingView`
final class RatingViewViewModel: NSObject {
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

	let object: ObjectType
	private let posterPath: String

	/// Designated initializer
	/// - Parameters:
	///		- object: The `ObjectType` model
	///		- posterPath: A `String` that represents the object's poster path
	init(object: ObjectType, posterPath: String) {
		self.object = object
		self.posterPath = posterPath
		super.init()

		for _ in 1...5 {
			viewModels.append(.init())
		}
	}
}

// ! Public

extension RatingViewViewModel {
	/// Function to add a rating for a given tv show or movie
	/// - Parameters:
	///		- isDecimal: A `Bool` to check wether the rating includes decimals, defaults to `false`
	///		- completion: `@escaping` closure that takes no arguments & returns nothing
	func addRating(isDecimal: Bool = false, completion: @escaping () -> Void) {
		let rating = isDecimal ? currentRating.round(to: 1) : currentRating * 2

		Service.sharedInstance.addRating(for: object, rating: rating)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { _ in
				completion()
			}
			.store(in: &subscriptions)
	}

	/// Function to fetch the object's poster image in different sizes
	/// - Parameter completion: `@escaping` closure that takes an array of `UIImage` objects as argument & returns nothing
	func fetchImages(completion: @escaping ([UIImage]) async -> ()) {
		Task(priority: .background) {
			guard let imageURL = Service.imageURL(.mediaPoster(posterPath), size: "w1280"),
				let backgroundImage = try? await ImageManager.sharedInstance.fetchImage(imageURL) else { return }

			guard let imageURL = Service.imageURL(.mediaPoster(posterPath)),
				let posterImage = try? await ImageManager.sharedInstance.fetchImage(imageURL) else { return }

			await completion([backgroundImage, posterImage])
		}
	}

	/// Function to set the current rating
	/// Parameter rating: A `Double` that represents the rating
	func setRating(_ rating: Double) {
		currentRating = rating
	}
}

// ! UICollectionView

extension RatingViewViewModel: UICollectionViewDelegate {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
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
		applySnapshot()
	}

	private func applySnapshot() {
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
		applySnapshot()
	}
}
