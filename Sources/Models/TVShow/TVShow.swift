import Foundation

/// API model struct
struct APIResponse: Codable {
	let results: [TVShow]
}

struct TVShow: Codable {
	let id: Int
	let name: String
	let coverImage: String?
	let description: String
	let backgroundCoverImage: String?
	let episodeAverageDurations: [Int]?
	let genres: [Genre]?
	let lastAirDate: String?
	let seasons: [Season]?
	let status: String?
	let voteAverage: Double?
	let nextEpisodeToAir: Episode?

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case coverImage = "poster_path"
		case description = "overview"
		case backgroundCoverImage = "backdrop_path"
		case episodeAverageDurations = "episode_run_time"
		case genres
		case lastAirDate = "last_air_date"
		case seasons
		case status
		case voteAverage = "vote_average"
		case nextEpisodeToAir = "next_episode_to_air"
	}
}

struct Genre: Codable {
	let name: String
}

struct Season: Codable {
	let name: String?
	let number: Int?
	let episodes: [Episode]?
	let coverImage: String?

	enum CodingKeys: String, CodingKey {
		case name
		case number = "season_number"
		case episodes
		case coverImage = "poster_path"
	}
}

struct Episode: Codable {
	let id: Int
	let name: String?
	let number: Int?
	let airDate: String?
	let duration: Int?
	let description: String?
	let seasonNumber: Int?
	let coverImage: String?

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case number = "episode_number"
		case airDate = "air_date"
		case duration = "runtime"
		case description = "overview"
		case seasonNumber = "season_number"
		case coverImage = "still_path"
	}
}
