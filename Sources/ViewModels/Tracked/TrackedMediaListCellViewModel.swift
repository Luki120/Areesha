import Foundation

/// View model struct for the vanilla collection view list cells in TrackedMediaListView's collection view
@MainActor
struct TrackedMediaListCellViewModel {
	let text: String
	let imageName: String
}

nonisolated extension TrackedMediaListCellViewModel: Hashable {}
