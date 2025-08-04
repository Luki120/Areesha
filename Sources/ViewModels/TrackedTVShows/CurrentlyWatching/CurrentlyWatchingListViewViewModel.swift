import Combine
import UIKit

protocol CurrentlyWatchingListViewViewModelDelegate: AnyObject {
	func didSelect(trackedTVShow: TrackedTVShow)
	func didShowToastView()
}

/// View model class for `CurrentlyWatchingListView`
final class CurrentlyWatchingListViewViewModel: NSObject {
	private let trackedManager: TrackedTVShowManager = .sharedInstance
	private var subscriptions: Set<AnyCancellable> = []
	private var tvShow: TVShow!

	weak var delegate: CurrentlyWatchingListViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
	private typealias CellRegistration = UICollectionView.CellRegistration<TrackedTVShowListCell, TrackedTVShowCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, TrackedTVShowCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TrackedTVShowCellViewModel>

	private var dataSource: DataSource!

	private enum Section: String {
		case currentlyWatching = "Currently watching"
		case returningSeries = "Returning series"

		var title: String { rawValue }
	}

	override init() {
		super.init()

		trackedManager.$trackedTVShows
			.sink { [unowned self] trackedTVShows in
				applyDiffableDataSourceSnapshot(withModels: trackedTVShows.filter { $0.isFinished == false })
			}
			.store(in: &subscriptions)
	}

	private func getModelIndex(for indexPath: IndexPath) -> Int? {
		let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
		let relevantShows: [TrackedTVShow]

		switch section {
			case .currentlyWatching:
				relevantShows = trackedManager.trackedTVShows.filter { $0.isFinished == false && !$0.isReturningSeries }

			case .returningSeries:
				relevantShows = trackedManager.trackedTVShows.filter { $0.isReturningSeries }
		}

		guard indexPath.item < relevantShows.count else { return nil }

		let selectedShow = relevantShows[indexPath.item]
		return trackedManager.trackedTVShows.firstIndex(where: { $0 == selectedShow })
	}	
}

// ! UICollectionView

extension CurrentlyWatchingListViewViewModel: UICollectionViewDelegate {
	private func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.viewModel = viewModel
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows.filter { $0.isFinished == false })
		setupSupplementaryRegistration()
	}

	private func setupSupplementaryRegistration() {
		let headerRegistration = HeaderRegistration(
			elementKind: UICollectionView.elementKindSectionHeader
		) { headerView, _, indexPath in
			let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

			var configuration = headerView.defaultContentConfiguration()
			var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()

			backgroundConfiguration.backgroundColor = .clear
			configuration.text = section.title

			headerView.backgroundConfiguration = backgroundConfiguration
			headerView.contentConfiguration = configuration
		}

		dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
			return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
		}
	}

	private func applyDiffableDataSourceSnapshot(withModels models: [TrackedTVShow]) {
		guard let dataSource else { return }

		let currentlyWatchingModels = models
			.filter { !$0.isFinished && !$0.isReturningSeries }
			.map(TrackedTVShowCellViewModel.init(_:))

		let returningShowsModels = models
			.filter { $0.isReturningSeries }
			.map(TrackedTVShowCellViewModel.init(_:))

		var snapshot = Snapshot()
		snapshot.appendSections([.currentlyWatching, .returningSeries])
		snapshot.appendItems(currentlyWatchingModels, toSection: .currentlyWatching)
		snapshot.appendItems(returningShowsModels, toSection: .returningSeries)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		switch indexPath.section {
			case 0:
				let trackedTVShows = trackedManager.trackedTVShows.filter { !$0.isFinished && !$0.isReturningSeries }
				delegate?.didSelect(trackedTVShow: trackedTVShows[indexPath.item])

			case 1:
				let trackedTVShows = trackedManager.trackedTVShows.filter { $0.isReturningSeries }
				delegate?.didSelect(trackedTVShow: trackedTVShows[indexPath.item])

			default: break
		}
	}
}

// ! Public

