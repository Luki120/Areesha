import Foundation

/// View model struct for `TrackedTVShowDetailsHeaderView`
@MainActor
struct TrackedTVShowDetailsHeaderViewViewModel: ImageFetching {
	let imageURL: URL?
	let episodeName: String	
}
