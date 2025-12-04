import Foundation

/// View model struct for `TVShowCell`
@MainActor
struct TVShowCellViewModel: ImageFetching {
	let imageURL: URL?
}

nonisolated extension TVShowCellViewModel: Hashable {}
