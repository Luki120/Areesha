import Foundation

/// View model struct for `TVShowDetailsCastCell`
struct TVShowDetailsCastCellViewModel: Hashable {
	let castText: String?
	let castCrewText: String?

	/// Designated initializer
	/// - Parameters:
	///		- castText: A nullable string to represent the cast text
	///		- castCrewText: A nullable string to represent the cast crew text
	init(castText: String? = nil, castCrewText: String? = nil) {
		self.castText = castText
		self.castCrewText = castCrewText
	}
}
