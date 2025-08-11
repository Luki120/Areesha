import Combine
import UIKit

protocol EpisodesViewViewModelDelegate: AnyObject {
	func didShowToastView()
	func shouldAnimateNoEpisodesLabel(isDataSourceEmpty: Bool)
}

/// View model class for EpisodesView
final class EpisodesViewViewModel: NSObject {
	var seasonName: String { return season.name ?? "" }

	private var _tvShow: TVShow!
	private var episodes = [Episode]()
	private var viewModels = OrderedSet<EpisodeCellViewModel>()
	private var subscriptions = Set<AnyCancellable>()

	weak var delegate: EpisodesViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<EpisodeCell, EpisodeCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, EpisodeCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeCellViewModel>

	private var dataSource: DataSource!

	private enum Section {
		case main
	}

	private let tvShow: TVShow
	private let season: Season

	/// Designated initializer
	/// - Parameters:
	///		- tvShow: The `TVShow` model object
	///		- season: The `Season` model object
	init(tvShow: TVShow, season: Season) {
		self.tvShow = tvShow
		self.season = season
		super.init()

		fetchDetails()
	}

	private func fetchDetails() {
		Service.sharedInstance.fetchDetails(for: tvShow.id, expecting: TVShow.self, storeIn: &subscriptions) { tvShow, _ in
			self._tvShow = tvShow
		}

		Service.sharedInstance.fetchSeasonDetails(
			for: season,
			tvShow: tvShow,
			storeIn: &subscriptions
		) { [weak self] season in
			guard let self else { return }
			episodes = season.episodes ?? []
			updateViewModels(with: episodes)
			applyDiffableDataSourceSnapshot()

			delegate?.shouldAnimateNoEpisodesLabel(isDataSourceEmpty: viewModels.isEmpty)
		}
	}

	private func updateViewModels(with episodes: [Episode]) {
		viewModels += episodes.compactMap { episode in
			guard let url = Service.imageURL(.episodeStill(episode)) else { return nil }

			return EpisodeCellViewModel(
				imageURL: url,
				episodeName: "\(episode.number ?? 0). \(episode.name ?? "")",
				episodeDuration: "\(episode.duration ?? 0) min",
				episodeDescription: episode.description ?? ""
			)
		}
	}
}

extension EpisodesViewViewModel {
	// ! Public

	/// Function to fetch the tv show's poster image
	/// - Parameter completion: `@escaping` closure that takes a `UIImage` as argument & returns nothing
	func fetchTVShowImage(completion: @escaping (UIImage) async -> ()) {
		Task(priority: .background) {
			guard let imageURL = Service.imageURL(.showPoster(self.tvShow), size: "w1280"),
				let image = try? await ImageManager.sharedInstance.fetchImage(imageURL) else { return }

			await completion(image)
		}
	}
}

// ! UICollectionView

extension EpisodesViewViewModel: UICollectionViewDelegate {
	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///		- collectionView: The collection view
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

		TrackedTVShowManager.sharedInstance.track(
			tvShow: tvShow,
			season: season,
			episode: episodes[indexPath.item]
		) { isTracked in
			if !isTracked {
				self.delegate?.didShowToastView()

				Task {
					await NotificationManager.sharedInstance.postNewEpisodeNotification(for: self._tvShow)
				}
			}
		}
	}
}
