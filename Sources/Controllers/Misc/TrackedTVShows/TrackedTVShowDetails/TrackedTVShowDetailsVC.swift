import UIKit

/// Controller that'll show the tracked tv show's details view
final class TrackedTVShowDetailsVC: BaseVC {

	let trackedTVShowDetailsViewViewModel: TrackedTVShowDetailsViewViewModel
	private let trackedTVShowDetailsView: TrackedTVShowDetailsView

	var coordinator: TrackedTVShowsCoordinator?

	override var titleView: UIView {
		return trackedTVShowDetailsView.titleLabel
	}

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: The view model object for this vc's view
	init(viewModel: TrackedTVShowDetailsViewViewModel) {
		self.trackedTVShowDetailsViewViewModel = viewModel
		self.trackedTVShowDetailsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
	}

	override func loadView() { view = trackedTVShowDetailsView }

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

}
