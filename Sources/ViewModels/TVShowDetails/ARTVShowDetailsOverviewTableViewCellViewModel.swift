import Foundation

/// View model struct for ARTVShowDetailsOverviewTableViewCell
struct ARTVShowDetailsOverviewTableViewCellViewModel: Hashable {

	private let overviewText: String

	var displayOverviewText: String { return overviewText }

	/// Designated initializer
	/// - Parameters:
	///     - overviewText: a string to represent the overview text
	init(overviewText: String) {
		self.overviewText = overviewText
	}

}
