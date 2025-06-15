import UIKit

/// Class to represent the tracked tv show details description cell
final class TrackedTVShowDetailsDescriptionCell: TVShowDetailsBaseCell {
	static let identifier = "TrackedTVShowDetailsDescriptionCell"

	@UsesAutoLayout
	private var descriptionLabel: UILabel = {
		let label = UILabel()
		label.textColor = .label
		label.numberOfLines = 0
		return label
	}()

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		descriptionLabel.text = nil
	}

	override func setupUI() {
		contentView.addSubview(descriptionLabel)
		super.setupUI()
	}

	override func layoutUI() {
		contentView.pinViewToAllEdges(
			descriptionLabel,
			topConstant: 20,
			bottomConstant: -20,
			leadingConstant: 20,
			trailingConstant: -20
		)
	}
}

extension TrackedTVShowDetailsDescriptionCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: TrackedTVShowDetailsDescriptionCellViewModel) {
		descriptionLabel.text = viewModel.description
	}
}
