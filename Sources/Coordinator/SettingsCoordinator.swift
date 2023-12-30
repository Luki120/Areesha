import UIKit

/// Settings coordinator, which will take care of any navigation events related to SettingsVC
final class SettingsCoordinator: Coordinator {

	enum Event {
		case appCellTapped(app: App)
		case sourceCodeCellTapped
	}

	var navigationController = SwipeableNavigationController()

	init() {
		let settingsVC = SettingsVC()
		settingsVC.coordinator = self
		settingsVC.title = "Settings"
		settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

		navigationController.viewControllers = [settingsVC]
	}

	func eventOccurred(with event: Event) {
		switch event {
			case .appCellTapped(let app): openURL(app.appURL)
			case .sourceCodeCellTapped: openURL(URL(string: "https://github.com/Luki120/Areesha"))
		}
	}

	private func openURL(_ url: URL?) {
		guard let url else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

}
