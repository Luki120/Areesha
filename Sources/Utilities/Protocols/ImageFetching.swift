import UIKit

/// Protocol to handle the image fetching logic
@MainActor
protocol ImageFetching {
	/// An optional url to represent the image's url
	var imageURL: URL? { get }
}

extension ImageFetching {
	/// Async function to fetch images
	/// - Throws: `(UIImage, Bool)`
	@_disfavoredOverload
	func fetchImage() async throws -> (UIImage, Bool) {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageActor.sharedInstance.fetchImage(imageURL)
	}

	/// Async function to fetch images
	/// - Throws: `UIImage`
	func fetchImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }

		let (image, _) = try await ImageActor.sharedInstance.fetchImage(imageURL)
		return image
	}
}
