import UIKit

/// Singleton manager to handle the image fetching logic
final class ImageManager {

	static let sharedInstance = ImageManager()
	private init() {}

	private let imageCache = NSCache<NSString, UIImage>()
 
	/// Function that'll handle the image fetching data task
	/// - Parameters:
	///		- url: the image's url, optional as it may be nil
	/// - Returns: A UIImage
	func fetchImageAsync(_ url: URL?) async throws -> UIImage {
		guard let url = url else { throw URLError(.badURL) }

		if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
			return cachedImage
		}

		let (data, _) = try await URLSession.shared.data(from: url)
		guard let image = UIImage(data: data) else { throw URLError(.badServerResponse) }
		imageCache.setObject(image, forKey: url.absoluteString as NSString)
		return image
	}

}
