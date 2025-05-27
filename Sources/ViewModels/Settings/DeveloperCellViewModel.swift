import Foundation
import UIKit.UIImage

/// View model struct for `DeveloperCell`
struct DeveloperCellViewModel: Hashable {
	let lukiImageURL, leptosImageURL: URL?
	let lukiName, leptosName: String

	/// Function to fetch the developer's avatar image
	/// - Parameters:
	///		- completion: Escaping closure that takes an array of UIImage as argument & returns nothing
	func fetchImages(completion: @escaping ([UIImage]) async -> ()) {
		guard let lukiImageURL, let leptosImageURL else { return }

		Task.detached(priority: .background) {
			guard let lukisImage: UIImage = try? await ImageManager.sharedInstance.fetchImage(lukiImageURL),
				let leptosImage: UIImage = try? await ImageManager.sharedInstance.fetchImage(leptosImageURL) else { return }

			await completion([lukisImage, leptosImage])
		}
	}
}
