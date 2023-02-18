import UIKit

/// Controller that'll show the TV show search list view
final class ARTVShowSearchVC: UIViewController {

	var coordinator: ExploreCoordinator?

	private let tvShowSearchListView = ARTVShowSearchListView()

	// ! Lifecycle

	override func loadView() { view = tvShowSearchListView }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		navigationItem.leftBarButtonItem = UIBarButtonItem()
		tvShowSearchListView.delegate = self
	}

 	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		coordinator?.eventOccurred(with: .pushedVC)
	}

 	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		coordinator?.eventOccurred(with: .poppedVC)
	}

}

// ! ARTVShowSearchListViewDelegate

extension ARTVShowSearchVC: ARTVShowSearchListViewDelegate {

	func didTapCloseButtonInTVShowSearchListView() {
		coordinator?.eventOccurred(with: .closeButtonTapped)
	}

	func arTVShowSearchListView(_ arTVShowSearchListView: ARTVShowSearchListView, didSelect tvShow: TVShow) {
		coordinator?.eventOccurred(with: .tvShowCellTapped(tvShow: tvShow))
	}

}
