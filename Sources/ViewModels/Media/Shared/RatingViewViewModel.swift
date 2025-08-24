import Combine
import Foundation
import UIKit.UIImage

/// View model class for `RatingView`
@MainActor
final class RatingViewViewModel: BaseViewModel<RatingCell> {
	var title: String { (object.type == .movie ? object.title : object.name) ?? "" }

	private var subscriptions = Set<AnyCancellable>()
	private var currentRating: Double = 0

	let object: ObjectType

	/// Designated initializer
	/// - Parameter object: The `ObjectType` model
	init(object: ObjectType) {
		self.object = object
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
		let backgroundImageURL = Service.imageURL(for: object, type: .backdrop, size: "w1280")
		guard let backgroundImage = try? await ImageActor.sharedInstance.fetchImage(backgroundImageURL) else {
			return []
		}

		let coverImageURL = Service.imageURL(for: object, type: .poster)
		guard let posterImage = try? await ImageActor.sharedInstance.fetchImage(coverImageURL) else {
			return []
		}

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
