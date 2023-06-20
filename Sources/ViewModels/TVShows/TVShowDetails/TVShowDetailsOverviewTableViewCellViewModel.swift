import Foundation

/// View model struct for TVShowDetailsOverviewTableViewCell
struct TVShowDetailsOverviewTableViewCellViewModel: Hashable {

	private let overviewText: String

	var displayOverviewText: String { return overviewText }

	/// Designated initializer
	/// - Parameters:
	///     - overviewText: A string to represent the overview text
	init(overviewText: String) {
		self.overviewText = overviewText
	}

}
