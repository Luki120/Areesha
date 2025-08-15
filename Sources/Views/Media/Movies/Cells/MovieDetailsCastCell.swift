import UIKit

/// `UITableViewCell` subclass that'll show the movie's cast
final class MovieDetailsCastCell: MediaDetailsCastCell {
	override
	class var identifier: String {
		return String(describing: self)
	}
}
