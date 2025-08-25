import protocol Swift.Hashable

/// Protocol to represent a generic object that conforms to `Hashable` to supply the diffable data source
@MainActor
protocol Configurable: Sendable {
	/// Generic object that conforms to `Hashable`
	associatedtype ViewModel: Hashable & Sendable
	/// Function to configure a collection or table view cell with the specified view model
	/// - Parameter viewModel: The cell's `ViewModel`
	func configure(with viewModel: ViewModel)
}
