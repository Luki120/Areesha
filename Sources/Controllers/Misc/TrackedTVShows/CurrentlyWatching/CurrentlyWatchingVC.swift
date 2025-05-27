import UIKit

/// Controller that'll show the currently watching tracked tv shows list view
final class CurrentlyWatchingVC: BaseVC {
	private let currentlyWatchingListView = CurrentlyWatchingListView()

	var coordinator: TrackedTVShowsCoordinator?

	private var selectedOption: TrackedTVShowManager.SortOption?

	override var titleView: UIView { return currentlyWatchingListView.titleLabel }

	// ! Lifecycle

	override func loadView() { view = currentlyWatchingListView }

	override func setupUI() {
		super.setupUI()
		navigationItem.leftBarButtonItem?.tintColor = .areeshaPinkColor
		navigationItem.rightBarButtonItem = .init(
			title: "",
			image: UIImage(systemName: "arrow.up.arrow.down"),
			menu: setupMenu()
		)

		currentlyWatchingListView.delegate = self

		guard let selectedOptionValue = UserDefaults.standard.string(forKey: "selectedOption"),
			let selectedOption = TrackedTVShowManager.SortOption(rawValue: selectedOptionValue) else { return }

		self.selectedOption = selectedOption
		updateMenu()
	}

	// ! Private

	private func setupMenu() -> UIMenu {
		let actions = [
			UIAction(title: "Alphabetically", state: selectedOption == .alphabetically ? .on : .off) { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.currentlyWatchingListView.viewModel, option: .alphabetically
					)
				)
				self.handleSelection(for: .alphabetically)
				self.updateMenu()
			},
			UIAction(title: "Least advanced", state: selectedOption == .leastAdvanced ? .on : .off) { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.currentlyWatchingListView.viewModel, option: .leastAdvanced
					)
				)
				self.handleSelection(for: .leastAdvanced)
				self.updateMenu()
			},
			UIAction(title: "More advanced", state: selectedOption == .moreAdvanced ? .on : .off) { _ in
				self.coordinator?.eventOccurred(
					with: .sortButtonTapped(
						viewModel: self.currentlyWatchingListView.viewModel, option: .moreAdvanced
					)
				)
				self.handleSelection(for: .moreAdvanced)
				self.updateMenu()
			}
		]

		return UIMenu(title: "Sort by", children: actions)
	}

	private func handleSelection(for sortOption: TrackedTVShowManager.SortOption) {
    	selectedOption = sortOption
    	UserDefaults.standard.set(selectedOption?.rawValue, forKey: "selectedOption")
	}

	private func updateMenu() {
		navigationItem.rightBarButtonItem?.menu = setupMenu()
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}
}

// ! CurrentlyWatchingTrackedTVShowListViewDelegate

extension CurrentlyWatchingVC: CurrentlyWatchingListViewDelegate {
	func currentlyWatchingListView(
		_ currentlyWatchingListView: CurrentlyWatchingListView,
		didSelect trackedTVShow: TrackedTVShow
	) {
		coordinator?.eventOccurred(with: .trackedTVShowCellTapped(trackedTVShow: trackedTVShow))
	}

	func didShowToastView(in currentlyWatchingListView: CurrentlyWatchingListView) {
		currentlyWatchingListView.fadeInOutToastView()
	}
}
