import Foundation

/// View model struct for `SeasonCell`
@MainActor
struct SeasonCellViewModel: ImageFetching {
	let imageURL: URL?
	let seasonName: String
}

nonisolated extension SeasonCellViewModel: Hashable {}
