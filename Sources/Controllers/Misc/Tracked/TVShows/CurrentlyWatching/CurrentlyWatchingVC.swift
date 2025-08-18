import UIKit

/// Controller that'll show the currently watching tracked tv shows list view
final class CurrentlyWatchingVC: BaseVC {
	private let currentlyWatchingListView = CurrentlyWatchingListView()
	private let roundedBlurredButton: RoundedBlurredButton = .init(systemImage: "arrow.up.arrow.down")

	var coordinator: TrackedMediaCoordinator?
	override var titleView: UIView { return currentlyWatchingListView.titleLabel }

	// ! Lifecycle

	override func loadView() { view = currentlyWatchingListView }

	override func setupUI() {
		super.setupUI()
		currentlyWatchingListView.delegate = self

		navigationItem.leftBarButtonItem?.tintColor = .areeshaPinkColor
		navigationItem.rightBarButtonItem = createSortShowsBarButtonItem()
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

	// ! Private

	private func makeAction(for sortOption: TrackedTVShowManager.SortOption) -> UIAction {
		let title: String
		let state: UIAction.State = TrackedTVShowManager.sharedInstance.sortOption == sortOption ? .on : .off

		switch sortOption {
			case .alphabetically: title = "Alphabetically"
			case .leastAdvanced: title = "Least advanced"
			case .moreAdvanced: title = "More advanced"
		}

		return UIAction(title: title, state: state) { _ in
			self.coordinator?.eventOccurred(
				with: .sortButtonTapped(viewModel: self.currentlyWatchingListView.viewModel, option: sortOption)
			)

			TrackedTVShowManager.sharedInstance.sortOption = sortOption
			self.roundedBlurredButton.menu = UIMenu(
				title: "Sort by",
				children: TrackedTVShowManager.SortOption.allCases.map(self.makeAction)
			)
		}
	}

	private func createSortShowsBarButtonItem() -> UIBarButtonItem {
		roundedBlurredButton.menu = UIMenu(
			title: "Sort by",
			children: TrackedTVShowManager.SortOption.allCases.map(self.makeAction)
		)
		roundedBlurredButton.showsMenuAsPrimaryAction = true
		return .init(customView: roundedBlurredButton)
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
}
