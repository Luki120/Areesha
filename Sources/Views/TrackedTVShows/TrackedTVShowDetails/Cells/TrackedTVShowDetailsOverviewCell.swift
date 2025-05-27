import UIKit

/// Class to represent the tracked tv show details overview cell
final class TrackedTVShowDetailsOverviewCell: TVShowDetailsBaseCell {
	static let identifier = "TrackedTVShowDetailsOverviewCell"

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

extension TrackedTVShowDetailsOverviewCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: TrackedTVShowDetailsOverviewCellViewModel) {
		descriptionLabel.text = viewModel.description
	}
}
