import Combine
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
	private var starImagesStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.spacing = 0.5
		stackView.alignment = .leading
		stackView.distribution = .fillEqually
		return stackView
	}()

	private var subscriptions = Set<AnyCancellable>()
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

		starImagesStackView.subviews.forEach {
			let imageView = $0 as? UIImageView
			imageView?.image = nil
		}
	}

	// ! Lifecycle

	private func setupUI() {
		contentView.addSubviews(posterImageView, starImagesStackView)
		layoutUI()
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			starImagesStackView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 5),
			starImagesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
			starImagesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			starImagesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
		])
	}

	private func updateStars(for rating: Double) {
		starImagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		let rating = rating / 2
		let fullStars = Int(rating)
		let isHalfStar = (rating - Double(fullStars)) >= 0.25

		for index in 0..<5 {
			let starImageView = UIImageView()
			starImageView.tintColor = .systemYellow
			starImageView.contentMode = .scaleAspectFit
			starImageView.clipsToBounds = true
			starImageView.translatesAutoresizingMaskIntoConstraints = false

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
			starImagesStackView.setupSizeConstraints(forView: starImageView, width: 10, height: 10)
		}
	}
}

// ! Configurable

extension RatedMovieCell: Configurable {
	func configure(with viewModel: RatedMovieCellViewModel) {
		activeViewModel = viewModel

		viewModel.$rating
			.sink { [weak self] rating in
				self?.updateStars(for: rating)
			}
			.store(in: &subscriptions)

		Task {
			guard let (image, isFromNetwork) = try? await viewModel.fetchImage() else { return }

			await MainActor.run {
				guard self.activeViewModel == viewModel else { return }

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
