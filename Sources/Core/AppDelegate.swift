import UIKit


@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var restrictRotation: UIInterfaceOrientationMask = .all

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		window = UIWindow()
		window?.tintColor = .areeshaPinkColor
		window?.rootViewController = TabBarVC()
		window?.makeKeyAndVisible()
		return true
	}

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return restrictRotation
	}

}
