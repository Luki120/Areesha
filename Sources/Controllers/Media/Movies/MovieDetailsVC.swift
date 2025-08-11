import UIKit

/// Controller that'll show the movie details view
final class MovieDetailsVC: BaseVC {
	let viewModel: MovieDetailsViewViewModel
	private let movieDetailsView: MovieDetailsView

	var coordinator: ExploreCoordinator?

	override var titleView: UIView {
		return movieDetailsView.titleLabel
	}

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this vc's view
	init(viewModel: MovieDetailsViewViewModel) {
		self.viewModel = viewModel
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
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

	@objc
	private func didTapRightBarButton() {
		let object = ObjectType(from: viewModel.movie)
		coordinator?.eventOccurred(with: .starButtonTapped(object: object))
	}
}
