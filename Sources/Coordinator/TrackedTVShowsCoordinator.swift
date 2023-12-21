import UIKit

/// Explore coordinator, which will take care of any navigation events related to TrackedTVShowsVC
final class TrackedTVShowsCoordinator: Coordinator {

	enum Event {
		case backButtonTapped
		case trackedTVShowCellTapped(trackedTVShow: TrackedTVShow)
		case sortButtonTapped(viewModel: TrackedTVShowListViewViewModel, option: TrackedTVShowManager.SortOption)
	}

	var navigationController = SwipeableNavigationController()

	init() {
		let trackedTVShowsVC = TrackedTVShowsVC()
		trackedTVShowsVC.coordinator = self
		trackedTVShowsVC.title = "Shows"
		trackedTVShowsVC.tabBarItem = UITabBarItem(title: "Shows", image: UIImage(named: "Movie"), tag: 2)

		navigationController.viewControllers = [trackedTVShowsVC]
	}

	func eventOccurred(with event: Event) {
		switch event {
			case .backButtonTapped:
				navigationController.popViewController(animated: true)

			case .trackedTVShowCellTapped(let trackedTVShow):
				let viewModel = TrackedTVShowDetailsViewViewModel(trackedTVShow: trackedTVShow)
				let trackedTVShowDetailsVC = TrackedTVShowDetailsVC(viewModel: viewModel)
				trackedTVShowDetailsVC.coordinator = self
				navigationController.pushViewController(trackedTVShowDetailsVC, animated: true)

			case .sortButtonTapped(let viewModel, let sortOption):
				viewModel.didSortDataSource(withOption: sortOption)
		}
	}

}
