import Combine
import UIKit

/// View model class for TrackedTVShowListView
final class TrackedTVShowListViewViewModel: NSObject {

	private var viewModels = OrderedSet<TrackedTVShowCollectionViewListCellViewModel>()

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<TrackedTVShowCollectionViewListCell, TrackedTVShowCollectionViewListCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, TrackedTVShowCollectionViewListCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, TrackedTVShowCollectionViewListCellViewModel>

	private var dataSource: DataSource!
	private var snapshot: Snapshot!

	@frozen private enum Sections {
		case main
	}

	override init() {
		super.init()
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didReceiveTrackedTVShowData(_:)),
			name: .didSendTrackedTVShowDataNotification,
			object: nil
		)

		guard let data = UserDefaults.standard.object(forKey: "viewModels") as? Data,
			let decodedViewModels = try? JSONDecoder().decode(OrderedSet<TrackedTVShowCollectionViewListCellViewModel>.self, from: data) else {
				viewModels = []
				return
			}

		viewModels = decodedViewModels
	}

	// ! Notification Center

	@objc
	private func didReceiveTrackedTVShowData(_ notification: Notification) {
		guard let tvShow = notification.userInfo?["tvShow"] as? TVShow,
			let season = notification.userInfo?["season"] as? Season,
			let episode = notification.userInfo?["episode"] as? Episode else { return }

		let urlString = "\(Service.Constants.baseImageURL)w500/\(episode.stillPath ?? "")"
		guard let url = URL(string: urlString),
			let seasonNumber = season.seasonNumber,
			let episodeNumber = episode.episodeNumber else { return }

		let isSeasonInDesiredRange = 1..<10 ~= seasonNumber
		let isEpisodeInDesiredRange = 1..<10 ~= episodeNumber
		let cleanSeasonNumber = isSeasonInDesiredRange ? "0\(seasonNumber)" : "\(seasonNumber)"
		let cleanSeasonEpisode = isEpisodeInDesiredRange ? "0\(episodeNumber)" : "\(episodeNumber)"

		let viewModel = TrackedTVShowCollectionViewListCellViewModel(
			imageURL: url,
			tvShowNameText: tvShow.name,
			lastSeenText: "Last seen: S\(cleanSeasonNumber)E\(cleanSeasonEpisode)"
		)

		viewModels.insert(viewModel)

		applyDiffableDataSourceSnapshot()
		encodeData()
	}

	// ! Private

	private func encodeData() {
		guard let encodedViewModels = try? JSONEncoder().encode(viewModels) else { return }
		UserDefaults.standard.set(encodedViewModels, forKey: "viewModels")		
	}

}

// ! UICollectionView

extension TrackedTVShowListViewViewModel: UICollectionViewDelegate {

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
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(Array(viewModels))
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
	}

}

// ! Public

extension TrackedTVShowListViewViewModel {

	/// Function to delete an item from the collection view at the given index path
	/// - Parameters:
	///     - at: The index path for the item
	func deleteItem(at indexPath: IndexPath) {
		viewModels.remove(at: indexPath.item)
		applyDiffableDataSourceSnapshot()
		encodeData()
	}

	/// Function to setup the diffable data source for the collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		setupCollectionViewDiffableDataSource(for: collectionView)
	}

}
