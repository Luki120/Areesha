import Combine
import UIKit

/// Singleton to handle the tracked tv shows
final class TrackedTVShowManager: ObservableObject {

	static let sharedInstance = TrackedTVShowManager()

	@Published private(set) var trackedTVShows: [TrackedTVShow] {
		didSet {
			guard let encodedViewModels = try? JSONEncoder().encode(trackedTVShows) else { return }
			UserDefaults.standard.set(encodedViewModels, forKey: "viewModels")
		}
	}

	private init() {
		guard let data = UserDefaults.standard.object(forKey: "viewModels") as? Data,
			let decodedViewModels = try? JSONDecoder().decode([TrackedTVShow].self, from: data) else {
				trackedTVShows = []
				return
			}

		trackedTVShows = decodedViewModels
	}

	/// Enum to represent the different types of options to sort
	enum SortOption: Codable {
		case alphabetically, leastAdvanced, moreAdvanced
	}

	private func insert(trackedTVShow: TrackedTVShow) {
		guard let data = UserDefaults.standard.object(forKey: "sortOption") as? Data,
			let decodedSortOption = try? JSONDecoder().decode(SortOption.self, from: data) else { return }

		switch decodedSortOption {
			case .alphabetically:
				let index = trackedTVShows.insertionIndexOf(trackedTVShow) { $0.tvShowNameText < $1.tvShowNameText }
				trackedTVShows.insert(trackedTVShow, at: index)

			case .leastAdvanced:
				let index = trackedTVShows.insertionIndexOf(trackedTVShow) { $0.lastSeenText < $1.lastSeenText }
				trackedTVShows.insert(trackedTVShow, at: index)

			case .moreAdvanced:
				let index = trackedTVShows.insertionIndexOf(trackedTVShow) { $0.lastSeenText > $1.lastSeenText }
				trackedTVShows.insert(trackedTVShow, at: index)
		}
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
		guard let url = Service.imageURL(.episodeStill(episode)) else { return }

		let isSeasonInDesiredRange = 1..<10 ~= season.seasonNumber
		let isEpisodeInDesiredRange = 1..<10 ~= episode.episodeNumber
		let cleanSeasonNumber = isSeasonInDesiredRange ? "0\(season.seasonNumber)" : "\(season.seasonNumber)"
		let cleanSeasonEpisode = isEpisodeInDesiredRange ? "0\(episode.episodeNumber)" : "\(episode.episodeNumber)"

		let trackedTVShow = TrackedTVShow(
			imageURL: url,
			tvShowNameText: tvShow.name,
			lastSeenText: "Last seen: S\(cleanSeasonNumber)E\(cleanSeasonEpisode)",
			episode: episode,
			episodeID: episode.id
		)

		guard !trackedTVShows.contains(trackedTVShow) else {
			completion(true)
			return
		}

		completion(false)
		insert(trackedTVShow: trackedTVShow)
	}

	/// Function to delete a tracked tv show at the given index
	/// - Parameters:
	///		- at: The index for the tv show
	func removeTrackedTVShow(at index: Int) {
		trackedTVShows.remove(at: index)
	}

	/// Function sort the tv show models according to the given option
	/// - Parameters:
	///		- withOption: The option
	func didSortModels(withOption option: SortOption) {
		switch option {
			case .alphabetically: trackedTVShows = trackedTVShows.sorted { $0.tvShowNameText < $1.tvShowNameText }
			case .leastAdvanced: trackedTVShows = trackedTVShows.sorted { $0.lastSeenText < $1.lastSeenText }
			case .moreAdvanced: trackedTVShows = trackedTVShows.sorted { $0.lastSeenText > $1.lastSeenText }
		}

		guard let encodedSortOption = try? JSONEncoder().encode(option) else { return }
		UserDefaults.standard.set(encodedSortOption, forKey: "sortOption")
	}

}
