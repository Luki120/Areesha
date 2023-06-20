import UIKit

/// Controller that'll show the episodes view
final class EpisodesVC: UIViewController {

	let episodesViewViewModel: EpisodesViewViewModel
	private let episodesView: EpisodesView

	var coordinator: ExploreCoordinator?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: The view model object for this vc's view
	init(viewModel: EpisodesViewViewModel) {
		self.episodesViewViewModel = viewModel
		self.episodesView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
	}

	override func loadView() { view = episodesView }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	// ! Private

	private func setupUI() {
		navigationItem.titleView = episodesView.titleLabel
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
