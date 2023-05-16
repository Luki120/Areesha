import UIKit

/// Controller that'll show the tv show seasons view
final class TVShowSeasonsVC: UIViewController {

	let tvShowSeasonsViewViewModel: TVShowSeasonsViewViewModel
	let tvShowSeasonsView: TVShowSeasonsView

	var coordinator: ExploreCoordinator?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: the view model object for this vc's view
	init(viewModel: TVShowSeasonsViewViewModel) {
		self.tvShowSeasonsViewViewModel = viewModel
		self.tvShowSeasonsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
	}

	override func loadView() { view = tvShowSeasonsView }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	// ! Private

	private func setupUI() {
		navigationItem.titleView = tvShowSeasonsView.titleLabel
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
