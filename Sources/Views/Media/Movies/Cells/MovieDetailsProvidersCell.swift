import UIKit

/// `UITableViewCell` subclass to show the movie's watch providers
final class MovieDetailsProvidersCell: MediaDetailsProvidersCell {
	override
	class var identifier: String {
		return String(describing: self)
	}
}
