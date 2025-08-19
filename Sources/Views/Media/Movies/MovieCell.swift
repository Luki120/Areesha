import struct Swift.String

/// Class to represent the movie cell
final class MovieCell: TVShowCell {
	override
	class var identifier: String {
		return String(describing: self)
	}
}
