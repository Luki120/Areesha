import UIKit

/// Controller that'll show the episodes view
final class EpisodesVC: BaseVC {

	let episodesViewViewModel: EpisodesViewViewModel
	private let episodesView: EpisodesView

	var coordinator: TVShowDetailsCoordinator?

	override var titleView: UIView {
		return episodesView.titleLabel
	}

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

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

}
