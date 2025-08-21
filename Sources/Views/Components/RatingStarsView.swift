import UIKit

/// Class to represent the rating stars view
final class RatingStarsView: UIView {
	let starImagesStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.spacing = 0.5
		stackView.alignment = .leading
		stackView.distribution = .fillEqually
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(starImagesStackView)
		pinViewToAllEdges(starImagesStackView)
	}

	// ! Private

	private func createStarImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.tintColor = .systemYellow
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}
}

// ! Public

extension RatingStarsView {
	/// Function to update the stars for a given rating
	/// - Parameters:
	///		- rating: A `Double` that represents the rating
	///		- size: A `Double` that represents the star image size, defaults to 10
	func updateStars(for rating: Double, size: Double = 10) {
		starImagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		let rating = rating / 2
		let fullStars = Int(floor(rating))
		let isHalfStar = (rating - Double(fullStars)) >= 0.5

		for index in 0..<5 {
			let starImageView = createStarImageView()

			UIView.transition(with: starImageView, duration: 0.5, options: .transitionCrossDissolve) {
				if index < fullStars {
					starImageView.image = UIImage(systemName: "star.fill")
				}
				else if index == fullStars && isHalfStar {
					starImageView.image = UIImage(systemName: "star.leadinghalf.fill")
				}
				else {
					starImageView.image = nil
				}
			}
			starImagesStackView.addArrangedSubview(starImageView)
			starImagesStackView.setupSizeConstraints(forView: starImageView, width: size, height: size)
		}
	}
}
