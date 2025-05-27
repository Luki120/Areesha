import Foundation

/// View model struct for `SeasonCell`
struct SeasonCellViewModel: Hashable, ImageFetching {
	let imageURL: URL?
	let seasonNameText: String
}
