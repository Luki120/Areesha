import UIKit

/// Controller that'll show the tracked media list view
final class TrackedMediaVC: UIViewController {
	private let trackedMediaListView = TrackedMediaListView()

	var coordinator: TrackedMediaCoordinator?

	// ! Lifecycle

	override func loadView() { view = trackedMediaListView }

	override func viewDidLoad() {
		super.viewDidLoad()
		trackedMediaListView.delegate = self
		trackedMediaListView.backgroundColor = .systemBackground
	}
}

// ! TrackedMediaListViewDelegate

extension TrackedMediaVC: TrackedMediaListViewDelegate {
	func trackedMediaListView(
		_ trackedMediaListView: TrackedMediaListView,
		didSelectItemAt indexPath: IndexPath
	) {
		coordinator?.eventOccurred(with: .cellTapped(indexPath: indexPath))
	}
}
