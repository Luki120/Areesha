import UIKit

/// Class to represent the tracked tv show details description cell
final class TrackedTVShowDetailsDescriptionCell: TVShowDetailsDescriptionCell {
	override
	class var identifier: String {
		return "TrackedTVShowDetailsDescriptionCell"
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
