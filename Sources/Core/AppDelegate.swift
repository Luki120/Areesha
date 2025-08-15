import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		window = UIWindow()
		window?.tintColor = .areeshaPinkColor
		window?.rootViewController = TabBarVC()
		window?.makeKeyAndVisible()

		Task {
			await NotificationActor.sharedInstance.requestAuthorization()
		}

		return true
	}
}
