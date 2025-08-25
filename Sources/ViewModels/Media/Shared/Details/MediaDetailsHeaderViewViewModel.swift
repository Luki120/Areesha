import struct Swift.String
import struct Foundation.URL

/// View model struct for `MediaDetailsHeaderView`
@MainActor
struct MediaDetailsHeaderViewViewModel: ImageFetching {
	private(set) var name: String? = nil
	private(set) var rating: String? = nil
	private(set) var episodeName: String? = nil

	let imageURL: URL?
}
