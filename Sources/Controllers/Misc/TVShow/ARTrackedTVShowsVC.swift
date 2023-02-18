import UIKit

/// Controller that'll show the tracked tv shows list view
final class ARTrackedTVShowsVC: UIViewController {

	var coordinator: TrackedTVShowsCoordinator?

	// ! Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

}
