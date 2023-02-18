import UIKit

/// Settings coordinator, which will take care of any navigation events related to ARSettingsVC
final class SettingsCoordinator: Coordinator {

	enum Event {}

	var navigationController = UINavigationController()

	init() {
		let settingsVC = ARSettingsVC()
		settingsVC.coordinator = self
		settingsVC.title = "Settings"
		settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

		navigationController.viewControllers = [settingsVC]
	}

	func eventOccurred(with event: Event) {}

}
