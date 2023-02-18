import Foundation

/// View model struct for the vanilla collection view list cells in ARTVShowSearchListView's collection view
struct ARTVShowSearchCollectionViewListCellViewModel: Hashable {

	private let tvShowNameText: String

	var displayTVShowNameText: String { return tvShowNameText }

	/// Designated initializer
	/// - Parameters:
	///     - tvShowNameText: a string to represent the TV show name text
	init(tvShowNameText: String) {
		self.tvShowNameText = tvShowNameText
	}

}
