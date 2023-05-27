import UIKit

/// Settings coordinator, which will take care of any navigation events related to SettingsVC
final class SettingsCoordinator: Coordinator {

	enum Event {}

	var navigationController = SwipeableNavigationController()

	init() {
		let settingsVC = SettingsVC()
		settingsVC.coordinator = self
		settingsVC.title = "Settings"
		settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

		navigationController.viewControllers = [settingsVC]
	}

	func eventOccurred(with event: Event) {}

}
