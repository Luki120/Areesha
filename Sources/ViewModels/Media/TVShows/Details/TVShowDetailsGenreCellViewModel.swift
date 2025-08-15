import Foundation

/// View model struct for `TVShowDetailsGenreCell`
struct TVShowDetailsGenreCellViewModel: Hashable {
	let genre: String?
	let episodeAverageDuration: String?
	let lastAirDate: String?
	let status: String?
	let revenue: Int?

	/// Designated initializer
	/// - Parameters:
	///		- genre: A nullable `String` to represent the genre
	///		- episodeAverageDuration: A nullable `String` to represent the episode average duration
	///		- lastAirDate: A nullable `String` to represent the last air date
	///		- status: A nullable `String` to represent the status
	///		- revenue: A nullable `Int` to represent the revenue for movies
	init(
		genre: String? = nil,
		episodeAverageDuration: String? = nil,
		lastAirDate: String? = nil,
		status: String? = nil,
		revenue: Int? = nil
	) {
		self.genre = genre
		self.episodeAverageDuration = episodeAverageDuration
		self.lastAirDate = lastAirDate
		self.status = status
		self.revenue = revenue
	}
}
