import Foundation

/// View model struct for the vanilla collection view list cells in TVShowSearchListView's collection view
struct TVShowSearchListCellViewModel: Hashable {
	private let id: Int
	let tvShowNameText: String

	/// Designated initializer
	/// - Parameters:
	///		- id: A unique integer to represent the TV show id 
	///		- tvShowNameText: A string to represent the TV show name text
	init(id: Int, tvShowNameText: String) {
		self.id = id
		self.tvShowNameText = tvShowNameText
	}
}
