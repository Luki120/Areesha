import Foundation

/// View model struct for TVShowDetailsNetworksTableViewCell
struct TVShowDetailsNetworksTableViewCellViewModel: Hashable {

	private let networksTitleText: String?
	private let networksNamesText: String?

	var displayNetworksTitleText: String { return networksTitleText ?? "" }
	var displayNetworksNamesText: String { return networksNamesText ?? "" }

	/// Designated initializer
	/// - Parameters:
	///     - networksTitleText: A nullable string to represent the networks title text
	///		- networksNamesText: A nullable string to represent the networks names text
	init(networksTitleText: String? = nil, networksNamesText: String? = nil) {
		self.networksTitleText = networksTitleText
		self.networksNamesText = networksNamesText
	}

}
