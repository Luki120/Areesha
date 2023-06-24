import UIKit

/// Protocol to handle the image fetching logic
protocol ImageFetching {
	/// An optional url to represent the image's url
	var imageURL: URL? { get }
}

extension ImageFetching {

	/// Function to retrieve the tv show season image either from the cache or the network
	/// - Returns: A UIImage
	func fetchImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageManager.sharedInstance.fetchImageAsync(imageURL)
	}

}
