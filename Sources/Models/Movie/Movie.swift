import Foundation

/// Movie response model struct
struct MovieResponse: Codable {
	let results: [Movie]
}

/// Movie model struct
struct Movie: Codable, Hashable, ImageRepresentable {
	let id: Int
	let title: String
	let budget: Int?
	let genres: [Genre]?
	let credits: Credits?
	let revenue: Int?
	let runtime: Double?
	let coverImage: String?
	let releaseDate: String?
	let description: String
	let voteAverage: Double?
	let backgroundCoverImage: String?

	enum CodingKeys: String, CodingKey {
		case id, title, budget, genres, credits, revenue, runtime
		case coverImage = "poster_path"
		case releaseDate = "release_date"
		case description = "overview"
		case voteAverage = "vote_average"
		case backgroundCoverImage = "backdrop_path"
	}

	// ! ImageRepresentable

	var posterPath: String? { coverImage }
	var backdropPath: String? { backgroundCoverImage }
}
