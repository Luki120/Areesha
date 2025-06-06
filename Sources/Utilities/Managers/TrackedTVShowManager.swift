import Combine
import UIKit

/// Singleton to handle the tracked tv shows
final class TrackedTVShowManager: ObservableObject {
	static let sharedInstance = TrackedTVShowManager()

	@PublishedStorage(key: "filteredViewModels", defaultValue: [])
	private(set) var filteredTrackedTVShows: [TrackedTVShow]

	@PublishedStorage(key: "viewModels", defaultValue: [])
	private(set) var trackedTVShows: [TrackedTVShow]

	@Storage(key: "sortOption", defaultValue: .moreAdvanced) var sortOption: SortOption

	/// Enum to represent the different types of options to sort
	enum SortOption: String, CaseIterable, Codable {
		case alphabetically, leastAdvanced, moreAdvanced
	}

	private init() {
		filteredTrackedTVShows = filteredTrackedTVShows.sorted { $0.rating ?? 0 > $1.rating ?? 0 }
	}

	private func insert(trackedTVShow: TrackedTVShow) {
		switch sortOption {
			case .alphabetically:
				let index = trackedTVShows.insertionIndex(of: trackedTVShow) { $0.name < $1.name }
				trackedTVShows.insert(trackedTVShow, at: index)

			case .leastAdvanced:
				let index = trackedTVShows.insertionIndex(of: trackedTVShow) { $0.lastSeen < $1.lastSeen }
				trackedTVShows.insert(trackedTVShow, at: index)

			case .moreAdvanced:
				let index = trackedTVShows.insertionIndex(of: trackedTVShow) { $0.lastSeen > $1.lastSeen }
				trackedTVShows.insert(trackedTVShow, at: index)
		}
	}
}

extension TrackedTVShowManager {
	// ! Public

	/// Function to track & save a tv show
	/// - Parameters:
	///		- tvShow: The `TVShow` object
	///		- season: The `Season` object
	///		- episode: The `Episode` object
	///		- completion: `@escaping` closure that takes a `Bool` as argument & returns nothing, to check
	///     if the given episode is already tracked or not
	func track(tvShow: TVShow, season: Season, episode: Episode, completion: @escaping (Bool) -> ()) {
		guard let url = Service.imageURL(.episodeStill(episode)),
			let seasonNumber = season.number,
			let episodeNumber = episode.number else { return }

		let isSeasonInDesiredRange = 1..<10 ~= seasonNumber
		let isEpisodeInDesiredRange = 1..<10 ~= episodeNumber
		let cleanSeasonNumber = isSeasonInDesiredRange ? "0\(seasonNumber)" : "\(seasonNumber)"
		let cleanEpisodeNumber = isEpisodeInDesiredRange ? "0\(episodeNumber)" : "\(episodeNumber)"

		let trackedTVShow = TrackedTVShow(
			tvShow: tvShow,
			name: tvShow.name,
			imageURL: url,
			season: season,
			episode: episode,
			lastSeen: "Last seen: S\(cleanSeasonNumber)E\(cleanEpisodeNumber)",
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
	///		- isFilteredArray: Boolean to check wether the array is filtered
	func deleteTrackedTVShow(at index: Int, isFilteredArray: Bool = false) {
		if !isFilteredArray { trackedTVShows.remove(at: index) }
		else { filteredTrackedTVShows.remove(at: index) }
	}

	/// Function to mark a tv show as finished
	/// - Parameters:
	///		- at: The index path for the item
	///		- completion: Escaping closure that takes a Bool as argument & returns nothing to check if
	///     the tv show is already in the filteredTrackedTVShows array or not
	func finishedShow(at index: Int, completion: @escaping (Bool) -> ()) {
		let isShowAdded = filteredTrackedTVShows.contains(where: trackedTVShows.contains)

		if !isShowAdded {
			completion(false)
			trackedTVShows[index].isFinished = true
			trackedTVShows[index].isReturningSeries = false

			filteredTrackedTVShows.append(contentsOf: trackedTVShows.filter { $0.isFinished })
			trackedTVShows = trackedTVShows.filter { $0.isFinished == false }
		}

		else {
			completion(true)
		}
	}

	/// Function to mark a currently watching show as returning series
	/// - Parameters:
	///		- at: The index path for the tv show
	///		- toggle: Boolean value to toggle between returning series or currently watching
	func markShowAsReturningSeries(at index: Int, toggle: Bool = true) {
		trackedTVShows[index].isReturningSeries = toggle
	}

	/// Function to sort the tv show models according to the given option
	/// - Parameters:
	///		- withOption: The option
	func didSortModels(withOption option: SortOption) {
		switch option {
			case .alphabetically: trackedTVShows = trackedTVShows.sorted { $0.name < $1.name }
			case .leastAdvanced: trackedTVShows = trackedTVShows.sorted { $0.lastSeen < $1.lastSeen }
			case .moreAdvanced: trackedTVShows = trackedTVShows.sorted { $0.lastSeen > $1.lastSeen }
		}
	}

	/// Function to set the ratings for the finished shows, if they exist
	/// - Parameters:
	///		- with: An array of `RatedTVShow` objects
	func updateRatings(with ratedShows: [RatedTVShow]) {
		for index in 0..<filteredTrackedTVShows.count {
			var filteredShow = filteredTrackedTVShows[index]

			if let ratedShow = ratedShows.first(where: { $0.id == filteredShow.tvShow.id }) {
				filteredShow.rating = ratedShow.rating
				filteredTrackedTVShows[index] = filteredShow
			}
		}
	}
}
