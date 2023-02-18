import UIKit

/// Basic Coordinator protocol to which coordinator classes will conform
protocol Coordinator {
	/// Enum to represent the possible navigation events each coordinator will handle
	associatedtype Event
	/// Navigation controller instance used for either presenting, push or pop a view controller
	var navigationController: UINavigationController { get set }
	/// Function that'll handle the specific event
	/// - Parameters:
	///		- with: the type of Event on which to act on
	func eventOccurred(with event: Event)
}
