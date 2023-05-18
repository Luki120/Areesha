import UIKit

/// View model class for TVShowSeasonsCollectionViewCell
final class TVShowSeasonsCollectionViewCellViewModel: Hashable {

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

 	// ! Hashable

	static func == (lhs: TVShowSeasonsCollectionViewCellViewModel, rhs: TVShowSeasonsCollectionViewCellViewModel) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(imageURL)
	}	

}
