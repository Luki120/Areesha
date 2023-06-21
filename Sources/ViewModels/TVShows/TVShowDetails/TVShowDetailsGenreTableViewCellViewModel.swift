import Foundation

/// View model struct for TVShowDetailsGenreTableViewCell
struct TVShowDetailsGenreTableViewCellViewModel: Hashable {

	let genreText: String?
	let episodeAverageDurationText: String?
	let lastAirDateText: String?
	let statusText: String?
	let voteAverageText: String?

	/// Designated initializer
	/// - Parameters:
	///     - genreText: A nullable string to represent the genre text
	///		- episodeAverageDurationText: A nullable string to represent the episode average duration text
	///     - lastAirDateText: A nullable string to represent the last air date text
	///		- statusText: A nullable string to represent the status text
	///		- voteAverageText: A nullable string to represent the vote average text
	init(
		genreText: String? = nil,
		episodeAverageDurationText: String? = nil,
		lastAirDateText: String? = nil,
		statusText: String? = nil,
		voteAverageText: String? = nil
	) {
		self.genreText = genreText
		self.episodeAverageDurationText = episodeAverageDurationText
		self.lastAirDateText = lastAirDateText
		self.statusText = statusText
		self.voteAverageText = voteAverageText
	}

}
