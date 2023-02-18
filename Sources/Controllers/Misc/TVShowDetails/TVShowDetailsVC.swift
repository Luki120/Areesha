import UIKit

/// Controller that'll show the tv show details view
final class TVShowDetailsVC: UIViewController {

	let tvShowDetailsViewViewModel: ARTVShowDetailsViewViewModel
	let tvShowDetailsView: ARTVShowDetailsView

	var coordinator: ExploreCoordinator?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: the view model object for this vc's view
	init(viewModel: ARTVShowDetailsViewViewModel) {
		self.tvShowDetailsViewViewModel = viewModel
		self.tvShowDetailsView = ARTVShowDetailsView(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
	}

	override func loadView() { view = tvShowDetailsView }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	// ! Private

	private func setupUI() {
		navigationItem.titleView = tvShowDetailsView.titleLabel
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "chevron.backward.circle"),
			style: .plain,
			target: self,
			action: #selector(didTapBackButton)
		)
		navigationItem.leftBarButtonItem?.tintColor = .label
		view.backgroundColor = .systemBackground
	}

	// ! Selectors

	@objc
	private func didTapBackButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

}
