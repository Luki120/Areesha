import UIKit

/// Class to represent the tv show cell
final class ARTVShowCollectionViewCell: UICollectionViewCell, Configurable {

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

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		contentView.pinViewToAllEdges(tvShowImageView)
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		tvShowImageView.image = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		contentView.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		contentView.layer.shadowColor = UIColor.label.cgColor
		contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
		contentView.layer.shadowOpacity = 0.5
		contentView.layer.shadowRadius = 4

		contentView.addSubview(tvShowImageView)
	}

}

extension ARTVShowCollectionViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: ARTVShowCollectionViewCellViewModel) {
		Task.detached(priority: .background) {
			let image = try? await viewModel.fetchTVShowImage()
			await MainActor.run {
				UIView.transition(with: self.tvShowImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowImageView.alpha = 1
					self.tvShowImageView.image = image
					self.tvShowImageView.transform = .init(scaleX: 1, y: 1)
				}
			}
		}
	}

}
