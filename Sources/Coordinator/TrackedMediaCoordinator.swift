import UIKit

/// Coordinator class for managing navigation events related to `TrackedMediaVC`
@MainActor
final class TrackedMediaCoordinator: Coordinator {
	enum Event {
		case cellTapped(indexPath: IndexPath)
		case backButtonTapped
		case starButtonTapped(object: ObjectType)
		case trackedTVShowCellTapped(trackedTVShow: TrackedTVShow)
		case ratedTVShowCellTapped(ratedTVShow: RatedTVShow)
		case sortButtonTapped(
			viewModel: CurrentlyWatchingListViewViewModel,
			option: TrackedTVShowManager.SortOption
		)
		case ratedMovieCellTapped(movie: Movie)
		case seasonsButtonTapped(tvShow: TVShow)
		case seasonCellTapped(tvShow: TVShow, season: Season)
		case popVC
	}

	var navigationController = SwipeableNavigationController()
	private var childCoordinators = [any Coordinator]()

	init() {
		let trackedMediaVC = TrackedMediaVC()
		trackedMediaVC.coordinator = self
		trackedMediaVC.title = "Media"
		trackedMediaVC.tabBarItem = UITabBarItem(title: "Media", image: UIImage(asset: .movie), tag: 2)

		navigationController.viewControllers = [trackedMediaVC]
		navigationController.completion = { [weak self] fromVC in
			guard let seasonsVC = fromVC as? SeasonsVC else { return }
			switch seasonsVC.coordinatorType {
				case .details: break
				case .tracked(let trackedCoordinator): self?.childDidFinish(trackedCoordinator)
			}			
		}
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

					case 2:
						let ratedMoviesVC = RatedMoviesVC()
						ratedMoviesVC.coordinator = self
						navigationController.pushViewController(ratedMoviesVC, animated: true)
	
					default: break
				}

			case .backButtonTapped, .popVC: navigationController.popViewController(animated: true)

			case .starButtonTapped(let object):
				let viewModel = RatingViewViewModel(
					object: object,
					posterPath: object.coverImage ?? "",
					backdropPath: object.backgroundCoverImage ?? ""
				)
				let ratingVC = RatingVC(viewModel: viewModel, coordinatorType: .tracked(self))
				navigationController.pushViewController(ratingVC, animated: true)

			case .ratedTVShowCellTapped(let ratedTVShow):
				guard let tvShow = ratedTVShow.tvShow else { return }

				let viewModel = TVShowDetailsViewViewModel(tvShow: tvShow)
				let detailsVC = TVShowDetailsVC(viewModel: viewModel, coordinatorType: .tracked(self))
				navigationController.pushViewController(detailsVC, animated: true)

			case .trackedTVShowCellTapped(let trackedTVShow):
				let viewModel = TrackedTVShowDetailsViewViewModel(trackedTVShow: trackedTVShow)
				let trackedTVShowDetailsVC = TrackedTVShowDetailsVC(viewModel: viewModel)
				trackedTVShowDetailsVC.coordinator = self
				navigationController.pushViewController(trackedTVShowDetailsVC, animated: true)

			case .sortButtonTapped(let viewModel, let sortOption):
				viewModel.didSortDataSource(withOption: sortOption)

			case .ratedMovieCellTapped(let movie):
				let viewModel = MovieDetailsViewViewModel(movie: movie)
				let detailVC = MovieDetailsVC(viewModel: viewModel, coordinatorType: .tracked(self))
				self.navigationController.pushViewController(detailVC, animated: true)

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
