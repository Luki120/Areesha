import Combine
import Foundation

/// Singleton service to make API calls
final class Service {

	static let sharedInstance = Service()
	private init() {}

	private var apiCache = [String:Data]()

	/// Enum to represent useful constant values
	enum Constants {
		static let apiKey = _Constants.apiKey
		static let baseURL = "https://api.themoviedb.org/3/"
		static let baseImageURL = "https://image.tmdb.org/t/p/"
		static let topRatedTVShowsURL = "\(baseURL)tv/top_rated?api_key=\(apiKey)"
		static let trendingTVShowsURL = "\(baseURL)trending/tv/day?api_key=\(apiKey)"
		static let searchTVShowBaseURL = "\(baseURL)search/tv?api_key=\(apiKey)"
	}

	/// Function to make API calls
	/// - Parameters:
	///     - withURL: The API call url
	///     - expecting: The given type that conforms to Codable from which to decode the JSON data
	/// - Returns: Any type of publisher, taking a tuple & Error
	func fetchTVShows<T: Codable>(withURL url: URL, expecting type: T.Type) -> AnyPublisher<(T, Bool), Error> {
		let dataPublisher: AnyPublisher<Data, Error>
		let isFromCache: Bool

		if let cachedData = apiCache[url.absoluteString] {
			isFromCache = true
			dataPublisher = Just(cachedData)
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		}
		else {
			isFromCache = false
			dataPublisher = URLSession.shared.dataTaskPublisher(for: url)
				.tryMap { data, _ in
					self.apiCache[url.absoluteString] = data
					return data
				}
				.eraseToAnyPublisher()	
		}

		return dataPublisher
			.decode(type: T.self, decoder: JSONDecoder())
			.map { ($0, isFromCache) }
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	/// Function to make API calls without caring about if it's coming from the cache or the network
	/// - Parameters:
	///     - withURL: The API call url
	///     - expecting: The given type that conforms to Codable from which to decode the JSON data
	/// - Returns: Any type of publisher, taking a generic type T & Error
	func fetchTVShows<T: Codable>(withURL url: URL, expecting type: T.Type) -> AnyPublisher<T, Error> {
		fetchTVShows(withURL: url, expecting: T.self)
			.map(\.0)
			.eraseToAnyPublisher()
	}

}

extension Service {

	/// Enum to represent the different types of images
	enum ImageFetch {
		case showPoster(TVShow)
		case showBackdrop(TVShow)
		case seasonPoster(Season)
		case episodeStill(Episode)

		var path: String? {
			switch self {
				case .showPoster(let show): return show.posterPath
				case .showBackdrop(let show): return show.backdropPath
				case .seasonPoster(let season): return season.posterPath
				case .episodeStill(let episode): return episode.stillPath
			}
		}
	}

	/// Function to get the requested image url
	/// - Parameters:
	///     - image: The image object
	///     - size: A string representing the size of the image
	static func imageURL(_ image: ImageFetch, size: String = "w500") -> URL? {
		guard let path = image.path else { return nil }
		return URL(string: "\(Constants.baseImageURL)\(size)/\(path)")
	}

}
