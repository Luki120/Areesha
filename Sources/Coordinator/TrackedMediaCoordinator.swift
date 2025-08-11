import UIKit

/// Tracked media coordinator, which will take care of any navigation events related to `TrackedMediaVC`
final class TrackedMediaCoordinator: Coordinator {
	enum Event {
		case cellTapped(indexPath: IndexPath)
		case backButtonTapped
		case trackedTVShowCellTapped(trackedTVShow: TrackedTVShow)
		case sortButtonTapped(
			viewModel: CurrentlyWatchingListViewViewModel,
			option: TrackedTVShowManager.SortOption
		)
		case seasonsButtonTapped(tvShow: TVShow)
		case seasonCellTapped(tvShow: TVShow, season: Season)
	}

	var navigationController = SwipeableNavigationController()

	init() {
		let trackedMediaVC = TrackedMediaVC()
		trackedMediaVC.coordinator = self
		trackedMediaVC.title = "Media"
		trackedMediaVC.tabBarItem = UITabBarItem(title: "Media", image: UIImage(asset: .movie), tag: 2)

		navigationController.viewControllers = [trackedMediaVC]
	}

	func eventOccurred(with event: Event) {
		switch event {
			case .cellTapped(let indexPath):
				switch indexPath.item {
					case 0:
						let currentlyWatchingTrackedTVShowsVC = CurrentlyWatchingVC()
						currentlyWatchingTrackedTVShowsVC.coordinator = self
						navigationController.pushViewController(currentlyWatchingTrackedTVShowsVC, animated: true)

					case 1:
						let finishedTrackedTVShowsVC = FinishedVC()
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

			case .seasonsButtonTapped(let tvShow):
				let viewModel = SeasonsViewViewModel(tvShow: tvShow)
				let seasonsVC = SeasonsVC(viewModel: viewModel, coordinatorType: .tracked(self))
				navigationController.pushViewController(seasonsVC, animated: true)

			case .seasonCellTapped(let tvShow, let season):
				let viewModel = EpisodesViewViewModel(tvShow: tvShow, season: season)
				let episodesVC = EpisodesVC(viewModel: viewModel, coordinatorType: .tracked(self))
				navigationController.pushViewController(episodesVC, animated: true)
		}
	}
}
