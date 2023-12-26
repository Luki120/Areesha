import UIKit

/// Controller that'll show the currently watching tracked tv shows list view
final class CurrentlyWatchingTrackedTVShowsVC: BaseVC {

	private let currentlyWatchingTrackedTVShowListView = CurrentlyWatchingTrackedTVShowListView()

	var coordinator: TrackedTVShowsCoordinator?

	override var titleView: UIView { return currentlyWatchingTrackedTVShowListView.titleLabel }

	// ! Lifecycle

	override func loadView() { view = currentlyWatchingTrackedTVShowListView }

	override func setupUI() {
		super.setupUI()
		navigationItem.leftBarButtonItem?.tintColor = .areeshaPinkColor
		navigationItem.rightBarButtonItem = .init(
			title: "",
			image: UIImage(systemName: "line.horizontal.3"),
			menu: setupMenu()
		)

		currentlyWatchingTrackedTVShowListView.delegate = self
	}

	// ! Private

	private func setupMenu() -> UIMenu {
		let actions = [
			UIAction(title: "Alphabetically") { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.currentlyWatchingTrackedTVShowListView.viewModel, option: .alphabetically
					)
				)
			},
			UIAction(title: "Least advanced") { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.currentlyWatchingTrackedTVShowListView.viewModel, option: .leastAdvanced
					)
				)
			},
			UIAction(title: "More advanced") { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.currentlyWatchingTrackedTVShowListView.viewModel, option: .moreAdvanced
					)
				)
			}
		]

		return UIMenu(title: "Sort by", children: actions)
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

}

// ! CurrentlyWatchingTrackedTVShowListViewDelegate

extension CurrentlyWatchingTrackedTVShowsVC: CurrentlyWatchingTrackedTVShowListViewDelegate {

	func currentlyWatchingTrackedTVShowListView(
		_ currentlyWatchingTrackedTVShowListView: CurrentlyWatchingTrackedTVShowListView,
		didSelect trackedTVShow: TrackedTVShow
	) {
		coordinator?.eventOccurred(with: .trackedTVShowCellTapped(trackedTVShow: trackedTVShow))
	}

	func didShowToastView(in currentlyWatchingTrackedTVShowListView: CurrentlyWatchingTrackedTVShowListView) {
		currentlyWatchingTrackedTVShowListView.fadeInOutToastView()
	}

}
