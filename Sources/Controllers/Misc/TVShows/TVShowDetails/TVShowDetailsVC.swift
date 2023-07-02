import UIKit

/// Controller that'll show the tv show details view
final class TVShowDetailsVC: BaseVC {

	let tvShowDetailsViewViewModel: TVShowDetailsViewViewModel
	private let tvShowDetailsView: TVShowDetailsView

	override var titleView: UIView {
		return tvShowDetailsView.titleLabel
	}

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

 	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tvShowDetailsView.titleLabel.isHidden = true
	}

}

// ! TVShowDetailsViewDelegate

extension TVShowDetailsVC: TVShowDetailsViewDelegate {

	func didTapSeasonsButton(in tvShowDetailsView: TVShowDetailsView) {
		coordinator?.eventOccurred(with: .seasonsButtonTapped(tvShow: tvShowDetailsViewViewModel.tvShow))
	}

}
