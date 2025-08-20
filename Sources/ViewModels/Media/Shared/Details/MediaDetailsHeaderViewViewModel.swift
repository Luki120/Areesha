import Foundation

/// View model struct for `MediaDetailsHeaderView`
@MainActor
struct MediaDetailsHeaderViewViewModel: ImageFetching {
	let imageURL: URL?
	let tvShowName: String
	let rating: String
}
