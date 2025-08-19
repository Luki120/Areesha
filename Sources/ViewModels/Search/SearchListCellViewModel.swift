import Foundation

/// View model struct for the vanilla collection view list cells in SearchListView's collection view
@MainActor
struct SearchListCellViewModel: Hashable {
	private let id: Int
	let name: String

	/// Designated initializer
	/// - Parameters:
	///		- id: An `Int` that represents the object id 
	///		- name: A `String` that represents the object's type name
	init(id: Int, name: String) {
		self.id = id
		self.name = name
	}
}
