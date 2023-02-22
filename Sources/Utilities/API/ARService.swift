import Combine
import Foundation

/// Singleton service to make API calls
final class ARService {

	static let sharedInstance = ARService()
	private init() {}

	private var apiCache = [String:Data]()

	struct Constants {
		static let apiKey = _Constants.apiKey
		static let baseURL = "https://api.themoviedb.org/3/"
		static let baseImageURL = "https://image.tmdb.org/t/p/"
		static let topRatedTVShowsURL = "\(baseURL)/tv/top_rated?api_key=\(apiKey)&language=en-US"
		static let searchTVShowBaseURL = "https://api.themoviedb.org/3/search/tv?api_key=\(apiKey)&language=en-US"
	}

	/// Function that'll handle API calls
	/// - Parameters:
	///     - withURL: the API call url
	///     - expecting: the given type that conforms to Codable from which we will decode the JSON data
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
