import UIKit

/// Controller that'll show the tracked tv shows list view
final class TrackedTVShowsVC: UIViewController {
	private let trackedTVShowListView = TrackedTVShowListView()

	var coordinator: TrackedTVShowsCoordinator?

	// ! Lifecycle

	override func loadView() { view = trackedTVShowListView }

	override func viewDidLoad() {
		super.viewDidLoad()
		trackedTVShowListView.delegate = self
		trackedTVShowListView.backgroundColor = .systemBackground
	}
}

// ! TrackedTVShowListViewDelegate

extension TrackedTVShowsVC: TrackedTVShowListViewDelegate {
	func trackedTVShowListView(
		_ trackedTVShowListView: TrackedTVShowListView,
		didSelectItemAt indexPath: IndexPath
	) {
		coordinator?.eventOccurred(with: .cellTapped(indexPath: indexPath))
	}
}
