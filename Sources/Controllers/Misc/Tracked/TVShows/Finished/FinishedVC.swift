import UIKit

/// Controller that'll show the finished tracked tv shows list view
final class FinishedVC: BaseVC {
	private let finishedListView = FinishedListView()

	var coordinator: TrackedMediaCoordinator?

	override var titleView: UIView { return finishedListView.titleLabel }

	// ! Lifecycle

	override func loadView() { view = finishedListView }

	override func setupUI() {
		super.setupUI()
		navigationItem.leftBarButtonItem?.tintColor = .areeshaPinkColor
		finishedListView.delegate = self
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}
}

// ! FinishedListViewDelegate

extension FinishedVC: FinishedListViewDelegate {
	func finishedListView(_ finishedListView: FinishedListView, didSelect trackedTVShow: TrackedTVShow) {
		coordinator?.eventOccurred(with: .trackedTVShowCellTapped(trackedTVShow: trackedTVShow))
	}
}
