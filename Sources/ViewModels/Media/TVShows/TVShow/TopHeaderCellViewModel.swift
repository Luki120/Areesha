import Foundation

/// View model struct for `TopHeaderCell`
@MainActor
struct TopHeaderCellViewModel {
	let sectionName: String
}

nonisolated extension TopHeaderCellViewModel: Hashable {}
