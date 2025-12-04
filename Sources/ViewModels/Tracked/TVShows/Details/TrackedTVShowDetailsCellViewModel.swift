import Foundation

/// View model struct for `TrackedTVShowDetailsCell`
@MainActor
struct TrackedTVShowDetailsCellViewModel {
	let episodeNumber: Int
	let episodeAirDate: String
}

nonisolated extension TrackedTVShowDetailsCellViewModel: Hashable {}
