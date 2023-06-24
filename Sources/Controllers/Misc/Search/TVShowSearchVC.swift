import UIKit

/// Controller that'll show the TV show search list view
final class TVShowSearchVC: UIViewController {

	var coordinator: ExploreCoordinator?

	private let tvShowSearchListView = TVShowSearchListView()

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
		tvShowSearchListView.fadeInTextField()
		tvShowSearchListView.becomeTextFieldFirstResponder()
	}

 	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		coordinator?.eventOccurred(with: .poppedVC)
		tvShowSearchListView.fadeOutTextField()
		tvShowSearchListView.resignTextFieldFirstResponder()
	}

}

// ! TVShowSearchListViewDelegate

extension TVShowSearchVC: TVShowSearchListViewDelegate {

	func tvShowSearchListView(_ tvShowSearchListView: TVShowSearchListView, didSelect tvShow: TVShow) {
		coordinator?.eventOccurred(with: .tvShowCellTapped(tvShow: tvShow))
	}

	func didTapCloseButton(in searchTextFieldView: SearchTextFieldView) {
		coordinator?.eventOccurred(with: .closeButtonTapped)
	}

	func didTapClearButton(in searchTextFieldView: SearchTextFieldView) {
		searchTextFieldView.textField.text = ""
	}

}
