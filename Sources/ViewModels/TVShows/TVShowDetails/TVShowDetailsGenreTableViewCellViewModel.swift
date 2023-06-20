import Foundation

/// View model struct for TVShowDetailsGenreTableViewCell
struct TVShowDetailsGenreTableViewCellViewModel: Hashable {

	private let genreText: String?
	private let episodeAverageDurationText: String?
	private let lastAirDateText: String?
	private let statusText: String?
	private let voteAverageText: String?

	var displayGenreText: String { return genreText ?? "" }
	var displayEpisodeAverageDurationText: String { return episodeAverageDurationText ?? "" }
	var displayLastAirDateText: String { return lastAirDateText ?? "" }
	var displayStatusText: String { return statusText ?? "" }
	var displayVoteAverageText: String { return voteAverageText ?? "" }

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
