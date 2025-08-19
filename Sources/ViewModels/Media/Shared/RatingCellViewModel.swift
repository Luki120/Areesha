import Foundation

/// View model struct for `RatingCell`
@MainActor
struct RatingCellViewModel: Hashable {
	let id = UUID()
	var image = "star"
}
