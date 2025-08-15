import Foundation

/// Movie model struct
struct Movie: Codable, Hashable {
	let id: Int
	let title: String
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
		case id
		case title
		case genres
		case credits
		case revenue
		case runtime
		case coverImage = "poster_path"
		case releaseDate = "release_date"
		case description = "overview"
		case voteAverage = "vote_average"
		case backgroundCoverImage = "backdrop_path"
	}
}
