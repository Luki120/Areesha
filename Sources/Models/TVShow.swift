import Foundation

/// API model struct
struct APIResponse: Codable {
	let results: [TVShow]
}

struct TVShow: Codable {
	let id: Int
	let name: String
	let overview: String?
	let poster_path: String?
	let backdrop_path: String?
	let episode_run_time: [Int]?
	let genres: [Genres]?
	let last_air_date: String?
	let networks: [Networks]?
	let status: String?
}

struct Genres: Codable {
	let name: String
}

struct Networks: Codable {
	let name: String
}
