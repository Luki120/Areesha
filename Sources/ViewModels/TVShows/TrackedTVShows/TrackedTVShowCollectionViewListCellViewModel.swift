import Foundation

/// View model struct for TrackedTVShowCollectionViewListCell
struct TrackedTVShowCollectionViewListCellViewModel: Codable, Hashable, ImageFetching {

	let imageURL: URL?
	let tvShowNameText: String
	let lastSeenText: String

}
