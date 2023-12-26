import Combine
import UIKit

/// Singleton to handle the tracked tv shows
final class TrackedTVShowManager: ObservableObject {

	static let sharedInstance = TrackedTVShowManager()

	@Published private(set) var filteredTrackedTVShows: [TrackedTVShow] {
		didSet {
			encode(models: filteredTrackedTVShows, withKey: "filteredViewModels")
		}
	}

	@Published private(set) var trackedTVShows: [TrackedTVShow] {
		didSet {
			encode(models: trackedTVShows, withKey: "viewModels")
		}
	}

	private init() {
		guard let data = UserDefaults.standard.object(forKey: "viewModels") as? Data,
			let filteredData = UserDefaults.standard.object(forKey: "filteredViewModels") as? Data,
			let decodedViewModels = try? JSONDecoder().decode([TrackedTVShow].self, from: data),
			let decodedFilteredViewModels = try? JSONDecoder().decode([TrackedTVShow].self, from: filteredData) else {
				trackedTVShows = []
				filteredTrackedTVShows = []
				return
			}

		trackedTVShows = decodedViewModels
		filteredTrackedTVShows = decodedFilteredViewModels
	}

	/// Enum to represent the different types of options to sort
	@frozen enum SortOption: Codable {
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

	private func encode(models: [TrackedTVShow], withKey key: String) {
		guard let encodedViewModels = try? JSONEncoder().encode(models) else { return }
		UserDefaults.standard.set(encodedViewModels, forKey: key)		
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
	func removeTrackedTVShow(at index: Int, isFilteredArray: Bool = false) {
		if !isFilteredArray { trackedTVShows.remove(at: index) }
		else { filteredTrackedTVShows.remove(at: index) }
	}

	/// Function to mark a tv show as finished
	/// - Parameters:
	///		- at: The index path for the item
	///		- completion: Escaping closure that takes a Bool as argument & returns nothing to check if
	///		the tv show is already in the filteredTrackedTVShows array or not
	func finishedShow(at index: Int, completion: @escaping (Bool) -> ()) {
		let isShowAdded = filteredTrackedTVShows.reduce(false, { $0 || trackedTVShows.contains($1) })

		if !isShowAdded {
			completion(false)
			trackedTVShows[index].isFinished = true

			filteredTrackedTVShows.append(contentsOf: trackedTVShows.filter { $0.isFinished }) 
			trackedTVShows = trackedTVShows.filter { $0.isFinished == false }
		}

		else {
			completion(true)
		}
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
