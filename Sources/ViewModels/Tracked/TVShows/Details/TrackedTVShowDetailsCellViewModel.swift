import Foundation

/// View model struct for `TrackedTVShowDetailsCell`
@MainActor
struct TrackedTVShowDetailsCellViewModel: Hashable {
	let episodeNumber: Int
	let episodeAirDate: String
}
