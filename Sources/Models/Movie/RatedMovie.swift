import Foundation

/// Rated movie result model struct
struct RatedMovieResult: Codable {
	let results: [RatedMovie]
	let totalPages: Int

	enum CodingKeys: String, CodingKey {
		case results
		case totalPages = "total_pages"
	}
}

/// Rated movie model struct
struct RatedMovie: Codable, Hashable {
	let id: Int
	let rating: Double
	let coverImage: String

	var movie: Movie?

	enum CodingKeys: String, CodingKey {
		case id
		case rating
		case coverImage = "poster_path"
	}
}
