import UIKit

/// Controller that'll show the tv show details view
final class TVShowDetailsVC: BaseVC {
	let tvShowDetailsViewViewModel: TVShowDetailsViewViewModel
	private let coordinatorType: CoordinatorType
	private let tvShowDetailsView: TVShowDetailsView

	var coordinator: ExploreCoordinator?

	override var titleView: UIView {
		return tvShowDetailsView.titleLabel
	}

	enum CoordinatorType {
		case explore
		case tracked(TrackedMediaCoordinator)
	}

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this vc's view
	///		- coordinatorType: The type of coordinator that'll handle this vc's events
	init(viewModel: TVShowDetailsViewViewModel, coordinatorType: CoordinatorType) {
		self.tvShowDetailsViewViewModel = viewModel
		self.tvShowDetailsView = .init(viewModel: viewModel)
		self.coordinatorType = coordinatorType
		super.init(nibName: nil, bundle: nil)

		tvShowDetailsView.delegate = self
	}

	override func loadView() { view = tvShowDetailsView }

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.leftBarButtonItem = tvShowDetailsView.createBarButtonItem(
			systemImage: "chevron.backward",
			target: self,
			action: #selector(didTapLeftBarButton)
		)

		let rateButtonItem = tvShowDetailsView.createBarButtonItem(
			systemImage: "star",
			target: self,
			action: #selector(didTapRateButton)
		)

		navigationItem.rightBarButtonItem = rateButtonItem
		navigationItem.rightBarButtonItem?.tintColor = .label
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tvShowDetailsView.titleLabel.isHidden = true
	}

	override func didTapLeftBarButton() {
		switch coordinatorType {
			case .explore: coordinator?.eventOccurred(with: .backButtonTapped)
			case .tracked(let trackedCoordinator): trackedCoordinator.eventOccurred(with: .backButtonTapped)
		}
	}

	@objc
	private func didTapRateButton() {
		let object = ObjectType(from: tvShowDetailsViewViewModel.tvShow)

		switch coordinatorType {
			case .explore: coordinator?.eventOccurred(with: .starButtonTapped(object: object))

			case .tracked(let trackedCoordinator):
				trackedCoordinator.eventOccurred(with: .starButtonTapped(object: object))
		}
	}
}

// ! TVShowDetailsViewDelegate

extension TVShowDetailsVC: TVShowDetailsViewDelegate {
	func didTapSeasonsButton(in tvShowDetailsView: TVShowDetailsView) {
		switch coordinatorType {
			case .explore: coordinator?.pushSeasonsVC(for: tvShowDetailsViewViewModel.tvShow)

			case .tracked(let trackedCoordinator):
				trackedCoordinator.pushSeasonsVC(for: tvShowDetailsViewViewModel.tvShow)
		}
	}
}
