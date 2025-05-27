import Foundation

/// View model struct for `TrackedTVShowListCell`
struct TrackedTVShowCellViewModel: Codable, Hashable, ImageFetching {
	let name: String
	let lastSeen: String
	let imageURL: URL?

	/// Designated initializer
	/// - Parameters:
	///		- model: The model object
	init(_ model: TrackedTVShow) {
		self.name = model.name
		self.lastSeen = model.lastSeen
		self.imageURL = model.imageURL
	}
}
