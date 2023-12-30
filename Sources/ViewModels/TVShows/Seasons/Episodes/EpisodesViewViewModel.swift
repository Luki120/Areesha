import Combine
import UIKit

protocol EpisodesViewViewModelDelegate: AnyObject {
	func didShowToastView()
	func shouldAnimateNoEpisodesLabel(isDataSourceEmpty: Bool)
}

/// View model class for EpisodesView
final class EpisodesViewViewModel: NSObject {

	var seasonName: String { return season.name ?? "" }

	private var episodes = [Episode]()
	private var viewModels = OrderedSet<EpisodeCollectionViewCellViewModel>()
	private var subscriptions = Set<AnyCancellable>()

	weak var delegate: EpisodesViewViewModelDelegate?

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<EpisodeCollectionViewCell, EpisodeCollectionViewCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, EpisodeCollectionViewCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, EpisodeCollectionViewCellViewModel>

	private var dataSource: DataSource!

	@frozen private enum Sections {
		case main
	}

	private let tvShow: TVShow
	private let season: Season

	/// Designated initializer
	/// - Parameters:
	///		- tvShow: The tv show model object
	///		- season: The season model object
	init(tvShow: TVShow, season: Season) {
		self.tvShow = tvShow
		self.season = season
		super.init()
		fetchSeasonDetails()
	}

	private func fetchSeasonDetails() {
		guard let url = URL(string: "\(Service.Constants.baseURL)tv/\(tvShow.id)/season/\(season.seasonNumber ?? 0)?\(Service.Constants.apiKey)") else {
			return
		}

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: Season.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] season in
				guard let self else { return }
				episodes = season.episodes ?? []
				updateViewModels(with: episodes)
				applyDiffableDataSourceSnapshot()

				delegate?.shouldAnimateNoEpisodesLabel(isDataSourceEmpty: viewModels.isEmpty)
			}
			.store(in: &subscriptions)
	}

	private func updateViewModels(with episodes: [Episode]) {
		viewModels += episodes.compactMap { episode in
			guard let url = Service.imageURL(.episodeStill(episode)) else { return nil }

			return EpisodeCollectionViewCellViewModel(
				imageURL: url,
				episodeNameText: "\(episode.episodeNumber ?? 0). \(episode.name ?? "")",
				episodeDurationText: "\(episode.runtime ?? 0) min",
				episodeDescriptionText: episode.overview ?? ""
			)
		}
	}

}

extension EpisodesViewViewModel {

	// ! Public

	/// Function to fetch the tv show's poster image
	/// - Parameters:
	///		- completion: Escaping closure that takes a UIImage as argument & returns nothing
	func fetchTVShowImage(completion: @escaping (UIImage) async -> ()) {
		Task.detached(priority: .background) {
			guard let imageURL = Service.imageURL(.showPoster(self.tvShow), size: "w1280"),
				let image = try? await ImageManager.sharedInstance.fetchImageAsync(imageURL) else { return }

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
			if !isTracked { self.delegate?.didShowToastView() }
		}
	}

}
