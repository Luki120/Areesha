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
		let formattedRating = average.truncatingRemainder(dividingBy: 1) == 0
			? String(format: "%.0f/10", average)
			: String(describing: average) + "/10"

		let rating = average == 0 ? "" : formattedRating

		guard let url else {
			return .init(
				name: name,
				rating: rating,
				imageURL: Bundle.main.url(forResource: "Placeholder", withExtension: "jpg")
			)
		}

		return .init(name: name, rating: rating, imageURL: url)
	}
}
