import protocol Swift.Hashable
import struct Foundation.URL

/// View model struct for `MediaDetailsProvidersCell`
@MainActor
struct MediaDetailsProvidersCellViewModel: ImageFetching {
	let imageURL: URL?
}

nonisolated extension MediaDetailsProvidersCellViewModel: Hashable {}
