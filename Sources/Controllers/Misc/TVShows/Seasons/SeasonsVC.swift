import UIKit

/// Controller that'll show the tv show seasons view
final class SeasonsVC: BaseVC {

	let seasonsViewViewModel: SeasonsViewViewModel
	let coordinatorType: CoordinatorType
	private let seasonsView: SeasonsView

	override var titleView: UIView {
		return seasonsView.titleLabel
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
	init(viewModel: SeasonsViewViewModel, coordinatorType: CoordinatorType) {
		self.seasonsViewViewModel = viewModel
		self.seasonsView = .init(viewModel: viewModel)
		self.coordinatorType = coordinatorType
		super.init(nibName: nil, bundle: nil)
		seasonsView.delegate = self
	}

	override func setupUI() {
		view.addSubview(seasonsView)
		seasonsView.fixSwipePopGesture(for: navigationController!)

		super.setupUI()
		layoutUI()
	}

	override func didTapLeftBarButton() {
		switch coordinatorType {
			case .details(let tvShowDetailsCoordinator):
				tvShowDetailsCoordinator.eventOccurred(with: .backButtonTapped)

			case .tracked(let trackedTVShowsCoordinator):
				trackedTVShowsCoordinator.eventOccurred(with: .backButtonTapped)
		}
	}

	// ! Private

	private func layoutUI() {
		seasonsView.translatesAutoresizingMaskIntoConstraints = false
		view.pinViewToSafeAreas(seasonsView)
	}

}

// ! SeasonsViewDelegate

extension SeasonsVC: SeasonsViewDelegate {

	func seasonsView(_ seasonsView: SeasonsView, didSelect season: Season, from tvShow: TVShow) {
		switch coordinatorType {
			case .details(let tvShowDetailsCoordinator):
				tvShowDetailsCoordinator.eventOccurred(with: .seasonCellTapped(tvShow: tvShow, season: season))

			case .tracked(let trackedTVShowsCoordinator):
				trackedTVShowsCoordinator.eventOccurred(with: .seasonCellTapped(tvShow: tvShow, season: season))
		}
	}

}
