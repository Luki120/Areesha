import Combine
import UIKit

@MainActor
protocol CurrentlyWatchingListViewViewModelDelegate: AnyObject {
	func didSelect(trackedTVShow: TrackedTVShow)
}

/// View model class for `CurrentlyWatchingListView`
@MainActor
final class CurrentlyWatchingListViewViewModel: NSObject {
	private let trackedManager: TrackedTVShowManager = .sharedInstance
	private var subscriptions: Set<AnyCancellable> = []

	weak var delegate: CurrentlyWatchingListViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
	private typealias CellRegistration = UICollectionView.CellRegistration<TrackedTVShowListCell, TrackedTVShowCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, TrackedTVShowCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TrackedTVShowCellViewModel>

	private var dataSource: DataSource!

	var sectionIdentifiers: [Section] { dataSource.snapshot().sectionIdentifiers }

	enum Section: String {
		case currentlyWatching = "Currently watching"
		case returningSeries = "Returning series"

		var title: String { rawValue }
	}

	override init() {
		super.init()

		trackedManager.$trackedTVShows
			.sink { [unowned self] trackedTVShows in
				applySnapshot(withModels: trackedTVShows)
			}
			.store(in: &subscriptions)
	}

	private func getModelIndex(for indexPath: IndexPath) -> Int? {
		let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
		let relevantShows: [TrackedTVShow]

		switch section {
			case .currentlyWatching:
				relevantShows = trackedManager.trackedTVShows.filter { !$0.isReturningSeries }

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
	/// Function to setup the diffable data source for the collection view
	/// - Parameter collectionView: The `UICollectionView`
	func setupDiffableDataSource(for collectionView: UICollectionView) {
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
		applySnapshot(withModels: trackedManager.trackedTVShows)
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

	private func applySnapshot(withModels models: [TrackedTVShow]) {
		guard let dataSource else { return }

		let currentlyWatchingModels = models
			.filter { !$0.isReturningSeries }
			.map(TrackedTVShowCellViewModel.init(_:))

		let returningShowsModels = models
			.filter { $0.isReturningSeries }
			.map(TrackedTVShowCellViewModel.init(_:))

		var snapshot = Snapshot()

		if !currentlyWatchingModels.isEmpty {
			snapshot.appendSections([.currentlyWatching])
			snapshot.appendItems(currentlyWatchingModels, toSection: .currentlyWatching)
		}

		if !returningShowsModels.isEmpty {
			snapshot.appendSections([.returningSeries])
			snapshot.appendItems(returningShowsModels, toSection: .returningSeries)
		}

		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		switch sectionIdentifiers[indexPath.section] {
			case .currentlyWatching:
				let trackedTVShows = trackedManager.trackedTVShows.filter { !$0.isReturningSeries }
				delegate?.didSelect(trackedTVShow: trackedTVShows[indexPath.item])

			case .returningSeries:
				let trackedTVShows = trackedManager.trackedTVShows.filter { $0.isReturningSeries }
				delegate?.didSelect(trackedTVShow: trackedTVShows[indexPath.item])
		}
	}
}

// ! Public

extension CurrentlyWatchingListViewViewModel {
	/// Function to delete an item from the collection view
	/// - Parameter indexPath: The `IndexPath` for the item
	func deleteItem(at indexPath: IndexPath) {
		guard let index = getModelIndex(for: indexPath),
			let item = dataSource.itemIdentifier(for: indexPath) else { return }

		let show = trackedManager.trackedTVShows[index].tvShow

		Task {
			await NotificationActor.sharedInstance.removePendingNotificationRequests(for: show)
		}

		trackedManager.deleteTrackedTVShow(at: index)

		var snapshot = dataSource.snapshot()
		snapshot.deleteItems([item])
		dataSource.apply(snapshot)
	}

	/// Function to sort the tv show models according to the given option
	/// - Parameter option: The `SortOption`
	func didSortDataSource(withOption option: TrackedTVShowManager.SortOption) {
		trackedManager.didSortModels(withOption: option)
		applySnapshot(withModels: trackedManager.trackedTVShows)
	}

	/// Function to mark a currently watching show as returning series
	/// - Parameters:
	///		- indexPath: The `IndexPath` for the tv show
	///		- toggle: `Bool` value to toggle between returning series or currently watching
	func markShowAsReturningSeries(at indexPath: IndexPath, toggle: Bool = true) {
		guard let index = getModelIndex(for: indexPath) else { return }

		trackedManager.markShowAsReturningSeries(at: index, toggle: toggle)
		applySnapshot(withModels: trackedManager.trackedTVShows)
	}

	/// Function to track the next episode if available
	/// - Parameter indexPath: The current `IndexPath` for the item
	func trackNextEpisode(at indexPath: IndexPath) {
		guard let index = getModelIndex(for: indexPath) else { return }

		let tvShow = trackedManager.trackedTVShows[index].tvShow
		let currentSeason = trackedManager.trackedTVShows[index].season

		Task {
			await Service.sharedInstance.fetchDetails(for: tvShow.id, expecting: TVShow.self)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { _ in }) { [weak self] tvShow, _ in
					Task {
						await self?.fetchSeasonDetails(for: currentSeason, tvShow: tvShow, at: indexPath)
					}
				}
				.store(in: &subscriptions)
		}
	}
}

// ! Track next episode logic

extension CurrentlyWatchingListViewViewModel {
	private func fetchSeasonDetails(for season: Season, tvShow: TVShow, at indexPath: IndexPath) async {
		guard let index = getModelIndex(for: indexPath) else { return }

		let currentEpisode = trackedManager.trackedTVShows[index].episode

		await Service.sharedInstance.fetchSeasonDetails(for: season, tvShow: tvShow)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] season in
				guard let self else { return }

				if let episodes = season.episodes,
					let nextEpisode = episodes.first(where: { $0.number == (currentEpisode.number ?? 0) + 1 }) {
					track(tvShow: tvShow, season: season, episode: nextEpisode)
				}
				else {
					guard let seasons = tvShow.seasons,
						let nextSeason = seasons.first(where: { $0.number == (season.number ?? 0) + 1 }) else { return }

						Task {
							await Service.sharedInstance.fetchSeasonDetails(for: nextSeason, tvShow: tvShow)
								.receive(on: DispatchQueue.main)
								.sink(receiveCompletion: { _ in }) { [weak self] nextSeason in
									guard let firstEpisode = nextSeason.episodes?.first(where: { $0.number == 1 }) else { return }
									self?.track(tvShow: tvShow, season: nextSeason, episode: firstEpisode)
								}
								.store(in: &self.subscriptions)
						}
				}
			}
			.store(in: &self.subscriptions)
	}

	private func track(tvShow: TVShow, season: Season, episode: Episode) {
		let isTracked = trackedManager.track(tvShow: tvShow, season: season, episode: episode)
		if !isTracked {
			Task {
				await NotificationActor.sharedInstance.postNewEpisodeNotification(for: tvShow)
			}
		}

		applySnapshot(withModels: trackedManager.trackedTVShows)
	}
}
