import UIKit

/// View model struct for EpisodeCollectionViewCell
struct EpisodeCollectionViewCellViewModel: Hashable {

	private let imageURL: URL?

	let episodeNameText: String
	let episodeDurationText: String
	let episodeDescriptionText: String

	/// Designated initializer
	/// - Parameters:
	///     - imageURL: an optional url to represent the image's url
	///     - episodeNameText: a string to represent the episode's name
	///     - episodeDurationText: a string to represent the episode's duration
	///     - episodeDescriptionText: a string to represent the episode's description
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
