import Combine
import Foundation

/// Singleton service to make API calls
final class Service {
	static let sharedInstance = Service()
	private init() {}

	private var apiCache = [String:Data]()

	/// Enum to represent useful constant values
	enum Constants {
		static let apiKey = "api_key=\(_Constants.apiKey)"
		static let baseURL = "https://api.themoviedb.org/3/"
		static let imageBaseURL = "https://image.tmdb.org/t/p/"
		static let ratedShowsURL = "\(baseURL)/account/\(_Constants.accountID)/rated/tv"
		static let topRatedTVShowsURL = "\(baseURL)tv/top_rated?\(apiKey)"
		static let trendingTVShowsURL = "\(baseURL)trending/tv/day?\(apiKey)"
		static let searchTVShowBaseURL = "\(baseURL)search/tv?\(apiKey)"
	}

	/// Function to make API calls
	/// - Parameters:
	///		- request: The `URLRequest`
	///		- expecting: The given type that conforms to `Codable` from which to decode the JSON data
	/// - Returns: `AnyPublisher<(T, Bool), Error>`
	func fetchTVShows<T: Codable>(request: URLRequest, expecting type: T.Type) -> AnyPublisher<(T, Bool), Error> {
		let urlString = request.url?.absoluteString ?? UUID().uuidString
		let dataPublisher: AnyPublisher<Data, Error>
		let isFromCache: Bool

		if let cachedData = apiCache[urlString] {
			isFromCache = true
			dataPublisher = Just(cachedData)
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		}
		else {
			isFromCache = false
			dataPublisher = URLSession.shared.dataTaskPublisher(for: request)
				.tryMap { data, _ in
					self.apiCache[urlString] = data
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

	/// Function to make API calls, ignoring if it comes from the cache or the network
	/// - Parameters:
	///		- withURL: The API call url
	///		- expecting: The given type that conforms to `Codable` from which to decode the JSON data
	/// - Returns: `AnyPublisher<T, Error>`
	func fetchTVShows<T: Codable>(request: URLRequest, expecting type: T.Type) -> AnyPublisher<T, Error> {
		return URLSession.shared.dataTaskPublisher(for: request)
			.tryMap { data, _ in
				return data
			}
			.decode(type: T.self, decoder: JSONDecoder())
			.map { $0 }
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	/// Function to make API calls
	/// - Parameters:
	///		- withURL: The API call url
	///		- expecting: The given type that conforms to `Codable` from which to decode the JSON data
	/// - Returns: `AnyPublisher<(T, Bool), Error>`
	func fetchTVShows<T: Codable>(withURL url: URL, expecting type: T.Type) -> AnyPublisher<(T, Bool), Error> {
		return fetchTVShows(request: .init(url: url), expecting: type)
	}

	/// Function to make API calls, ignoring if it comes from the cache or the network
	/// - Parameters:
	///		- withURL: The API call url
	///		- expecting: The given type that conforms to `Codable` from which to decode the JSON data
	/// - Returns: `AnyPublisher<T, Error>`
	func fetchTVShows<T: Codable>(withURL url: URL, expecting type: T.Type) -> AnyPublisher<T, Error> {
		fetchTVShows(request: .init(url: url), expecting: T.self)
			.map(\.0)
			.eraseToAnyPublisher()
	}

	/// Function to add a rating for a given TV show
	/// - Parameters:
	///		- for: The `TVShow` object
	///		- rating: An integer that represents the rating
	/// - Returns: `AnyPublisher<Data, Error>`
	func addRating(for tvShow: TVShow, rating: Int) -> AnyPublisher<Data, Error> {
		guard let url = URL(string: "\(Constants.baseURL)tv/\(tvShow.id)/rating") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}

		var request = URLRequest(url: url)
		request.httpBody = try? JSONEncoder().encode(["value": rating])
		request.httpMethod = "POST"
		request.timeoutInterval = 10
		request.allHTTPHeaderFields = [
			"accept": "application/json",
			"Content-Type": "application/json;charset=utf-8",
			"Authorization": "Bearer \(_Constants.token)"
		]

		return URLSession.shared.dataTaskPublisher(for: request)
			.tryMap { data, _ in
				return data
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}

// ! Reusable

extension Service {
	/// Function to fetch tv show details for a given tv show
	/// - Parameters:
	///		- for: The `TVShow` object
	///		- storeIn: A `Set<AnyCancellable>` to store this instance
	///		- completion: `@escaping` closure that takes a tuple of `TVShow` & `Bool` and returns nothing
	func fetchTVShowDetails(
		for tvShow: TVShow,
		storeIn subscriptions: inout Set<AnyCancellable>,
		completion: @escaping (TVShow, Bool) -> ()
	) {
		let urlString = "\(Constants.baseURL)tv/\(tvShow.id)?\(Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }

		fetchTVShows(withURL: url, expecting: TVShow.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { tvShow, isFromCache in
				completion(tvShow, isFromCache)
			}
			.store(in: &subscriptions)
	}

	/// Function to fetch season details for a given season
	/// - Parameters:
	///		- for: The `Season` object
	///		- tvShow: The `TVShow` object for the season
	///		- storeIn: A `Set<AnyCancellable>` to store this instance
	///		- completion: `@escaping` closure that takes a `Seasons` object & returns nothing
	func fetchSeasonDetails(
		for season: Season,
		tvShow: TVShow,
		storeIn subscriptions: inout Set<AnyCancellable>,
		completion: @escaping (Season) -> ()
	) {
		let urlString = "\(Constants.baseURL)tv/\(tvShow.id)/season/\(season.number ?? 0)?\(Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }

		fetchTVShows(withURL: url, expecting: Season.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { season in
				completion(season)
			}
			.store(in: &subscriptions)
	}
}

// ! ImageFetch

extension Service {
	/// Enum to represent the different types of images
	enum ImageFetch {
		case showPoster(TVShow)
		case showBackdrop(TVShow)
		case seasonPoster(Season)
		case episodeStill(Episode)
		case watchProviderLogo(WatchOption)

		var path: String? {
			switch self {
				case .showPoster(let show): return show.coverImage
				case .showBackdrop(let show): return show.backgroundCoverImage
				case .seasonPoster(let season): return season.coverImage
				case .episodeStill(let episode): return episode.coverImage
				case .watchProviderLogo(let watchOption): return watchOption.logoImage
			}
		}
	}

	/// Function to get the requested image url
	/// - Parameters:
	///		- image: The `ImageFetch` object
	///		- size: A string representing the size of the image
	static func imageURL(_ image: ImageFetch, size: String = "w500") -> URL? {
		guard let path = image.path else { return nil }
		return URL(string: String(describing: Constants.imageBaseURL + size + "/" + path))
	}
}
