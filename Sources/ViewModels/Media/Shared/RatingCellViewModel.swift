import Foundation

/// View model struct for `RatingCell`
@MainActor
struct RatingCellViewModel {
	let id = UUID()
	var image = "star"
}

nonisolated extension RatingCellViewModel: Hashable {}
