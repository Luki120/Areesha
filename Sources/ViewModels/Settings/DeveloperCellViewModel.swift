import UIKit.UIImage

/// View model struct for `DeveloperCell`
@MainActor
struct DeveloperCellViewModel: Hashable {
	let lukiImageURL, leptosImageURL: URL?
	let lukiName, leptosName: String

	/// Function to fetch the developer's avatar image
	/// - Returns: `[UIImage]`
	nonisolated func fetchImages() async -> [UIImage] {
		guard let lukiImageURL, let leptosImageURL else { return [] }

		guard let lukisImage = try? await ImageActor.sharedInstance.fetchImage(lukiImageURL),
			let leptosImage = try? await ImageActor.sharedInstance.fetchImage(leptosImageURL) else {
				return []
			}

		return [lukisImage, leptosImage]
	}
}
