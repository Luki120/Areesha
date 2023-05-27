import UIKit

/// Controller that'll show the tracked tv shows list view
final class TrackedTVShowsVC: UIViewController {

	private let trackedTVShowListView = TrackedTVShowListView()

	var coordinator: TrackedTVShowsCoordinator?

	// ! Lifecycle

	override func loadView() { view = trackedTVShowListView }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
	}

}
