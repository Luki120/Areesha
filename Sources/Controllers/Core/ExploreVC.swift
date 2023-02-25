import UIKit

/// Controller that'll show the main tv shows list
final class ExploreVC: UIViewController {

	var coordinator: ExploreCoordinator?
	private var previousVC: UIViewController?

	private let tvShowListView = TVShowListView()

	// ! Lifecycle

	override func loadView() { view = tvShowListView }

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		tabBarController?.delegate = self
		tvShowListView.delegate = self
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

// ! TVShowListViewDelegate

extension ExploreVC: TVShowListViewDelegate {

	func tvShowListView(_ tvShowListView: TVShowListView, didSelect tvShow: TVShow) {
		coordinator?.eventOccurred(with: .tvShowCellTapped(tvShow: tvShow))
	}

}

// ! UITabBarControllerDelegate

extension ExploreVC: UITabBarControllerDelegate {

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if previousVC == viewController || previousVC == nil {
			guard let navVC = viewController as? UINavigationController,
				let vc = navVC.viewControllers.first as? ExploreVC,
				vc.view.window != nil else { return }

			tvShowListView.collectionView.setContentOffset(
				CGPoint(x: 0, y: -tvShowListView.collectionView.safeAreaInsets.top),
				animated: true
			)
		}
		previousVC = viewController
	}

}
