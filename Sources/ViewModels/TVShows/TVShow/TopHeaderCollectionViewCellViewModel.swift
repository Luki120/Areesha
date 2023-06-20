import Foundation

/// View model struct for TopHeaderCollectionViewCell
struct TopHeaderCollectionViewCellViewModel: Hashable {

	private let sectionText: String

	var displaySectionText: String { return sectionText }

	/// Designated initializer
	/// - Parameters:
	///     - sectionText: A string to display the section text
	init(sectionText: String) {
		self.sectionText = sectionText
	}

}
