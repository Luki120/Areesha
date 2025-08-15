import UIKit

/// Coordinator protocol to handle navigation events
@MainActor
protocol Coordinator: AnyObject {
	/// Enum to represent a navigation event
	associatedtype Event
	/// Navigation controller instance
	var navigationController: SwipeableNavigationController { get set }
	/// Function to handle events
	/// - Parameter event: The type of `Event`
	func eventOccurred(with event: Event)
}
