import protocol Swift.Hashable
import struct Foundation.URL

/// View model struct for `MediaDetailsProvidersCell`
@MainActor
struct MediaDetailsProvidersCellViewModel: Hashable, ImageFetching {
	let imageURL: URL?
}
