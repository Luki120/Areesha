import Foundation

/// View model struct for `TVShowDetailsNetworksCell`
struct TVShowDetailsNetworksCellViewModel: Hashable {
	let networksTitle: String?
	let networksNames: String?

	/// Designated initializer
	/// - Parameters:
	///		- networksTitle: A nullable string to represent the networks title
	///		- networksNames: A nullable string to represent the networks names
	init(networksTitle: String? = nil, networksNames: String? = nil) {
		self.networksTitle = networksTitle
		self.networksNames = networksNames
	}
}
