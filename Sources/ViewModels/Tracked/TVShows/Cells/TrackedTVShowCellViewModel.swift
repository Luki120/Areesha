import Foundation

/// View model struct for `TrackedTVShowListCell`
struct TrackedTVShowCellViewModel: Hashable, ImageFetching {
	let name: String
	let lastSeen: String
	let imageURL: URL?

	var listType: ListType = .currentlyWatching
	private(set) var rating: Double = 0

	var ratingLabel: String {
		let isWholeNumber = rating.truncatingRemainder(dividingBy: 1) == 0
		let ratingValue = isWholeNumber ? String(format: "%.0f/10", rating) : String(describing: rating) + "/10"
		return rating == 0 ? "Not rated yet" : "You rated: " + ratingValue
	}

	enum ListType {
		case currentlyWatching, finished
	}

	/// Designated initializer
	/// - Parameter model: The `TrackedTVShow` object
	init(_ model: TrackedTVShow) {
		self.name = model.name
		self.lastSeen = model.lastSeen
		self.imageURL = model.imageURL
		self.rating = model.rating ?? 0
	}
}
