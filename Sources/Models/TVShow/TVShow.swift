import Foundation

/// TV show model struct
struct TVShow: Codable, ImageRepresentable {
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
		case id, name, genres, seasons, status
		case coverImage = "poster_path"
		case description = "overview"
		case backgroundCoverImage = "backdrop_path"
		case episodeAverageDurations = "episode_run_time"
		case lastAirDate = "last_air_date"
		case voteAverage = "vote_average"
		case nextEpisodeToAir = "next_episode_to_air"
	}

	// ! ImageRepresentable

	var posterPath: String? { coverImage }
	var backdropPath: String? { backgroundCoverImage }
}

/// Season model struct
struct Season: Codable, ImageRepresentable {
	let name: String?
	let number: Int?
	let episodes: [Episode]?
	let coverImage: String?

	enum CodingKeys: String, CodingKey {
		case name, episodes
		case number = "season_number"
		case coverImage = "poster_path"
	}

	// ! ImageRepresentable

	var posterPath: String? { coverImage }
}

/// Episode model struct
struct Episode: Codable, ImageRepresentable {
	let id: Int
	let name: String?
	let number: Int?
	let airDate: String?
	let duration: Int?
	let description: String?
	let seasonNumber: Int?
	let coverImage: String?

	enum CodingKeys: String, CodingKey {
		case id, name
		case number = "episode_number"
		case airDate = "air_date"
		case duration = "runtime"
		case description = "overview"
		case seasonNumber = "season_number"
		case coverImage = "still_path"
	}

	// ! ImageRepresentable

	var posterPath: String? { coverImage }
}
