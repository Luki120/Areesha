import Foundation

/// View model struct for `TVShowDetailsNetworksCell`
struct TVShowDetailsNetworksCellViewModel: Hashable {
	let networksTitleText: String?
	let networksNamesText: String?

	/// Designated initializer
	/// - Parameters:
	///		- networksTitleText: A nullable string to represent the networks title text
	///		- networksNamesText: A nullable string to represent the networks names text
	init(networksTitleText: String? = nil, networksNamesText: String? = nil) {
		self.networksTitleText = networksTitleText
		self.networksNamesText = networksNamesText
	}
}
