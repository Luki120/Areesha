import Foundation

/// View model struct for `TVShowDetailsHeaderView`
@MainActor
struct TVShowDetailsHeaderViewViewModel: ImageFetching {
	let imageURL: URL?
	let tvShowName: String
	let rating: String
}
