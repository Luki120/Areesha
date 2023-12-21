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
		navigationItem.rightBarButtonItem = .init(
			title: "",
			image: UIImage(systemName: "line.horizontal.3"),
			menu: setupMenu()
		)

	}

	// ! Private

	private func setupMenu() -> UIMenu {
		let actions = [
			UIAction(title: "Alphabetically") { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.trackedTVShowListView.viewModel, option: .alphabetically
					)
				)
			},
			UIAction(title: "Least advanced") { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.trackedTVShowListView.viewModel, option: .leastAdvanced
					)
				)
			},
			UIAction(title: "More advanced") { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.trackedTVShowListView.viewModel, option: .moreAdvanced
					)
				)
			}
		]

		return UIMenu(title: "Sort by", children: actions)
	}

}

// ! TrackedTVShowListViewDelegate

extension TrackedTVShowsVC: TrackedTVShowListViewDelegate {

	func trackedTVShowListView(
		_ trackedTVShowListView: TrackedTVShowListView,
		didSelect trackedTVShow: TrackedTVShow
	) {
		coordinator?.eventOccurred(with: .trackedTVShowCellTapped(trackedTVShow: trackedTVShow))
	}

}
