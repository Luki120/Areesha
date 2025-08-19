import UIKit

/// Controller that'll show the rating view
final class RatingVC: BaseVC {
	private let viewModel: RatingViewViewModel
	private let ratingView: RatingView
	private let coordinatorType: CoordinatorType

	var coordinator: ExploreCoordinator?

	override var titleView: UIView { ratingView.titleLabel }

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
	///		- coordinatorType: The `CoordinatorType` object that'll handle this vc's events
	init(viewModel: RatingViewViewModel, coordinatorType: CoordinatorType) {
		self.viewModel = viewModel
		self.ratingView = .init(viewModel: viewModel)
		self.coordinatorType = coordinatorType
		super.init(nibName: nil, bundle: nil)
	}

	override func loadView() {
		view = ratingView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		ratingView.delegate = self

		let roundedBlurredButton: RoundedBlurredButton = .init(systemImage: "arrow.up.arrow.down")
		roundedBlurredButton.addTarget(self, action: #selector(didTapRightBarButton), for: .touchUpInside)

		navigationItem.rightBarButtonItem = .init(customView: roundedBlurredButton)
	}

	override func didTapLeftBarButton() {
		switch coordinatorType {
			case .explore: coordinator?.eventOccurred(with: .backButtonTapped)
			case .tracked(let trackedCoordinator): trackedCoordinator.eventOccurred(with: .backButtonTapped)
		}
	}

	@objc
	private func didTapRightBarButton() {
		ratingView.fadeInOutSlider()
	}
}

// ! RatingViewDelegate

extension RatingVC: RatingViewDelegate {
	func didAddRating(in ratingView: RatingView) {
		switch coordinatorType {
			case .explore: coordinator?.eventOccurred(with: .popVC)
			case .tracked(let trackedCoordinator): trackedCoordinator.eventOccurred(with: .popVC)
		}
	}
}
