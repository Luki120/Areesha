import Foundation

/// View model struct for `MediaDetailsDescriptionCell`
@MainActor
struct MediaDetailsDescriptionCellViewModel {
	let description: String
}

nonisolated extension MediaDetailsDescriptionCellViewModel: Hashable {}
