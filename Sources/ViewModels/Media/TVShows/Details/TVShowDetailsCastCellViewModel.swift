import Foundation

/// View model struct for `TVShowDetailsCastCell`
struct TVShowDetailsCastCellViewModel: Hashable {
	let cast: String?

	/// Designated initializer
	/// - Parameter cast: A nullable `String` to represent the cast
	init(cast: String? = nil) {
		self.cast = cast
	}
}
