import Foundation

/// Tracked tv show model struct
struct TrackedTVShow: Codable, Hashable {
	let name: String
	let tvShow: TVShow
	let season: Season
	let episode: Episode
	let lastSeen: String

	var rating: Double?
	var imageURL: URL?
	var isFinished = false
	var isReturningSeries = false

	func hash(into hasher: inout Hasher) {
		hasher.combine(episode.id)
	}

	static func == (lhs: TrackedTVShow, rhs: TrackedTVShow) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
