import Foundation

/// Protocol to represent a generic object that conforms to Hashable to supply the diffable data source
protocol Configurable {
	/// Generic object that conforms to Hashable
	associatedtype ViewModel: Hashable
	/// Function that'll configure the collection view's cells with the specified view model
	/// - Parameters:
	///		- with: the cell's view model
	func configure(with viewModel: ViewModel)
}
