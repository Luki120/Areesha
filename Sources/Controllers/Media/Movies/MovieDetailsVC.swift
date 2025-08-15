import UIKit

/// Controller that'll show the movie details view
final class MovieDetailsVC: BaseVC {
	private let viewModel: MovieDetailsViewViewModel
	private let coordinatorType: CoordinatorType
	private let movieDetailsView: MovieDetailsView

	var coordinator: ExploreCoordinator?

	override var titleView: UIView {
		return movieDetailsView.titleLabel
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
	///		- coordinatorType: The `CoordinatorType` object that'll handle this vc's events
	init(viewModel: MovieDetailsViewViewModel, coordinatorType: CoordinatorType) {
		self.viewModel = viewModel
		self.coordinatorType = coordinatorType
		self.movieDetailsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
	}

	override func loadView() { view = movieDetailsView }

	override func viewDidLoad() {
		super.viewDidLoad()

		let backButton: RoundedBlurredButton = .init(systemImage: "chevron.backward", isHeader: true)
		backButton.addTarget(self, action: #selector(didTapLeftBarButton), for: .touchUpInside)

		let rateButton: RoundedBlurredButton = .init(systemImage: "star", isHeader: true)
		rateButton.addTarget(self, action: #selector(didTapRightBarButton), for: .touchUpInside)

		navigationItem.leftBarButtonItem = .init(customView: backButton)
		navigationItem.rightBarButtonItem = .init(customView: rateButton)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		movieDetailsView.titleLabel.isHidden = true
	}

	override func didTapLeftBarButton() {
		switch coordinatorType {
			case .explore: coordinator?.eventOccurred(with: .backButtonTapped)
			case .tracked(let trackedCoordinator): trackedCoordinator.eventOccurred(with: .backButtonTapped)
		}
	}

	@objc
	private func didTapRightBarButton() {
		let object = ObjectType(from: viewModel.movie)

		switch coordinatorType {
			case .explore: coordinator?.eventOccurred(with: .starButtonTapped(object: object))

			case .tracked(let trackedCoordinator):
				trackedCoordinator.eventOccurred(with: .starButtonTapped(object: object))
		}
	}
}
