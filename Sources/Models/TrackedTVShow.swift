import Foundation

/// Tracked tv show model struct
struct TrackedTVShow: Codable, Hashable {
	let imageURL: URL?
	let tvShowNameText: String
	let lastSeenText: String
	let episodeID: Int

	func hash(into hasher: inout Hasher) {
		hasher.combine(episodeID)
	}	

	static func == (lhs: TrackedTVShow, rhs: TrackedTVShow) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

}
