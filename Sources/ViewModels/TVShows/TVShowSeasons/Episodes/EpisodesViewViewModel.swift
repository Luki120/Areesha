import Combine
import UIKit

/// View model class for EpisodesView
final class EpisodesViewViewModel: NSObject {

	let tvShow: TVShow
	let season: Season

	var seasonName: String { return season.name ?? "" }

	private var viewModels = [EpisodeCollectionViewCellViewModel]()
	private var subscriptions = Set<AnyCancellable>()

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
				self?.updateViewModels(with: season.episodes ?? [])
				self?.applyDiffableDataSourceSnapshot()
			}
			.store(in: &subscriptions)
	}

	private func updateViewModels(with episodes: [Episode]) {
		for episode in episodes {
			let imageURLString = "\(Service.Constants.baseImageURL)w500/\(episode.stillPath ?? "")"
			guard let url = URL(string: imageURLString) else { return }

			let viewModel = EpisodeCollectionViewCellViewModel(
				imageURL: url,
				episodeNameText: "\(episode.episodeNumber ?? 0). \(episode.name ?? "")",
				episodeDurationText: "\(episode.runtime ?? 0) min",
				episodeDescriptionText: episode.overview ?? ""
			)

			if !viewModels.contains(viewModel) {
				viewModels.append(viewModel)
			}
		}
	}

	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.configure(with: viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier -> UICollectionViewCell? in
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
		snapshot.appendItems(viewModels)
		dataSource.apply(snapshot, animatingDifferences: true)
	}

}

// ! UICollectionViewDelegate

extension EpisodesViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
	}

}
