import UIKit

/// `UITableViewCell` subclass that'll show the movie's cast
final class MovieDetailsCastCell: TVShowDetailsCastCell {
	override
	class var identifier: String {
		return String(describing: self)
	}

	/// Function to configure the cell with its respective view model
	/// - Parameter viewModel: The cell's view model
	func configure(with viewModel: MovieDetailsCastCellViewModel) {
		castLabel.text = viewModel.cast.isEmpty ? "Cast unknown" : viewModel.cast
	}
}
