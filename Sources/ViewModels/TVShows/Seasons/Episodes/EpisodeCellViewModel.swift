import Foundation

/// View model struct for `EpisodeCell`
struct EpisodeCellViewModel: Hashable, ImageFetching {
	let imageURL: URL?
	let episodeNameText: String
	let episodeDurationText: String
	let episodeDescriptionText: String
}
