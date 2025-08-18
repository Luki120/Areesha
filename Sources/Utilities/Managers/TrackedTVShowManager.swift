import Combine
import UIKit

/// Singleton to handle the tracked tv shows
@MainActor
final class TrackedTVShowManager: ObservableObject {
	static let sharedInstance = TrackedTVShowManager()

	@PublishedStorage(key: "viewModels", defaultValue: [])
	private(set) var trackedTVShows: [TrackedTVShow]

	@Storage(key: "sortOption", defaultValue: .moreAdvanced) var sortOption: SortOption

	/// Enum to represent the different types of options to sort
	enum SortOption: String, CaseIterable, Codable {
		case alphabetically, leastAdvanced, moreAdvanced
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

// ! Public

extension TrackedTVShowManager {
	/// Function to track & save a tv show
	///
	/// - Parameters:
	///		- tvShow: The `TVShow` object
	///		- season: The `Season` object
	///		- episode: The `Episode` object
	/// - Returns: `Bool`
	@discardableResult
	func track(tvShow: TVShow, season: Season, episode: Episode) -> Bool {
		guard let seasonNumber = season.number,
			let episodeNumber = episode.number else { return false }

		let isSeasonInDesiredRange = 1..<10 ~= seasonNumber
		let isEpisodeInDesiredRange = 1..<10 ~= episodeNumber
		let cleanSeasonNumber = isSeasonInDesiredRange ? "0\(seasonNumber)" : "\(seasonNumber)"
		let cleanEpisodeNumber = isEpisodeInDesiredRange ? "0\(episodeNumber)" : "\(episodeNumber)"

		let trackedTVShow = TrackedTVShow(
			name: tvShow.name,
			tvShow: tvShow,
			season: season,
			episode: episode,
			imageURL: Service.imageURL(.episodeStill(episode)),
			lastSeen: "Last seen: S\(cleanSeasonNumber)E\(cleanEpisodeNumber)"
		)

		guard !trackedTVShows.contains(trackedTVShow) else { return true }
		insert(trackedTVShow: trackedTVShow)

		return false
	}

	/// Function to delete a tracked tv show at the given index
	/// - Parameter index: The index for the tv show
	func deleteTrackedTVShow(at index: Int) {
		trackedTVShows.remove(at: index)
	}

	/// Function to mark a currently watching show as returning series
	/// - Parameters:
	///		- index: The index path for the tv show
	///		- toggle: `Bool` value to toggle between returning series or currently watching
	func markShowAsReturningSeries(at index: Int, toggle: Bool = true) {
		trackedTVShows[index].isReturningSeries = toggle
	}

	/// Function to sort the tv show models according to the given option
	/// - Parameter option: The `SortOption`
	func didSortModels(withOption option: SortOption) {
		switch option {
			case .alphabetically: trackedTVShows = trackedTVShows.sorted { $0.name < $1.name }
			case .leastAdvanced: trackedTVShows = trackedTVShows.sorted { $0.lastSeen < $1.lastSeen }
			case .moreAdvanced: trackedTVShows = trackedTVShows.sorted { $0.lastSeen > $1.lastSeen }
		}
	}
}
