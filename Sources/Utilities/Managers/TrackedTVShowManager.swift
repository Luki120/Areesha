import Combine
import UIKit

/// Singleton to handle the tracked tv shows
final class TrackedTVShowManager: ObservableObject {

	static let sharedInstance = TrackedTVShowManager()

	@Published private(set) var trackedTVShows: OrderedSet<TrackedTVShow> {
		didSet {
			guard let encodedViewModels = try? JSONEncoder().encode(trackedTVShows) else { return }
			UserDefaults.standard.set(encodedViewModels, forKey: "viewModels")
		}
	}

	private init() {
		guard let data = UserDefaults.standard.object(forKey: "viewModels") as? Data,
			let decodedViewModels = try? JSONDecoder().decode(OrderedSet<TrackedTVShow>.self, from: data) else {
				trackedTVShows = []
				return
			}

		trackedTVShows = decodedViewModels
	}

}

extension TrackedTVShowManager {

	// ! Public

	/// Function to track & save a tv show
	/// - Parameters:
	///		- tvShow: The tv show object
	///		- season: The season object
	///		- episode: The episode object
	///		- completion: Escaping closure that takes a Bool as argument & returns nothing to check
	///		if the tv show with the given episode id is already being tracked or not
	func track(tvShow: TVShow, season: Season, episode: Episode, completion: @escaping (Bool) -> ()) {
		guard let url = Service.imageURL(.episodeStill(episode)),
			  let seasonNumber = season.seasonNumber,
			  let episodeNumber = episode.episodeNumber else { return }

		let isSeasonInDesiredRange = 1..<10 ~= seasonNumber
		let isEpisodeInDesiredRange = 1..<10 ~= episodeNumber
		let cleanSeasonNumber = isSeasonInDesiredRange ? "0\(seasonNumber)" : "\(seasonNumber)"
		let cleanSeasonEpisode = isEpisodeInDesiredRange ? "0\(episodeNumber)" : "\(episodeNumber)"

		let trackedTVShow = TrackedTVShow(
			imageURL: url,
			tvShowNameText: tvShow.name,
			lastSeenText: "Last seen: S\(cleanSeasonNumber)E\(cleanSeasonEpisode)",
			episodeID: episode.id
		)

		guard !trackedTVShows.contains(trackedTVShow) else {
			completion(true)
			return
		}

		completion(false)
		trackedTVShows.insert(trackedTVShow)
	}

	/// Function to delete a tracked tv show at the given index
	/// - Parameters:
	///		- at: The index for the tv show
	func removeTrackedTVShow(at index: Int) {
		trackedTVShows.remove(at: index)
	}

}
