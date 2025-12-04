import UIKit

@main
final class SceneDelegate: UIResponder, UIApplicationDelegate, UISceneDelegate {
	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = scene as? UIWindowScene else { return }

		window = UIWindow(windowScene: scene)
		window?.tintColor = .areeshaPinkColor
		window?.rootViewController = TabBarVC()
		window?.makeKeyAndVisible()

		Task {
			await NotificationActor.sharedInstance.requestAuthorization()
		}
	}
}
