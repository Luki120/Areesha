import UIKit

/// Controller that'll show the episodes view
final class EpisodesVC: BaseVC {
	let episodesViewViewModel: EpisodesViewViewModel
	private let coordinatorType: CoordinatorType
	private let episodesView: EpisodesView

	override var titleView: UIView {
		return episodesView.titleLabel
	}

	enum CoordinatorType {
		case details(TVShowDetailsCoordinator)
		case tracked(TrackedTVShowsCoordinator)
	}

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this vc's view
	///		- coordinatorType: The type of coordinator that'll handle this vc's events
	init(viewModel: EpisodesViewViewModel, coordinatorType: CoordinatorType) {
		self.episodesViewViewModel = viewModel
		self.episodesView = .init(viewModel: viewModel)
		self.coordinatorType = coordinatorType
		super.init(nibName: nil, bundle: nil)
		episodesView.delegate = self
	}

	override func loadView() { view = episodesView }

	override func didTapLeftBarButton() {
		switch coordinatorType {
			case .details(let tvShowDetailsCoordinator):
				tvShowDetailsCoordinator.eventOccurred(with: .backButtonTapped)

			case .tracked(let trackedTVShowsCoordinator):
				trackedTVShowsCoordinator.eventOccurred(with: .backButtonTapped)
		}
	}
}

// ! EpisodesViewDelegate

extension EpisodesVC: EpisodesViewDelegate {
	func didShowToastView(in episodesView: EpisodesView) {
		episodesView.fadeInOutToastView()
	}
}
