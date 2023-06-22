import UIKit

/// View model struct for SeasonCollectionViewCell
struct SeasonCollectionViewCellViewModel: Hashable {

	private let imageURL: URL?
	let seasonNameText: String

	/// Designated initializer
	/// - Parameters:
	///     - imageURL: An optional url to represent the image's url
	///     - seasonText: A string to represent the season name
	init(imageURL: URL?, seasonNameText: String) {
		self.imageURL = imageURL
		self.seasonNameText = seasonNameText
	}

	/// Function to retrieve the tv show season image either from the cache or the network
	/// - Returns: A UIImage
	func fetchTVShowSeasonImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageManager.sharedInstance.fetchImageAsync(imageURL)
	}

}
