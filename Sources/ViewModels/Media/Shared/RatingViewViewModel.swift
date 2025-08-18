import Combine
import Foundation
import UIKit.UIImage

/// View model class for `RatingView`
@MainActor
final class RatingViewViewModel: BaseViewModel<RatingCell> {
	private var subscriptions = Set<AnyCancellable>()
	private var currentRating: Double = 0

	let object: ObjectType
	private let posterPath: String
	private let backdropPath: String

	/// Designated initializer
	/// - Parameters:
	///		- object: The `ObjectType` model
	///		- posterPath: A `String` that represents the object's poster path
	///		- backdropPath: A `String` that represents the object's backdrop path
	init(object: ObjectType, posterPath: String, backdropPath: String) {
		self.object = object
		self.posterPath = posterPath
		self.backdropPath = backdropPath
		super.init()

		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}

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

		Task {
			await Service.sharedInstance.addRating(for: object, rating: rating)
				.catch { _ in Just(Data()) }
				.receive(on: DispatchQueue.main)
				.sink { [weak self] _ in
					completion()

					Task {
						let key = self?.object.type == .movie
							? Service.Constants.ratedMoviesURL
							: Service.Constants.ratedShowsURL

						await Service.sharedInstance.resetCache(for: key)
					}
				}
				.store(in: &subscriptions)
			}
	}

	/// Function to fetch the object's images in different sizes
	/// - Returns: `[UIImage]`
	nonisolated func fetchImages() async -> [UIImage] {
		guard let imageURL = Service.imageURL(.mediaPoster(backdropPath), size: "w1280"),
			let backgroundImage = try? await ImageActor.sharedInstance.fetchImage(imageURL) else { return [] }

		guard let imageURL = Service.imageURL(.mediaPoster(posterPath)),
			let posterImage = try? await ImageActor.sharedInstance.fetchImage(imageURL) else { return [] }

		return [backgroundImage, posterImage]
	}

	/// Function to set the current rating
	/// Parameter rating: A `Double` that represents the rating
	func setRating(_ rating: Double) {
		currentRating = rating
	}
}

// ! UICollectionView

extension RatingViewViewModel: UICollectionViewDelegate {
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
