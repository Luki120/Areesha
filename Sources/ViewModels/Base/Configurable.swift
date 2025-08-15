import Foundation

/// Protocol to represent a generic object that conforms to `Hashable` to supply the diffable data source
@MainActor
protocol Configurable: Sendable {
	/// Generic object that conforms to `Hashable`
	associatedtype ViewModel: Hashable & Sendable
	/// Function that'll configure the collection view's cells with the specified view model
	/// - Parameter viewModel: The cell's view model
	func configure(with viewModel: ViewModel)
}
