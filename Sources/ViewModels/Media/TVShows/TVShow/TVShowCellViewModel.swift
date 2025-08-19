import Foundation

/// View model struct for `TVShowCell`
@MainActor
struct TVShowCellViewModel: Hashable, ImageFetching {
	let imageURL: URL?
}
