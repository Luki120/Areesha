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
	let name: String
	let backgroundCoverImage: String

	var rating: Double
	var tvShow: TVShow?

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case rating
		case backgroundCoverImage = "backdrop_path"
	}	
}
