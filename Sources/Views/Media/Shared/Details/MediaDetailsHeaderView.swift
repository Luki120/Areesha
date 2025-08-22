import UIKit
import CoreImage.CIFilterBuiltins

/// Class to represent the header image for the tv show details view
final class MediaDetailsHeaderView: BaseHeaderView {
	private let context = CIContext()
	private var ratingsLabel: UILabel!

	// ! Lifecycle

	override func setupUI() {
		super.setupUI()
		ratingsLabel = createLabel()
		containerView.addSubview(ratingsLabel)

		layoutUI()
	}

	override func layoutUI() {
		super.layoutUI()
		guard addRatingsLabel else { return }

		nameLabel.trailingAnchor.constraint(equalTo: ratingsLabel.leadingAnchor, constant: -10).isActive = true
		nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		ratingsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
		ratingsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true

		ratingsLabel.setContentHuggingPriority(.required, for: .horizontal)
		ratingsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
	}
}

// ! Public

extension MediaDetailsHeaderView {
	/// Function to configure the view with its respective view model
	/// - Parameter viewModel: The view's view model
	func configure(with viewModel: MediaDetailsHeaderViewViewModel) {
		nameLabel.text = viewModel.name ?? viewModel.episodeName
		ratingsLabel.text = viewModel.rating

		Task {
			let image = try await viewModel.fetchImage().blur(context: context)

			await MainActor.run {
				UIView.transition(with: self.headerImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.headerImageView.image = image
				}
				UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
					[self.nameLabel, self.ratingsLabel].forEach { $0.alpha = 1 }
				}
			}
		}
	}

	/// Function to animate the vc's title label
	/// - Parameters:
	///		- titleLabel: The `UILabel`
	///		- scrollView: The `UIScrollView`
	///		- scrollableHeight: A `CGFloat` that represents the minimum height needed for scrolling
	func animate(titleLabel: UILabel, in scrollView: UIScrollView, scrollableHeight: CGFloat) {
		let kScrollableHeight = scrollableHeight
		let scrolledEnough = scrollView.contentOffset.y > kScrollableHeight

		UIView.animate(withDuration: 0.35, delay: 0, options: scrolledEnough ? .curveEaseIn : .curveEaseOut) {
			titleLabel.alpha = scrolledEnough ? 1 : 0
			if scrolledEnough { titleLabel.isHidden = false }

			self.roundedBlurredButtons.forEach {
				$0.setupStyles(for: .header(status: scrolledEnough))
			}
		} completion: { isFinished in
			guard UIDevice.current.hasDynamicIsland else { return }

			if isFinished && !scrolledEnough {
				titleLabel.isHidden = true
			}
		}
	}
}

@MainActor
private extension UIImage {
	enum ProgressiveBlurPosition {
		case top, bottom

		var colors: [CIColor] {
			switch self {
				case .top: return [.clear, .white]
				case .bottom: return [.white, .clear]
			}
		}
	}

	/// Function that creates a `UIImage` with progressive blur
	/// - Parameters:
	///		- context: The `CIContext`
	///		- radius: A `Float` that represents the blur radius, defaults to 40
	/// - Returns: `UIImage`
	func blur(context: CIContext, radius: Float = 40) -> UIImage {
		guard let ciImage = CIImage(image: self) else { return .init() }

		let imageMask = createImageMask(for: ciImage, maskHeight: ciImage.extent.height, position: .bottom)
		let blurredImage = applyProgressiveBlur(to: ciImage, mask: imageMask, blurRadius: radius)

		guard let cgImage = context.createCGImage(blurredImage, from: blurredImage.extent) else { return .init() }
		return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)		
	}

	private func applyProgressiveBlur(to ciImage: CIImage, mask: CIImage, blurRadius: Float) -> CIImage {
		let clampedImage = ciImage.clampedToExtent()
		let filter = CIFilter.maskedVariableBlur()
		filter.mask = mask
		filter.radius = blurRadius
		filter.inputImage = clampedImage

		return filter.outputImage?.cropped(to: ciImage.extent) ?? .init()
	}

	private func createImageMask(
		for ciImage: CIImage,
		maskHeight: Double,
		position: ProgressiveBlurPosition
	) -> CIImage {
		let gradient = CIFilter.smoothLinearGradient()
		gradient.color0 = position.colors[0]
		gradient.color1 = position.colors[1]
		gradient.point0 = CGPoint(x: 0, y: 0)
		gradient.point1 = CGPoint(x: 0, y: maskHeight * 0.25)

		guard let gradientImage = gradient.outputImage else { return .init() }

		let featheredMaskImage = gradientImage.clampedToExtent()
		let gaussiarBlur = CIFilter.gaussianBlur()
		gaussiarBlur.radius = 85
		gaussiarBlur.inputImage = featheredMaskImage

		return gaussiarBlur.outputImage?.cropped(to: ciImage.extent) ?? .init()
	}
}
