import UIKit

/// Explore coordinator, which will take care of any navigation events related to ARTrackedTVShowsVC
final class TrackedTVShowsCoordinator: Coordinator {

	enum Event {}

	var navigationController = UINavigationController()

	init() {
		let trackedTVShowsVC = ARTrackedTVShowsVC()
		trackedTVShowsVC.coordinator = self
		trackedTVShowsVC.title = "Shows"
		trackedTVShowsVC.tabBarItem = UITabBarItem(title: "Shows", image: UIImage(named: "Movie"), tag: 0)

		navigationController.viewControllers = [trackedTVShowsVC]
	}

	func eventOccurred(with event: Event) {}

}
