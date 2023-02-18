import UIKit.UIImage

/// View model struct for ARTVShowDetailsHeaderView
struct ARTVShowDetailsHeaderViewViewModel {

	private let imageURL: URL?

	/// Designated initializer
	/// - Parameters:
	///     - imageURL: an optional url to represent the image's url
	init(imageURL: URL?) {
		self.imageURL = imageURL
	}

	/// Function to retrieve the tv show image either from the cache or the network
	/// - Returns: A UIImage
	func fetchTVShowHeaderImage() async throws -> UIImage {
		guard let url = imageURL else { throw URLError(.badURL) }
		return try await ARImageManager.sharedInstance.fetchImageAsync(url)
	}

}
