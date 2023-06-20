import UIKit

/// Controller that'll show the tv show details view
final class TVShowDetailsVC: UIViewController {

	let tvShowDetailsViewViewModel: TVShowDetailsViewViewModel
	private let tvShowDetailsView: TVShowDetailsView

	var coordinator: ExploreCoordinator?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: The view model object for this vc's view
	init(viewModel: TVShowDetailsViewViewModel) {
		self.tvShowDetailsViewViewModel = viewModel
		self.tvShowDetailsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)

		tvShowDetailsView.delegate = self
	}

	override func loadView() { view = tvShowDetailsView }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

 	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tvShowDetailsView.titleLabel.isHidden = true
	}

	// ! Private

	private func setupUI() {
		navigationItem.titleView = tvShowDetailsView.titleLabel
		navigationItem.leftBarButtonItem = .createBackBarButtonItem(
			forTarget: self,
			selector: #selector(didTapBackButton)
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

// ! TVShowDetailsViewDelegate

extension TVShowDetailsVC: TVShowDetailsViewDelegate {

	func didTapSeasonsButton(in tvShowDetailsView: TVShowDetailsView) {
		coordinator?.eventOccurred(with: .seasonsButtonTapped(tvShow: tvShowDetailsViewViewModel.tvShow))
	}

}
