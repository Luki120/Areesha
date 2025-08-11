import UIKit

/// `UITableViewCell` subclass to show the movie's watch providers
final class MovieDetailsProvidersCell: TVShowDetailsProvidersCell {
	override
	class var identifier: String {
		return String(describing: self)
	}
}
