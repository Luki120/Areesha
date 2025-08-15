import UIKit

/// Coordinator class for managing navigation events related to `TVShowDetailsVC`
@MainActor
final class TVShowDetailsCoordinator: Coordinator {
	enum Event {
		case backButtonTapped
		case seasonsButtonTapped(tvShow: TVShow)
		case seasonCellTapped(tvShow: TVShow, season: Season)
	}

	var navigationController = SwipeableNavigationController()

	func eventOccurred(with event: Event) {
		switch event {
			case .backButtonTapped: navigationController.popViewController(animated: true)

			case .seasonsButtonTapped(let tvShow):
				let viewModel = SeasonsViewViewModel(tvShow: tvShow)
				let seasonsVC = SeasonsVC(viewModel: viewModel, coordinatorType: .details(self))
				navigationController.pushViewController(seasonsVC, animated: true)

			case .seasonCellTapped(let tvShow, let season):
				let viewModel = EpisodesViewViewModel(tvShow: tvShow, season: season)
				let episodesVC = EpisodesVC(viewModel: viewModel, coordinatorType: .details(self))
				navigationController.pushViewController(episodesVC, animated: true)
		}
	}
}
