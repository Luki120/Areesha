import Foundation

/// View model struct for `SeasonCell`
@MainActor
struct SeasonCellViewModel: Hashable, ImageFetching {
	let imageURL: URL?
	let seasonName: String
}
