import Foundation

/// View model struct for `MediaDetailsProvidersCell`
@MainActor
struct MediaDetailsProvidersCellViewModel: Hashable, ImageFetching {
	let imageURL: URL?
}
