import Foundation

/// View model struct for `TVShowDetailsGenreCell`
struct TVShowDetailsGenreCellViewModel: Hashable {
	let genre: String?
	let episodeAverageDuration: String?
	let lastAirDate: String?
	let status: String?

	/// Designated initializer
	/// - Parameters:
	///		- genre: A nullable string to represent the genre
	///		- episodeAverageDuration: A nullable string to represent the episode average duration
	///		- lastAirDate: A nullable string to represent the last air date
	///		- status: A nullable string to represent the status
	init(
		genre: String? = nil,
		episodeAverageDuration: String? = nil,
		lastAirDate: String? = nil,
		status: String? = nil
	) {
		self.genre = genre
		self.episodeAverageDuration = episodeAverageDuration
		self.lastAirDate = lastAirDate
		self.status = status
	}
}
