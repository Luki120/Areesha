import Foundation

/// View model struct for `MediaDetailsCastCell`
@MainActor
struct MediaDetailsCastCellViewModel {
	let cast: String?

	/// Designated initializer
	/// - Parameter cast: A nullable `String` to represent the cast
	init(cast: String? = nil) {
		self.cast = cast
	}	
}

nonisolated extension MediaDetailsCastCellViewModel: Hashable {}
