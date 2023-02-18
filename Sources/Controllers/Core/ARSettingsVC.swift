import UIKit

/// Controller that'll show the settings view
final class ARSettingsVC: UIViewController {

	var coordinator: SettingsCoordinator?

	// ! Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

}
