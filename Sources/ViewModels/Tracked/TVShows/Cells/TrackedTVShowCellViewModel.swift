import Foundation

/// View model struct for `TrackedTVShowListCell`
@MainActor
struct TrackedTVShowCellViewModel: Hashable, ImageFetching {
	let name: String
	let lastSeen: String

	var imageURL: URL?
	var listType: ListType = .currentlyWatching
	private(set) var rating: Double = 0

	enum ListType {
		case currentlyWatching, finished
	}

	/// Designated initializer
	///	- Parameter model: The `TrackedTVShow` object
	init(_ model: TrackedTVShow) {
		self.name = model.name
		self.lastSeen = model.lastSeen
		self.imageURL = model.imageURL
	}

	/// Initializer to create a `TrackedTVShowCellViewModel` from a `RatedTVShow`
	///	- Parameter model: The `RatedTVShow` object
	init(_ model: RatedTVShow) {
		self.name = model.name
		self.rating = model.rating
		self.lastSeen = ""
		self.imageURL = nil
	}
}
