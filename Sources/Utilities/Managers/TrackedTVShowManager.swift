import Combine
import UIKit

/// Singleton to handle the tracked tv shows
final class TrackedTVShowManager: ObservableObject {

	static let sharedInstance = TrackedTVShowManager()

	@Published private(set) var filteredTrackedTVShows = [TrackedTVShow]() {
		didSet {
			encode(filteredTrackedTVShows, forKey: "filteredViewModels")
		}
	}

	@Published private(set) var trackedTVShows = [TrackedTVShow]() {
		didSet {
			encode(trackedTVShows, forKey: "viewModels")
		}
	}

	private init() {
		guard let trackedTVShows = decode([TrackedTVShow].self, forKey: "viewModels") else { return }
		self.trackedTVShows = trackedTVShows

		guard let filteredTrackedTVShows = decode([TrackedTVShow].self, forKey: "filteredViewModels") else { return }
		self.filteredTrackedTVShows = filteredTrackedTVShows
	}

	/// Enum to represent the different types of options to sort
	@frozen enum SortOption: String, Codable {
		case alphabetically, leastAdvanced, moreAdvanced
	}

	private func insert(trackedTVShow: TrackedTVShow) {
		guard let decodedSortOption = decode(SortOption.self, forKey: "sortOption") else {
			trackedTVShows.append(trackedTVShow)
			return
		}

		switch decodedSortOption {
			case .alphabetically:
				let index = trackedTVShows.insertionIndex(of: trackedTVShow) { $0.tvShowNameText < $1.tvShowNameText }
				trackedTVShows.insert(trackedTVShow, at: index)

			case .leastAdvanced:
				let index = trackedTVShows.insertionIndex(of: trackedTVShow) { $0.lastSeenText < $1.lastSeenText }
				trackedTVShows.insert(trackedTVShow, at: index)

			case .moreAdvanced:
				let index = trackedTVShows.insertionIndex(of: trackedTVShow) { $0.lastSeenText > $1.lastSeenText }
				trackedTVShows.insert(trackedTVShow, at: index)
		}
	}

	private func encode<D: Encodable>(_ data: D, forKey key: String) {
		guard let encodedData = try? JSONEncoder().encode(data) else { return }
		UserDefaults.standard.set(encodedData, forKey: key)		
	}

	private func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
		guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return nil }
		return try? JSONDecoder().decode(type.self, from: data)
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
			tvShow: tvShow,
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
		let isShowAdded = filteredTrackedTVShows.contains(where: trackedTVShows.contains)

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
		encode(option, forKey: "sortOption")
	}

}
