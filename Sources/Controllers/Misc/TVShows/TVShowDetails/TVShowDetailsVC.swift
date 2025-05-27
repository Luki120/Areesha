import UIKit

/// Controller that'll show the tv show details view
final class TVShowDetailsVC: BaseVC {
	let tvShowDetailsViewViewModel: TVShowDetailsViewViewModel
	private let tvShowDetailsView: TVShowDetailsView

	var coordinator: ExploreCoordinator?

	override var titleView: UIView {
		return tvShowDetailsView.titleLabel
	}

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this vc's view
	init(viewModel: TVShowDetailsViewViewModel) {
		self.tvShowDetailsViewViewModel = viewModel
		self.tvShowDetailsView = .init(viewModel: viewModel)
		super.init(nibName: nil, bundle: nil)

		tvShowDetailsView.delegate = self
	}

	override func loadView() { view = tvShowDetailsView }

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = .init(
			image: .init(systemName: "star"),
			style: .done,
			target: self,
			action: #selector(didTapRightBarButton)
		)
		navigationItem.rightBarButtonItem?.tintColor = .label
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tvShowDetailsView.titleLabel.isHidden = true
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}

	@objc
	private func didTapRightBarButton() {
		coordinator?.eventOccurred(with: .starButtonTapped(tvShow: tvShowDetailsViewViewModel.tvShow))
	}
}

// ! TVShowDetailsViewDelegate

extension TVShowDetailsVC: TVShowDetailsViewDelegate {
	func didTapSeasonsButton(in tvShowDetailsView: TVShowDetailsView) {
		coordinator?.pushSeasonsVC(for: tvShowDetailsViewViewModel.tvShow)
	}
}
