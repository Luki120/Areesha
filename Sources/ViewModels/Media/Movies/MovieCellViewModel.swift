import protocol Swift.Hashable
import struct Foundation.URL

/// View model struct for `MovieCell`
struct MovieCellViewModel: Hashable, ImageFetching {
	var imageURL: URL?
}
