import UIKit

/// `UITableViewCell` subclass to show the movie's description
final class MovieDetailsDescriptionCell: TVShowDetailsDescriptionCell {
	override
	class var identifier: String {
		return String(describing: self)
	}

	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: MovieDetailsDescriptionCellViewModel) {
		descriptionLabel.text = viewModel.description.isEmpty ? "No description available" : viewModel.description
	}
}
