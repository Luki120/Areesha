import UIKit

/// Controller that'll show the rating view
final class RatingVC: BaseVC {
	private let viewModel: RatingViewViewModel
	private let ratingView: RatingView

	var coordinator: ExploreCoordinator?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this vc's view
	init(viewModel: RatingViewViewModel) {
		self.viewModel = viewModel
		self.ratingView = .init(viewModel: viewModel)
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		(UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		(UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

	@objc
	private func didTapRightBarButton() {
		ratingView.fadeInOutSlider()
	}
}

// ! RatingViewDelegate

extension RatingVC: RatingViewDelegate {
	func didAddRating(in ratingView: RatingView) {
		coordinator?.eventOccurred(with: .popVC)
	}
}
