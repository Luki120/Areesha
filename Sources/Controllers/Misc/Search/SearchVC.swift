import UIKit

/// Controller that'll show the TV show / movies search list view
final class SearchVC: UIViewController {
	var coordinator: ExploreCoordinator?

	private let searchListView = SearchListView()

	// ! Lifecycle

	override func loadView() { view = searchListView }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		navigationItem.leftBarButtonItem = UIBarButtonItem()
		searchListView.delegate = self
	}

 	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		coordinator?.eventOccurred(with: .pushedVC)
		searchListView.fadeInTextField()
		searchListView.becomeTextFieldFirstResponder()
	}

 	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		coordinator?.eventOccurred(with: .poppedVC)
		searchListView.fadeOutTextField()
		searchListView.resignTextFieldFirstResponder()
	}
}

// ! SearchListViewDelegate

extension SearchVC: SearchListViewDelegate {
	func searchListView(_ searchListView: SearchListView, didSelect object: ObjectType) {
		coordinator?.eventOccurred(with: .objectCellTapped(object: object))
	}

	func didTapCloseButton(in searchTextFieldView: SearchTextFieldView) {
		coordinator?.eventOccurred(with: .closeButtonTapped)
	}

	func didTapClearButton(in searchTextFieldView: SearchTextFieldView) {
		searchTextFieldView.textField.text = ""
	}
}
