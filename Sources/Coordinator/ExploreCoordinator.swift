import UIKit

/// Explore coordinator, which will take care of any navigation events related to ARExploreVC
final class ExploreCoordinator: NSObject, Coordinator {

	enum Event {
		case tvShowCellTapped(tvShow: TVShow)
		case backButtonTapped
		case searchButtonTapped
		case closeButtonTapped
		case pushedVC
		case poppedVC
	}

	var navigationController = UINavigationController()

	override init() {
		super.init()
		let exploreVC = ARExploreVC()
		exploreVC.title = "Explore"
		exploreVC.coordinator = self
		exploreVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 0)

		navigationController.delegate = self
		navigationController.viewControllers = [exploreVC]
	}

	func eventOccurred(with event: Event) {
		switch event {
			case .tvShowCellTapped(let tvShow):
				let viewModel = ARTVShowDetailsViewViewModel(tvShow: tvShow)
				let detailVC = TVShowDetailsVC(viewModel: viewModel)
				detailVC.coordinator = self
				navigationController.pushViewController(detailVC, animated: true)

			case .backButtonTapped, .closeButtonTapped:
				navigationController.popViewController(animated: true)

			case .searchButtonTapped:
				let searchVC = ARTVShowSearchVC()
				searchVC.coordinator = self
				navigationController.pushViewController(searchVC, animated: true)

			case .pushedVC: navigationController.navigationBar.isHidden = true
			case .poppedVC: navigationController.navigationBar.isHidden = false
		}
	}

}

// ! UINavigationControllerDelegate

extension ExploreCoordinator: UINavigationControllerDelegate {

	func navigationController(
		_ navigationController: UINavigationController,
		animationControllerFor operation: UINavigationController.Operation,
		from fromVC: UIViewController,
		to toVC: UIViewController
	) -> UIViewControllerAnimatedTransitioning? {
		/// Class to use neat custom transitions when pushing & popping vcs into the stack
		final class ARPushPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
			func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
				return 0.35
			}

			func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
				let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
				guard let vc = toVC else { return }

				transitionContext.containerView.addSubview(vc.view)

				vc.view.alpha = 0

				UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .transitionCrossDissolve, animations: {
					vc.view.alpha = 1
				}) { _ in
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				}
			}
		}
		return ARPushPopAnimator()
	}

}

// https://icons8.com/icon/EYpsuynPA2Ra/clapperboard
