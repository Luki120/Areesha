import UIKit

/// Root view controller, which will show our tabs
final class TabBarVC: UITabBarController {

	private let exploreCoordinator = ExploreCoordinator()
	private let trackedTVShowsCoordinator = TrackedTVShowsCoordinator()
	private let settingsCoordinator = SettingsCoordinator()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init() {
		super.init(nibName: nil, bundle: nil)
		viewControllers = [
			exploreCoordinator.navigationController,
			trackedTVShowsCoordinator.navigationController,
			settingsCoordinator.navigationController
		]
	}

}
