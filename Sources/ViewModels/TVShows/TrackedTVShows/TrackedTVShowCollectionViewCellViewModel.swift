import UIKit

/// View model struct for TrackedTVShowCollectionViewCell
struct TrackedTVShowCollectionViewCellViewModel: Codable, Hashable {

	private let imageURL: URL?
	let tvShowNameText: String
	let lastSeenText: String

	/// Designated initializer
	/// - Parameters:
	///     - imageURL: An optional url to represent the image's url
	///     - tvShowNameText: A string to represent the tv show's name
	///     - lastSeenText: A string to represent the last seen text
	init(imageURL: URL?, tvShowNameText: String, lastSeenText: String) {
		self.imageURL = imageURL
		self.tvShowNameText = tvShowNameText
		self.lastSeenText = lastSeenText
	}

	/// Function to retrieve the tv show season image either from the cache or the network
	/// - Returns: A UIImage
	func fetchTVShowSeasonImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageManager.sharedInstance.fetchImageAsync(imageURL)
	}

}
