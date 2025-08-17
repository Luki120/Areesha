import Foundation

/// Rated tv show model struct
struct RatedTVShowResult: Codable {
	let results: [RatedTVShow]
	let totalPages: Int

	enum CodingKeys: String, CodingKey {
		case results
		case totalPages = "total_pages"
	}
}

struct RatedTVShow: Codable {
	let id: Int
	let rating: Double
}
