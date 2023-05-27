import UIKit

/// Class to represent the tracked tv show collection view cell
final class TrackedTVShowCollectionViewCell: UICollectionViewCell {

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	}

}

extension TrackedTVShowCollectionViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: TrackedTVShowCollectionViewCell) {}

}
