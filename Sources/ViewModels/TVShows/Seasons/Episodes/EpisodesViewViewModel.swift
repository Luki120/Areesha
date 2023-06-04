import Combine
import UIKit

/// View model class for EpisodesView
final class EpisodesViewViewModel: NSObject {

	var posterPath: String { return tvShow.posterPath ?? "" }
	var seasonName: String { return season.name ?? "" }

	private let tvShow: TVShow
	private let season: Season

	private var episodes = [Episode]()
	private var viewModels = OrderedSet<EpisodeCollectionViewCellViewModel>()
	private var subscriptions = Set<AnyCancellable>()

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<EpisodeCollectionViewCell, EpisodeCollectionViewCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, EpisodeCollectionViewCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, EpisodeCollectionViewCellViewModel>

	private var dataSource: DataSource!
	private var snapshot: Snapshot!

	@frozen private enum Sections {
		case main
	}

	/// Designated initializer
	/// - Parameters:
	///		- tvShow: the tv show model object
	///     - season: the season model object
	init(tvShow: TVShow, season: Season) {
		self.tvShow = tvShow
		self.season = season
		super.init()
		fetchSeasonDetails()
	}

	private func fetchSeasonDetails() {
		guard let url = URL(string: "\(Service.Constants.baseURL)tv/\(tvShow.id)/season/\(season.seasonNumber ?? 0)?api_key=\(Service.Constants.apiKey)") else {
			return
		}

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: Season.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] season in
				guard let self else { return }
				episodes = season.episodes ?? []
				updateViewModels(with: episodes)
				applyDiffableDataSourceSnapshot()
			}
			.store(in: &subscriptions)
	}

	private func updateViewModels(with episodes: [Episode]) {
		viewModels += episodes.compactMap { episode in
			let imageURLString = "\(Service.Constants.baseImageURL)w500/\(episode.stillPath ?? "")"
			guard let url = URL(string: imageURLString) else { return nil }

			return EpisodeCollectionViewCellViewModel(
				imageURL: url,
				episodeNameText: "\(episode.episodeNumber ?? 0). \(episode.name ?? "")",
				episodeDurationText: "\(episode.runtime ?? 0) min",
				episodeDescriptionText: episode.overview ?? ""
			)
		}
	}

}

// ! UICollectionView

extension EpisodesViewViewModel: UICollectionViewDelegate {

	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///     - collectionView: The collection view
	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.configure(with: viewModel)
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

		let userInfo: [String : Codable] = [
			"tvShow": tvShow,
			"season": season,
			"episode": episodes[indexPath.item]
		]
		NotificationCenter.default.post(
			name: .didSendTrackedTVShowDataNotification,
			object: nil,
			userInfo: userInfo
		)
	}

}
