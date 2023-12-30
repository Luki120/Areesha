import UIKit

/// Controller that'll show the tv show seasons view
final class SeasonsVC: BaseVC {

	let seasonsViewViewModel: SeasonsViewViewModel
	private let seasonsView: SeasonsView

	var coordinator: TVShowDetailsCoordinator?

	override var titleView: UIView {
		return seasonsView.titleLabel
	}

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this vc's view
	init(viewModel: SeasonsViewViewModel) {
		self.seasonsViewViewModel = viewModel
		self.seasonsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)
		seasonsView.delegate = self
	}

	override func setupUI() {
		view.addSubview(seasonsView)
		super.setupUI()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		layoutUI()
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

	// ! Private

	private func layoutUI() {
		seasonsView.translatesAutoresizingMaskIntoConstraints = false
		view.pinViewToSafeAreas(seasonsView)
	}

}

// ! SeasonsViewDelegate

extension SeasonsVC: SeasonsViewDelegate {

	func seasonsView(_ seasonsView: SeasonsView, didSelect season: Season, from tvShow: TVShow) {
		coordinator?.eventOccurred(with: .seasonCellTapped(tvShow: tvShow, season: season))
	}

}
