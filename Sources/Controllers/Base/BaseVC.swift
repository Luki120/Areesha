import UIKit

/// Base view controller to provide a reusable navigation bar button & title view
class BaseVC: UIViewController {
	/// Variable available to subclasses to represent the title view
	var titleView: UIView { return UIView() }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	/// Function to setup the UI
	func setupUI() {
		let roundedBlurredButton: RoundedBlurredButton = .init(systemImage: "chevron.backward")
		roundedBlurredButton.addTarget(self, action: #selector(didTapLeftBarButton), for: .touchUpInside)

		navigationItem.titleView = titleView
		navigationItem.leftBarButtonItem = .init(customView: roundedBlurredButton)
		navigationItem.leftBarButtonItem?.tintColor = .label
		view.backgroundColor = .systemBackground
	}

	/// Function available to subclasses to perform an action when the left bar button is tapped
	@objc
	func didTapLeftBarButton() {}
}
