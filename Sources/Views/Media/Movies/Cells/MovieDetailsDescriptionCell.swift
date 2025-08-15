import UIKit

/// `UITableViewCell` subclass to show the movie's description
final class MovieDetailsDescriptionCell: TVShowDetailsDescriptionCell {
	override
	class var identifier: String {
		return String(describing: self)
	}
}
