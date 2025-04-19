import Foundation

/// Tracked tv show model struct
struct TrackedTVShow: Codable, Hashable {
	let tvShow: TVShow
	let imageURL: URL?
	let name: String
	let lastSeen: String
	let episode: Episode
	let episodeID: Int

	var isFinished = false
	var isReturningSeries = false

	func hash(into hasher: inout Hasher) {
		hasher.combine(episodeID)
	}

	static func == (lhs: TrackedTVShow, rhs: TrackedTVShow) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

}
