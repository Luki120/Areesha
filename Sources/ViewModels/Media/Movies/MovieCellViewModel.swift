import protocol Swift.Hashable
import struct Foundation.URL

/// View model struct for `MovieCell`
@MainActor
struct MovieCellViewModel: ImageFetching {
	var imageURL: URL?
}

nonisolated extension MovieCellViewModel: Hashable {}
