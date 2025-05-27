import UIKit

/// Controller that'll show the main tv shows list
final class ExploreVC: UIViewController {
	var coordinator: ExploreCoordinator?
	private var previousVC: UIViewController?
	private var isInitiallyInHomeVC = true

	private let tvShowHostView = TVShowHostView()

	// ! Lifecycle

	override func loadView() { view = tvShowHostView }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		tabBarController?.delegate = self
		tvShowHostView.delegate = self
	}

	// ! Private

	private func setupUI() {
		view.backgroundColor = .systemBackground

		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .search,
			target: self,
			action: #selector(didTapSearchButton)
		)
	}

	@objc
	private func didTapSearchButton() {
		coordinator?.eventOccurred(with: .searchButtonTapped)
	}
}

// ! TVShowHostViewDelegate

extension ExploreVC: TVShowHostViewDelegate {
	func tvShowHostView(_ tvShowHostView: TVShowHostView, didSelect tvShow: TVShow) {
		coordinator?.eventOccurred(with: .tvShowCellTapped(tvShow: tvShow))
	}
}

// ! UITabBarControllerDelegate

extension ExploreVC: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if previousVC == viewController || isInitiallyInHomeVC {
			guard let navVC = viewController as? UINavigationController,
				let vc = navVC.viewControllers.first as? ExploreVC,
				vc.view.window != nil else { return }

			tvShowHostView.scrollToTop()
			isInitiallyInHomeVC = false
		}
		previousVC = viewController
	}
}
