import Foundation

/// API model struct
struct APIResponse: Codable {
	let results: [TVShow]
}

struct TVShow: Codable {
	let id: Int
	let name: String
	let overview: String
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
	let number: Int?
	let episodes: [Episode]?
	let posterPath: String?

	enum CodingKeys: String, CodingKey {
		case name
		case number = "season_number"
		case episodes
		case posterPath = "poster_path"
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
	let stillPath: String?

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case number = "episode_number"
		case airDate = "air_date"
		case duration = "runtime"
		case description = "overview"
		case seasonNumber = "season_number"
		case stillPath = "still_path"
	}
}
