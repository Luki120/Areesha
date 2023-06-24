import Foundation

/// View model struct for TrackedTVShowCollectionViewCell
struct TrackedTVShowCollectionViewCellViewModel: Codable, Hashable, ImageFetching {

	let imageURL: URL?
	let tvShowNameText: String
	let lastSeenText: String

}
