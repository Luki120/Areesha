import UIKit

/// Controller that'll show the settings view
final class SettingsVC: UIViewController {

	var coordinator: SettingsCoordinator?

	// ! Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

}
