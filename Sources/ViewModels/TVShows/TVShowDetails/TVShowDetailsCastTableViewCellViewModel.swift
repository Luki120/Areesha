import Foundation

/// View model struct for TVShowDetailsCastTableViewCell
struct TVShowDetailsCastTableViewCellViewModel: Hashable {

	private let castText: String?
	private let castCrewText: String?

	var displayCastText: String { return castText ?? "" }
	var displayCastCrewText: String { return castCrewText ?? "" }

	/// Designated initializer
	/// - Parameters:
	///     - castText: a nullable string to represent the cast text
	///		- castCrewText: a nullable string to represent the cast crew text
	init(castText: String? = nil, castCrewText: String? = nil) {
		self.castText = castText
		self.castCrewText = castCrewText
	}

}
