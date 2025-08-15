import UIKit.UIImage

/// View model struct for `DeveloperCell`
struct DeveloperCellViewModel: Hashable {
	let lukiImageURL, leptosImageURL: URL?
	let lukiName, leptosName: String

	/// Function to fetch the developer's avatar image
	/// - Returns: `[UIImage]`
	nonisolated func fetchImages() async -> [UIImage] {
		guard let lukiImageURL, let leptosImageURL else { return [] }

		guard let lukisImage: UIImage = try? await ImageActor.sharedInstance.fetchImage(lukiImageURL),
			let leptosImage: UIImage = try? await ImageActor.sharedInstance.fetchImage(leptosImageURL) else {
				return []
			}

		return [lukisImage, leptosImage]
	}
}
