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

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupUI() {
		view.addSubview(tvShowSeasonsView)

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

	private func layoutUI() {
		tvShowSeasonsView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tvShowSeasonsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tvShowSeasonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			tvShowSeasonsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tvShowSeasonsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
		])
	}

	// ! Selectors

	@objc
	private func didTapBackButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}	

}