extension CurrentlyWatchingListViewViewModel {
	/// Function to delete an item from the collection view at the given index path
	/// - Parameter at: The `IndexPath` for the item
	func deleteItem(at indexPath: IndexPath) {
		guard let index = getModelIndex(for: indexPath),
			let item = dataSource.itemIdentifier(for: indexPath) else { return }

		NotificationManager.sharedInstance.removePendingNotificationRequests(
			for: trackedManager.trackedTVShows[index].tvShow
		)

		trackedManager.deleteTrackedTVShow(at: index)

		var snapshot = dataSource.snapshot()
		snapshot.deleteItems([item])
		dataSource.apply(snapshot)
	}

	/// Function to sort the tv show models according to the given option
	/// - Parameter option: The `SortOption`
	func didSortDataSource(withOption option: TrackedTVShowManager.SortOption) {
		trackedManager.didSortModels(withOption: option)
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows)
	}

	/// Function to mark a tv show as finished
	/// - Parameter at: The `IndexPath` for the item
	func finishedShow(at indexPath: IndexPath) {
		guard let index = getModelIndex(for: indexPath) else { return }

		trackedManager.finishedShow(at: index) { [weak self] isShowAdded in
			if isShowAdded { self?.delegate?.didShowToastView() }
		}
	}

	/// Function to mark a currently watching show as returning series
	/// - Parameters:
	///		- at: The `IndexPath` for the tv show
	///		- toggle: `Bool` value to toggle between returning series or currently watching
	func markShowAsReturningSeries(at indexPath: IndexPath, toggle: Bool = true) {
		guard let index = getModelIndex(for: indexPath) else { return }

		trackedManager.markShowAsReturningSeries(at: index, toggle: toggle)
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows)
	}

	/// Function to setup the diffable data source for the collection view
	/// - Parameter collectionView: The `UICollectionView`
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		setupCollectionViewDiffableDataSource(for: collectionView)
	}

	/// Function to track the next episode if available
	/// - Parameter at: The current `IndexPath` for the item
	func trackNextEpisode(at indexPath: IndexPath) {
		guard let index = getModelIndex(for: indexPath) else { return }

		let tvShow = trackedManager.trackedTVShows[index].tvShow
		let currentSeason = trackedManager.trackedTVShows[index].season
		let currentEpisode = trackedManager.trackedTVShows[index].episode

		Service.sharedInstance.fetchDetails(
			for: tvShow.id,
			expecting: TVShow.self,
			storeIn: &subscriptions
		) { [weak self] tvShow, _ in
			guard let self else { return }
			self.tvShow = tvShow

			Service.sharedInstance.fetchSeasonDetails(
				for: currentSeason,
				tvShow: tvShow,
				storeIn: &subscriptions
			) { [weak self] season in
				guard let self else { return }

				if let episodes = season.episodes,
					let nextEpisode = episodes.first(where: { $0.number == (currentEpisode.number ?? 0) + 1 }) {
					track(tvShow: tvShow, season: season, episode: nextEpisode)
				}
				else {
					guard let seasons = tvShow.seasons,
						let nextSeason = seasons.first(where: { $0.number == (currentSeason.number ?? 0) + 1 }) else { return }

					Service.sharedInstance.fetchSeasonDetails(
						for: nextSeason,
						tvShow: tvShow,
						storeIn: &subscriptions
					) { [weak self] nextSeason in
						guard let firstEpisode = nextSeason.episodes?.first(where: { $0.number == 1 }) else { return }
						self?.track(tvShow: tvShow, season: nextSeason, episode: firstEpisode)
					}
				}
			}
		}
	}
}

// ! Track next episode logic

extension CurrentlyWatchingListViewViewModel {
	private func track(tvShow: TVShow, season: Season, episode: Episode) {
		trackedManager.track(tvShow: tvShow, season: season, episode: episode) { isTracked in
			if !isTracked {
				Task {
					await NotificationManager.sharedInstance.postNewEpisodeNotification(for: self.tvShow)
				}
			}
		}
		applyDiffableDataSourceSnapshot(withModels: trackedManager.trackedTVShows)
	}
}
