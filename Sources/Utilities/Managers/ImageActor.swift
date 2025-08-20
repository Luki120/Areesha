import UIKit

/// Singleton manager to handle the image fetching logic
final actor ImageActor {
	static let sharedInstance = ImageActor()
	private init() {}

	private let imageCache = NSCache<NSString, UIImage>()
 
	/// Function to fetch images
	/// - Parameter url: The image's `URL`, optional as it may be nil
	/// - Returns: `(UIImage, Bool)`
	@_disfavoredOverload
	func fetchImage(_ url: URL?) async throws -> (UIImage, Bool) {
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

	/// Function to fetch images
	/// - Parameter url: The image's `URL`, optional as it may be nil
	/// - Returns: `UIImage`
	func fetchImage(_ url: URL?) async throws -> UIImage {
		guard let url else { throw URLError(.badURL) }

		let (image, _) = try await fetchImage(url)
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

/// Protocol to handle the image fetching logic
@MainActor
protocol ImageFetching {
	/// An optional url to represent the image's url
	var imageURL: URL? { get }
}

extension ImageFetching {
	/// Async function to fetch images either from the cache or the network
	/// - Throws: `(UIImage, Bool)`
	@_disfavoredOverload
	func fetchImage() async throws -> (UIImage, Bool) {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageActor.sharedInstance.fetchImage(imageURL)
	}

	/// Async function to fetch images, ignoring the cache
	/// - Throws: `UIImage`
	func fetchImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }

		let (image, _) = try await ImageActor.sharedInstance.fetchImage(imageURL)
		return image
	}
}
