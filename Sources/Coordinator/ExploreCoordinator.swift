import UIKit

/// Explore coordinator, which will take care of any navigation events related to ExploreVC
final class ExploreCoordinator: NSObject, Coordinator {

	enum Event {
		case tvShowCellTapped(tvShow: TVShow)
		case backButtonTapped
		case searchButtonTapped
		case closeButtonTapped
		case pushedVC
		case poppedVC
	}

	var navigationController = SwipeableNavigationController()
	private var childCoordinators: [any Coordinator] = []

	override init() {
		super.init()

		let exploreVC = ExploreVC()
		exploreVC.title = "Explore"
		exploreVC.coordinator = self
		exploreVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 0)

		navigationController.delegate = navigationController
		navigationController.viewControllers = [exploreVC]

		navigationController.completion = { [weak self] fromVC in
			guard let seasonsVC = fromVC as? SeasonsVC else { return }
			self?.childDidFinish(seasonsVC.coordinator)
		}
	}

	func eventOccurred(with event: Event) {
		switch event {
			case .tvShowCellTapped(let tvShow):
				let viewModel = TVShowDetailsViewViewModel(tvShow: tvShow)
				let detailVC = TVShowDetailsVC(viewModel: viewModel)
				detailVC.coordinator = self
				navigationController.pushViewController(detailVC, animated: true)

			case .backButtonTapped, .closeButtonTapped:
				navigationController.popViewController(animated: true)

			case .searchButtonTapped:
				let searchVC = TVShowSearchVC()
				searchVC.coordinator = self
				navigationController.pushViewController(searchVC, animated: true)

			case .pushedVC: navigationController.navigationBar.isHidden = true
			case .poppedVC: navigationController.navigationBar.isHidden = false
		}
	}

	func pushSeasonsVC(for tvShow: TVShow) {
		let child = TVShowDetailsCoordinator()
		child.navigationController = navigationController
		childCoordinators.append(child)
		child.eventOccurred(with: .seasonsButtonTapped(tvShow: tvShow))
	}

	private func childDidFinish(_ child: (any Coordinator)?) {
		guard let index = childCoordinators.firstIndex(where: { $0 === child }) else { return }
		childCoordinators.remove(at: index)
	}

}

/// Custom UINavigationController subclass to reenable swipe behavior with custom push/pop transitions
final class SwipeableNavigationController: UINavigationController {

	var completion: ((UIViewController) -> Void)?
	private var isPushAnimation = false

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init() {
		super.init(nibName: nil, bundle: nil)
		delegate = self
	}

	deinit {
		delegate = nil
		interactivePopGestureRecognizer?.delegate = nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		interactivePopGestureRecognizer?.delegate = self
	}

	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		isPushAnimation = true
		super.pushViewController(viewController, animated: animated)
	}

}

// ! UIGestureRecognizerDelegate

extension SwipeableNavigationController: UIGestureRecognizerDelegate {

	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard gestureRecognizer == interactivePopGestureRecognizer else { return true }
		return viewControllers.count > 1 && isPushAnimation == false
	}

}

// ! UINavigationControllerDelegate

extension SwipeableNavigationController: UINavigationControllerDelegate {

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		guard let swipeableNavigationController = navigationController as? SwipeableNavigationController else { return }
		swipeableNavigationController.isPushAnimation = false

		guard let fromViewController = swipeableNavigationController.transitionCoordinator?.viewController(forKey: .from) else {
			return
		}

		guard !swipeableNavigationController.viewControllers.contains(fromViewController) else { return }

		completion?(fromViewController)
	}

	func navigationController(
		_ navigationController: UINavigationController,
		animationControllerFor operation: UINavigationController.Operation,
		from fromVC: UIViewController,
		to toVC: UIViewController
	) -> UIViewControllerAnimatedTransitioning? {
		/// Class to use neat custom transitions when pushing & popping vcs into the stack
		final class PushPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
		return PushPopAnimator()
	}

}
