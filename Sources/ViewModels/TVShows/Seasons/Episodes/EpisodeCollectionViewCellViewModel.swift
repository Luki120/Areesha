import Foundation

/// View model struct for EpisodeCollectionViewCell
struct EpisodeCollectionViewCellViewModel: Hashable, ImageFetching {

	let imageURL: URL?
	let episodeNameText: String
	let episodeDurationText: String
	let episodeDescriptionText: String

}
