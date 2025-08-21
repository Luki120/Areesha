import UIKit

/// Class to represent the rated movie cell
final class RatedMovieCell: UICollectionViewCell {
	@UsesAutoLayout
	private var posterImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 5
		return imageView
	}()

	@UsesAutoLayout
	private var ratingStarsView = RatingStarsView()

	private var activeViewModel: RatedMovieCellViewModel!

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		posterImageView.image = nil

		ratingStarsView.starImagesStackView.arrangedSubviews.forEach {
			let imageView = $0 as? UIImageView
			imageView?.image = nil
		}
	}

	// ! Lifecycle

	private func setupUI() {
		contentView.addSubviews(posterImageView, ratingStarsView)
		layoutUI()
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			ratingStarsView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 5),
			ratingStarsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
			ratingStarsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			ratingStarsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
		])
	}
}

// ! Configurable

extension RatedMovieCell: Configurable {
	func configure(with viewModel: RatedMovieCellViewModel) {
		activeViewModel = viewModel
		ratingStarsView.updateStars(for: viewModel.rating)

		Task {
			let (image, isFromNetwork) = try await viewModel.fetchImage()
			guard self.activeViewModel == viewModel else { return }

			await MainActor.run {
				if isFromNetwork {
					UIView.transition(with: self.posterImageView, duration: 0.5, options: .transitionCrossDissolve) {
						self.posterImageView.image = image
					}
				}
				else {
					self.posterImageView.image = image
				}
			}
		}
	}
}
