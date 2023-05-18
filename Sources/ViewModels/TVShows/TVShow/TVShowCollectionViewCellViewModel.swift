import UIKit.UIImage

/// View model class for TVShowSearchListView
final class TVShowCollectionViewCellViewModel: Hashable {

	private let imageURL: URL?

	/// Designated initializer
	/// - Parameters:
	///     - imageURL: an optional url to represent the image's url
	init(imageURL: URL?) {
		self.imageURL = imageURL
	}

	/// Function to retrieve the tv show image either from the cache or the network
	/// - Returns: A UIImage
	func fetchTVShowImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageManager.sharedInstance.fetchImageAsync(imageURL)
	}

 	// ! Hashable

	static func == (lhs: TVShowCollectionViewCellViewModel, rhs: TVShowCollectionViewCellViewModel) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(imageURL)
	}

}
