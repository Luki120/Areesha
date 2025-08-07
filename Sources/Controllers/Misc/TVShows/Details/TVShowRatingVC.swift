import UIKit

/// Controller that'll show the tv show rating view
final class TVShowRatingVC: BaseVC {
	private let viewModel: TVShowRatingViewViewModel
	private let tvShowRatingView: TVShowRatingView

	var coordinator: ExploreCoordinator?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this vc's view
	init(viewModel: TVShowRatingViewViewModel) {
		self.viewModel = viewModel
		self.tvShowRatingView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
	}

	override func loadView() {
		view = tvShowRatingView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tvShowRatingView.delegate = self

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
		tvShowRatingView.fadeInOutSlider()
	}
}

// ! TVShowRatingViewDelegate

extension TVShowRatingVC: TVShowRatingViewDelegate {
	func didAddRating(in tvShowRatingView: TVShowRatingView) {
		coordinator?.eventOccurred(with: .popVC)
	}
}
