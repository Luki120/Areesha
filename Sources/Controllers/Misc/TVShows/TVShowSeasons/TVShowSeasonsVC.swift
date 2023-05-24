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
		tvShowSeasonsView.delegate = self
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
		navigationItem.leftBarButtonItem = .createBackBarButtonItem(
			forTarget: self,
			selector: #selector(didTapBackButton)
		)
		navigationItem.leftBarButtonItem?.tintColor = .label
		view.backgroundColor = .systemBackground
	}

	private func layoutUI() {
		tvShowSeasonsView.translatesAutoresizingMaskIntoConstraints = false
		view.pinViewToSafeAreas(tvShowSeasonsView)
	}

	// ! Selectors

	@objc
	private func didTapBackButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

}

// ! TVShowSeasonsViewDelegate

extension TVShowSeasonsVC: TVShowSeasonsViewDelegate {

	func tvShowSeasonsView(_ tvShowSeasonsView: TVShowSeasonsView, didSelect season: Season, from tvShow: TVShow) {
		coordinator?.eventOccurred(with: .seasonCellTapped(tvShow: tvShow, season: season))
	}

}
