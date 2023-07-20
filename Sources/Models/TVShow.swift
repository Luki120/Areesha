import Foundation

/// API model struct
struct APIResponse: Codable {
	let results: [TVShow]
}

struct TVShow: Codable {
	let id: Int
	let name: String
	let overview: String?
	let posterPath: String?
	let backdropPath: String?
	let episodeRunTime: [Int]?
	let genres: [Genre]?
	let lastAirDate: String?
	let networks: [Network]?
	let seasons: [Season]?
	let status: String?
	let voteAverage: Double?

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case overview
		case posterPath = "poster_path"
		case backdropPath = "backdrop_path"
		case episodeRunTime = "episode_run_time"
		case genres
		case lastAirDate = "last_air_date"
		case networks
		case seasons
		case status
		case voteAverage = "vote_average"
	}
}

struct Genre: Codable {
	let name: String
}

struct Network: Codable {
	let name: String
}

struct Season: Codable {
	let name: String?
	let posterPath: String?
	let episodes: [Episode]?
	let seasonNumber: Int?

	enum CodingKeys: String, CodingKey {
		case name
		case posterPath = "poster_path"
		case episodes
		case seasonNumber = "season_number"
	}
}

struct Episode: Codable {
	let id: Int
	let airDate: String?
	let episodeNumber: Int?
	let name: String?
	let overview: String?
	let runtime: Int?
	let stillPath: String?

	enum CodingKeys: String, CodingKey {
		case id
		case airDate = "air_date"
		case episodeNumber = "episode_number"
		case name
		case overview
		case runtime
		case stillPath = "still_path"
	}
}
