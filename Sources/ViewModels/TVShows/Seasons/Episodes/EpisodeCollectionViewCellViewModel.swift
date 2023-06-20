import UIKit

/// View model struct for EpisodeCollectionViewCell
struct EpisodeCollectionViewCellViewModel: Hashable {

	private let imageURL: URL?

	let episodeNameText: String
	let episodeDurationText: String
	let episodeDescriptionText: String

	/// Designated initializer
	/// - Parameters:
	///     - imageURL: An optional url to represent the image's url
	///     - episodeNameText: A string to represent the episode's name
	///     - episodeDurationText: A string to represent the episode's duration
	///     - episodeDescriptionText: A string to represent the episode's description
	init(imageURL: URL?, episodeNameText: String, episodeDurationText: String, episodeDescriptionText: String) {
		self.imageURL = imageURL
		self.episodeNameText = episodeNameText
		self.episodeDurationText = episodeDurationText
		self.episodeDescriptionText = episodeDescriptionText
	}

	/// Function to retrieve the episode image either from the cache or the network
	/// - Returns: A UIImage
	func fetchEpisodeImage() async throws -> UIImage {
		guard let imageURL else { throw URLError(.badURL) }
		return try await ImageManager.sharedInstance.fetchImageAsync(imageURL)
	}

}
