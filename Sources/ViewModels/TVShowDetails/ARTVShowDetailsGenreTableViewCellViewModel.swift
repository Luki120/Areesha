import Foundation

/// View model struct for ARTVShowDetailsGenreTableViewCell
struct ARTVShowDetailsGenreTableViewCellViewModel: Hashable {

	private let genreText: String?
	private let episodeAverageDurationText: String?
	private let lastAirDateText: String?
	private let statusText: String?

	var displayGenreText: String { return genreText ?? "" }
	var displayEpisodeAverageDurationText: String { return episodeAverageDurationText ?? "" }
	var displayLastAirDateText: String { return lastAirDateText ?? "" }
	var displayStatusText: String { return statusText ?? "" }

	/// Designated initializer
	/// - Parameters:
	///     - genreText: a nullable string to represent the genre text
	///		- episodeAverageDurationText: a nullable string to represent the episode average duration text
	///     - lastAirDateText: a nullable string to represent the last air date text
	///		- statusText: a nullable string to represent the status text
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
