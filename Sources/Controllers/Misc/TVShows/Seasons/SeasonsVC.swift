import UIKit

/// Controller that'll show the tv show seasons view
final class SeasonsVC: UIViewController {

	let seasonsViewViewModel: SeasonsViewViewModel
	private let seasonsView: SeasonsView

	var coordinator: ExploreCoordinator?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: The view model object for this vc's view
	init(viewModel: SeasonsViewViewModel) {
		self.seasonsViewViewModel = viewModel
		self.seasonsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
		seasonsView.delegate = self
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
		view.addSubview(seasonsView)

		navigationItem.titleView = seasonsView.titleLabel
		navigationItem.leftBarButtonItem = .createBackBarButtonItem(
			forTarget: self,
			selector: #selector(didTapBackButton)
		)
		navigationItem.leftBarButtonItem?.tintColor = .label
		view.backgroundColor = .systemBackground
	}

	private func layoutUI() {
		seasonsView.translatesAutoresizingMaskIntoConstraints = false
		view.pinViewToSafeAreas(seasonsView)
	}

	// ! Selectors

	@objc
	private func didTapBackButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

}

// ! SeasonsViewDelegate

extension SeasonsVC: SeasonsViewDelegate {

	func seasonsView(_ seasonsView: SeasonsView, didSelect season: Season, from tvShow: TVShow) {
		coordinator?.eventOccurred(with: .seasonCellTapped(tvShow: tvShow, season: season))
	}

}
