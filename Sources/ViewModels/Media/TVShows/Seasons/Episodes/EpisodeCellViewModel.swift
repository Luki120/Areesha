import Foundation

/// View model struct for `EpisodeCell`
@MainActor
struct EpisodeCellViewModel: ImageFetching {
	let imageURL: URL?
	let episodeName, episodeDuration, episodeDescription: String
}

nonisolated extension EpisodeCellViewModel: Hashable {}
