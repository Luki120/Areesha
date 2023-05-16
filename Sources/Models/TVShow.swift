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
	let genres: [Genres]?
	let lastAirDate: String?
	let networks: [Networks]?
	let seasons: [Seasons]?
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

struct Genres: Codable {
	let name: String
}

struct Networks: Codable {
	let name: String
}

struct Seasons: Codable {
	let name: String?
	let posterPath: String?

	enum CodingKeys: String, CodingKey {
		case name
		case posterPath = "poster_path"
	}
}
