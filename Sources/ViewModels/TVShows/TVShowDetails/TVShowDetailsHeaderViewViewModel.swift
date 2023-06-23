import UIKit

/// View model struct for TVShowDetailsHeaderView
struct TVShowDetailsHeaderViewViewModel {

	private let imageURL: URL?
	let tvShowNameText: String
	let ratingsText: String

	/// Designated initializer
	/// - Parameters:
	///		- imageURL: An optional url to represent the image's url
	///		- tvShowNameText: A string to represent the tv show's name text
	///		- ratingsText: A string to represent the tv show's ratings text
	init(imageURL: URL?, tvShowNameText: String, ratingsText: String) {
		self.imageURL = imageURL
		self.tvShowNameText = tvShowNameText
		self.ratingsText = ratingsText
	}

	/// Function to retrieve the tv show image either from the cache or the network
	/// - Returns: A UIImage
	func fetchTVShowHeaderImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageManager.sharedInstance.fetchImageAsync(imageURL)
	}

}
