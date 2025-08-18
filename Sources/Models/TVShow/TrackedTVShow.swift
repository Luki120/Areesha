import Foundation

/// Tracked tv show model struct
struct TrackedTVShow: Codable, Hashable {
	let name: String
	let tvShow: TVShow
	let season: Season
	let episode: Episode
	let imageURL: URL?
	let lastSeen: String

	var isReturningSeries = false

	func hash(into hasher: inout Hasher) {
		hasher.combine(episode.id)
	}

	static func == (lhs: TrackedTVShow, rhs: TrackedTVShow) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
