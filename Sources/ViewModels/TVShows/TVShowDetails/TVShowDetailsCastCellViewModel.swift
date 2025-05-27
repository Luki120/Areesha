import Foundation

/// View model struct for `TVShowDetailsCastCell`
struct TVShowDetailsCastCellViewModel: Hashable {
	let cast: String?
	let castCrew: String?

	/// Designated initializer
	/// - Parameters:
	///		- cast: A nullable string to represent the cast
	///		- castCrew: A nullable string to represent the cast crew
	init(cast: String? = nil, castCrew: String? = nil) {
		self.cast = cast
		self.castCrew = castCrew
	}
}
