import UIKit

/// Tracked tv shows coordinator, which will take care of any navigation events related to TrackedTVShowsVC
final class TrackedTVShowsCoordinator: Coordinator {

	enum Event {
		case cellTapped(indexPath: IndexPath)
		case backButtonTapped
		case trackedTVShowCellTapped(trackedTVShow: TrackedTVShow)
		case sortButtonTapped(
			viewModel: CurrentlyWatchingTrackedTVShowListViewViewModel,
			option: TrackedTVShowManager.SortOption
		)
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
			case .cellTapped(let indexPath):
				switch indexPath.item {
					case 0:
						let currentlyWatchingTrackedTVShowsVC = CurrentlyWatchingTrackedTVShowsVC()
						currentlyWatchingTrackedTVShowsVC.coordinator = self
						navigationController.pushViewController(currentlyWatchingTrackedTVShowsVC, animated: true)

					case 1:
						let finishedTrackedTVShowsVC = FinishedTrackedTVShowsVC()
						finishedTrackedTVShowsVC.coordinator = self
						navigationController.pushViewController(finishedTrackedTVShowsVC, animated: true)
	
					default: break
				}

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
