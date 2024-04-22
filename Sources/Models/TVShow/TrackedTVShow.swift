import Foundation

/// Tracked tv show model struct
struct TrackedTVShow: Codable, Hashable {
	let tvShow: TVShow
	let imageURL: URL?
	let tvShowNameText: String
	let lastSeenText: String
	let episode: Episode
	let episodeID: Int

	var isFinished = false

	func hash(into hasher: inout Hasher) {
		hasher.combine(episodeID)
	}

	static func == (lhs: TrackedTVShow, rhs: TrackedTVShow) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

}
