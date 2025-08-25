import UIKit

/// Class to represent the tv show cell
class TVShowCell: UICollectionViewCell {
	class var identifier: String {
		return String(describing: self)
	}

	@UsesAutoLayout
	private var tvShowImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 2
		imageView.transform = .init(scaleX: 0.1, y: 0.1)
		return imageView
	}()

	private lazy var spinnerView = createSpinnerView(withStyle: .medium, childOf: contentView) 
	private var imageTask: Task<Void, Error>?

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		spinnerView.startAnimating()
		tvShowImageView.image = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		contentView.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		contentView.layer.shadowColor = UIColor.label.cgColor
		contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
		contentView.layer.shadowOpacity = 0.2
		contentView.layer.shadowRadius = 2
		contentView.addSubview(tvShowImageView)

		spinnerView.startAnimating()
		layoutUI()
	}

	private func layoutUI() {
		contentView.pinViewToAllEdges(tvShowImageView)
		tvShowImageView.centerViewOnBothAxes(spinnerView)
		setupSizeConstraints(forView: spinnerView, width: 100, height: 100)
	}
}

// ! Public

extension TVShowCell {
	/// Function to configure the cell with its respective view model
	/// - Parameter viewModel: The cell's view model
	final func configure<V: ImageFetching>(with viewModel: V) {
		imageTask?.cancel()
		imageTask = Task {
			let image = try await viewModel.fetchImage()
			guard !Task.isCancelled else { return }

			await MainActor.run {
				UIView.transition(with: self.tvShowImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowImageView.alpha = 1
					self.tvShowImageView.image = image
					self.tvShowImageView.transform = .init(scaleX: 1, y: 1)
				}
				self.spinnerView.stopAnimating()
			}
		}
	}
}
