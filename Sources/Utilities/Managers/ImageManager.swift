import UIKit

/// Singleton manager to handle the image fetching logic
final class ImageManager {
	static let sharedInstance = ImageManager()
	private init() {}

	private let imageCache = NSCache<NSString, UIImage>()
 
	/// Function that'll handle the image fetching data task
	/// - Parameters:
	///		- url: The image's url, optional as it may be nil
	/// - Returns: `(UIImage, Bool)`
	@_disfavoredOverload
	func fetchImageAsync(_ url: URL?) async throws -> (UIImage, Bool) {
		guard let url else { throw URLError(.badURL) }

		if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
			return (cachedImage, false)
		}

		if #available(iOS 15.0, *) { 
			let (data, _) = try await URLSession.shared.data(from: url)
			guard let image = UIImage(data: data) else { throw URLError(.badServerResponse) }
			imageCache.setObject(image, forKey: url.absoluteString as NSString)
			return (image, true)
		}
		else {
			let data = try await self.data(from: url)
			guard let image = UIImage(data: data) else { throw URLError(.badServerResponse) }
			imageCache.setObject(image, forKey: url.absoluteString as NSString)
			return (image, true)
		}
	}

	/// Function that'll handle the image fetching data task
	/// - Parameters:
	///		- url: The image's url, optional as it may be nil
	/// - Returns: `UIImage`
	func fetchImageAsync(_ url: URL?) async throws -> UIImage {
		guard let url else { throw URLError(.badURL) }

		let (image, _) = try await fetchImageAsync(url)
		return image
	}

	private func data(from url: URL) async throws -> Data {
		try await withCheckedThrowingContinuation { continuation in
			let task = URLSession.shared.dataTask(with: url) { data, _, error in
				guard let data else {
					return continuation.resume(throwing: error ?? URLError(.badServerResponse))
				}
				continuation.resume(returning: data)
			}
			task.resume()
		}
	}
}
