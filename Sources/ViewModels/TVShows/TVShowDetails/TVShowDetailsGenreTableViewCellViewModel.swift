import Foundation

/// View model struct for TVShowDetailsGenreTableViewCell
struct TVShowDetailsGenreTableViewCellViewModel: Hashable {

	let genreText: String?
	let episodeAverageDurationText: String?
	let lastAirDateText: String?
	let statusText: String?

	/// Designated initializer
	/// - Parameters:
	///		- genreText: A nullable string to represent the genre text
	///		- episodeAverageDurationText: A nullable string to represent the episode average duration text
	///		- lastAirDateText: A nullable string to represent the last air date text
	///		- statusText: A nullable string to represent the status text
	init(
		genreText: String? = nil,
		episodeAverageDurationText: String? = nil,
		lastAirDateText: String? = nil,
		statusText: String? = nil
	) {
		self.genreText = genreText
		self.episodeAverageDurationText = episodeAverageDurationText
		self.lastAirDateText = lastAirDateText
		self.statusText = statusText
	}

}
