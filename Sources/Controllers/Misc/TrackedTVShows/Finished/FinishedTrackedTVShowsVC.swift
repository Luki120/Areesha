import UIKit

/// Controller that'll show the finished tracked tv shows list view
final class FinishedTrackedTVShowsVC: BaseVC {

	private let finishedTrackedTVShowListView = FinishedTrackedTVShowListView()

	var coordinator: TrackedTVShowsCoordinator?

	override var titleView: UIView { return finishedTrackedTVShowListView.titleLabel }

	// ! Lifecycle

	override func loadView() { view = finishedTrackedTVShowListView }

	override func setupUI() {
		super.setupUI()
		navigationItem.leftBarButtonItem?.tintColor = .areeshaPinkColor
		finishedTrackedTVShowListView.delegate = self
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

}

// ! FinishedTrackedTVShowListViewDelegate

extension FinishedTrackedTVShowsVC: FinishedTrackedTVShowListViewDelegate {

	func finishedTrackedTVShowListView(
		_ finishedTrackedTVShowListView: FinishedTrackedTVShowListView,
		didSelect trackedTVShow: TrackedTVShow
	) {
		coordinator?.eventOccurred(with: .trackedTVShowCellTapped(trackedTVShow: trackedTVShow))
	}

}
