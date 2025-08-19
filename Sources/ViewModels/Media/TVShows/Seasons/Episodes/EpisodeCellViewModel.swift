import Foundation

/// View model struct for `EpisodeCell`
@MainActor
struct EpisodeCellViewModel: Hashable, ImageFetching {
	let imageURL: URL?
	let episodeName: String
	let episodeDuration: String
	let episodeDescription: String
}
