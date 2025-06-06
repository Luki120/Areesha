import Foundation

/// View model struct for `TrackedTVShowListCell`
struct TrackedTVShowCellViewModel: Hashable, ImageFetching {
	let name: String
	let lastSeen: String
	let imageURL: URL?

	var listType: ListType = .currentlyWatching
	private(set) var rating: Double = 0

	var ratingLabel: String {
		rating == 0 ? "Not rated yet" : "You rated: " + String(describing: Int(rating)) + "/10"
	}

	enum ListType {
		case currentlyWatching, finished
	}

	/// Designated initializer
	/// - Parameters:
	///		- model: The `TrackedTVShow` object
	init(_ model: TrackedTVShow) {
		self.name = model.name
		self.lastSeen = model.lastSeen
		self.imageURL = model.imageURL
		self.rating = model.rating ?? 0
	}
}
