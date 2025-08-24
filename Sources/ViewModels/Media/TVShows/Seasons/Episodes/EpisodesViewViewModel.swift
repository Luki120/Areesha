import Combine
import UIKit

@MainActor
protocol EpisodesViewViewModelDelegate: AnyObject {
	func didShowToastView()
	func shouldAnimateNoEpisodesLabel(isDataSourceEmpty: Bool)
}

/// View model class for EpisodesView
@MainActor
final class EpisodesViewViewModel: BaseViewModel<EpisodeCell> {
	var seasonName: String { return season.name ?? "" }

	private var _tvShow: TVShow!
	private var episodes = [Episode]()
	private var subscriptions = Set<AnyCancellable>()

	weak var delegate: EpisodesViewViewModelDelegate?

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

		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}

		Task {
			await fetchDetails()
		}
	}

	private func fetchDetails() async {
		await Service.sharedInstance.fetchDetails(for: tvShow.id, expecting: TVShow.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] tvShow, _ in
				self?._tvShow = tvShow
			}
			.store(in: &subscriptions)

		await Service.sharedInstance.fetchSeasonDetails(for: season, tvShow: tvShow)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] season in
				guard let self else { return }
				episodes = season.episodes ?? []
				updateViewModels(with: episodes)
				applySnapshot()

				delegate?.shouldAnimateNoEpisodesLabel(isDataSourceEmpty: viewModels.isEmpty)
			}
			.store(in: &subscriptions)
	}

	private func updateViewModels(with episodes: [Episode]) {
		viewModels += episodes.compactMap { episode in
			let url = Service.imageURL(for: episode, type: .episodeStill)

			return EpisodeCellViewModel(
				imageURL: url,
				episodeName: "\(episode.number ?? 0). \(episode.name ?? "")",
				episodeDuration: "\(episode.duration ?? 0) min",
				episodeDescription: episode.description ?? ""
			)
		}
	}
}

// ! Public

extension EpisodesViewViewModel {
	/// Function to fetch the tv show's poster image
	/// - Returns: `UIImage`
	nonisolated func fetchTVShowImage() async -> UIImage {
		let imageURL = Service.imageURL(for: tvShow, type: .poster, size: "w1280")

		guard let image = try? await ImageActor.sharedInstance.fetchImage(imageURL) else { return .init() }
		return image
	}
}

// ! UICollectionViewDelegate

extension EpisodesViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		let isTracked = TrackedTVShowManager.sharedInstance.track(
			tvShow: tvShow,
			season: season,
			episode: episodes[indexPath.item]
		)

		if !isTracked {
			delegate?.didShowToastView()

			Task {
				await NotificationActor.sharedInstance.postNewEpisodeNotification(for: _tvShow)
			}
		}
	}
}
