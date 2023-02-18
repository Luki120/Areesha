import UIKit


@UIApplicationMain
final class ARAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		window = UIWindow()
		window?.tintColor = .areeshaPinkColor
		window?.rootViewController = ARTabBarVC()
		window?.makeKeyAndVisible()
		return true
	}

}
