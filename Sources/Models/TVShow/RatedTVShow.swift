import Foundation

/// Rated tv show model struct
struct RatedTVShowResult: Codable {
	let results: [RatedTVShow]
}

struct RatedTVShow: Codable {
	let id: Int
	let rating: Double
}
