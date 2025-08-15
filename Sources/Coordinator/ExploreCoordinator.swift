import Combine
import UIKit

/// Coordinator class for managing navigation events related to `ExploreVC`
@MainActor
final class ExploreCoordinator: NSObject, Coordinator {
	enum Event {
		case objectCellTapped(object: ObjectType)
		case tvShowCellTapped(tvShow: TVShow)
		case backButtonTapped
		case starButtonTapped(object: ObjectType)
		case markAsWatchedButtonTapped(viewModel: TVShowDetailsViewViewModel)
		case searchButtonTapped
		case closeButtonTapped
		case pushedVC
		case poppedVC
		case popVC
	}

	var navigationController = SwipeableNavigationController()
	private var subscriptions = Set<AnyCancellable>()
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
			switch seasonsVC.coordinatorType {
				case .details(let tvShowDetailsCoordinator): self?.childDidFinish(tvShowDetailsCoordinator)
				case .tracked: break
			}
		}
	}

	func eventOccurred(with event: Event) {
		switch event {
			case .objectCellTapped(let object):
				switch object.type {
					case .tv:
						Task {
							await Service.sharedInstance.fetchDetails(for: object.id, expecting: TVShow.self)
								.receive(on: DispatchQueue.main)
								.sink(receiveCompletion: { _ in }) { [weak self] tvShow, _ in
									self?.pushDetailsVC(for: tvShow)
								}
								.store(in: &subscriptions)
						}

					case .movie:
						Task {
							await Service.sharedInstance.fetchDetails(
								for: object.id,
								isMovie: true,
								expecting: Movie.self
							)
							.receive(on: DispatchQueue.main)
							.sink(receiveCompletion: { _ in }) { [weak self] movie, _ in
								let viewModel = MovieDetailsViewViewModel(movie: movie)
								let detailVC = MovieDetailsVC(
									viewModel: viewModel,
									coordinatorType: .explore
								)
								detailVC.coordinator = self
								self?.navigationController.pushViewController(detailVC, animated: true)
							}
							.store(in: &subscriptions)
						}

					default: break
				}

			case .tvShowCellTapped(let tvShow): pushDetailsVC(for: tvShow)

			case .backButtonTapped, .closeButtonTapped:
				navigationController.popViewController(animated: true)

			case .starButtonTapped(let object):
				let viewModel = RatingViewViewModel(
					object: object,
					posterPath: object.coverImage ?? "",
					backdropPath: object.backgroundCoverImage ?? ""
				)
				let ratingVC = RatingVC(viewModel: viewModel, coordinatorType: .explore)
				ratingVC.coordinator = self
				navigationController.pushViewController(ratingVC, animated: true)

			case .markAsWatchedButtonTapped(let viewModel): viewModel.markShowAsWatched()

			case .searchButtonTapped:
				let searchVC = SearchVC()
				searchVC.coordinator = self
				navigationController.pushViewController(searchVC, animated: true)

			case .pushedVC: navigationController.navigationBar.isHidden = true
			case .poppedVC: navigationController.navigationBar.isHidden = false

			case .popVC: navigationController.popViewController(animated: true)
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

	private func pushDetailsVC(for tvShow: TVShow) {
		let viewModel = TVShowDetailsViewViewModel(tvShow: tvShow)
		let detailVC = TVShowDetailsVC(viewModel: viewModel, coordinatorType: .explore)
		detailVC.coordinator = self
		navigationController.pushViewController(detailVC, animated: true)
	}
}

/// Custom `UINavigationController` subclass to reenable swipe behavior with custom push/pop transitions
@MainActor
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
