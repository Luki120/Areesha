import UIKit

/// View model struct for TVShowSeasonsCollectionViewCell
struct TVShowSeasonsCollectionViewCellViewModel: Hashable {

	private let imageURL: URL?
	private let seasonNameText: String

	var displaySeasonNameText: String { return seasonNameText }

	/// Designated initializer
	/// - Parameters:
	///     - imageURL: an optional url to represent the image's url
	///     - seasonText: a string to represent the season name
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
