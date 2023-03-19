import Foundation


struct TopHeaderCollectionViewCellViewModel: Hashable {

	private let sectionText: String

	var displaySectionText: String { return sectionText }

	init(sectionText: String) {
		self.sectionText = sectionText
	}

}
