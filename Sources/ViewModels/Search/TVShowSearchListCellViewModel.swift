import Foundation

/// View model struct for the vanilla collection view list cells in TVShowSearchListView's collection view
struct TVShowSearchListCellViewModel: Hashable {
	private let id: Int
	let tvShowName: String

	/// Designated initializer
	/// - Parameters:
	///		- id: A unique integer to represent the TV show id 
	///		- tvShowName: A string to represent the TV show name text
	init(id: Int, tvShowName: String) {
		self.id = id
		self.tvShowName = tvShowName
	}
}
