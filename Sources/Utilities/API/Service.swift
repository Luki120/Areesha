import Combine
import Foundation

/// Singleton service to make API calls
final class Service {

	static let sharedInstance = Service()
	private init() {}

	private var apiCache = [String:Data]()

	struct Constants {
		static let apiKey = _Constants.apiKey
		static let baseURL = "https://api.themoviedb.org/3/"
		static let baseImageURL = "https://image.tmdb.org/t/p/"
		static let topRatedTVShowsURL = "\(baseURL)/tv/top_rated?api_key=\(apiKey)"
		static let trendingTVShowsURL = "\(baseURL)trending/tv/day?api_key=\(apiKey)"
		static let searchTVShowBaseURL = "https://api.themoviedb.org/3/search/tv?api_key=\(apiKey)"
	}

	/// Function to make API calls
	/// - Parameters:
	///     - withURL: the API call url
	///     - expecting: the given type that conforms to Codable from which to decode the JSON data
	///		- isFromCache: escaping closure to check whether the API call is coming from cache or the network
	/// - Returns: Any type of publisher, of generic type T & Error
	func fetchTVShows<T: Codable>(
		withURL url: URL,
		expecting type: T.Type,
		isFromCache: @escaping (Bool) -> () = { _ in }
	) -> AnyPublisher<T, Error> {
		if let cachedData = apiCache[url.absoluteString] {
			isFromCache(true)
			return Just(cachedData)
				.decode(type: type.self, decoder: JSONDecoder())
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
		}

		return URLSession.shared.dataTaskPublisher(for: url)
			.tryMap { data, _ in
				isFromCache(false)
				self.apiCache[url.absoluteString] = data
				return data
			}
			.decode(type: type.self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

}
