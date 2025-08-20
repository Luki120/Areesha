import Foundation

/// Protocol for configuring an instance of `MediaDetailsHeaderViewViewModel`
@MainActor
protocol HeaderPresentable {
	/// Function to setup the view model
	/// - Parameters:
	///		- name: A `String` that represents the media's name
	///		- average: A `Double` that represents the media's vote average
	///		- url: The `URL` for the media's image
	/// - Returns: `MediaDetailsHeaderViewViewModel`
	func setupViewModel(name: String, average: Double, url: URL?) -> MediaDetailsHeaderViewViewModel
}

extension HeaderPresentable {
	func setupViewModel(name: String, average: Double, url: URL?) -> MediaDetailsHeaderViewViewModel {
		let average = average.round(to: 1)
		let isWholeNumber = average.truncatingRemainder(dividingBy: 1) == 0

		let rating = isWholeNumber
			? String(format: "%.0f/10", average)
			: String(describing: average) + "/10"

		guard let url else {
			return .init(
				name: name,
				rating: average == 0 ? "" : rating,
				imageURL: Bundle.main.url(forResource: "Placeholder", withExtension: "jpg")
			)
		}

		return .init(name: name, rating: rating, imageURL: url)
	}
}

/// View model struct for `MediaDetailsHeaderView`
@MainActor
struct MediaDetailsHeaderViewViewModel: ImageFetching {
	private(set) var name: String? = nil
	private(set) var rating: String? = nil
	private(set) var episodeName: String? = nil

	let imageURL: URL?
}
