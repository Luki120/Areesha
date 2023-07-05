import Foundation

/// View model struct for TrackedTVShowCollectionViewListCell
struct TrackedTVShowCollectionViewListCellViewModel: Codable, Hashable, ImageFetching {

	let imageURL: URL?
	let tvShowNameText: String
	let lastSeenText: String

	/// Designated initializer
	/// - Parameters:
	///		- model: The model object
	init(_ model: TrackedTVShow) {
		self.imageURL = model.imageURL
		self.tvShowNameText = model.tvShowNameText
		self.lastSeenText = model.lastSeenText
	}

}
