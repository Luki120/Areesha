import Foundation

/// Tracked tv show model struct
struct TrackedTVShow: Codable, Hashable {
	let imageURL: URL?
	let tvShowNameText: String
	let lastSeenText: String
}
