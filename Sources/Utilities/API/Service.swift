import Combine
import Foundation

/// Singleton service to make API calls
final actor Service {
	static let sharedInstance = Service()
	private init() {}

	private var apiCache = [String:Data]()

	/// Enum to represent useful constant values
	enum Constants {
		static let apiKey = "api_key=\(_Constants.apiKey)"
		static let baseURL = "https://api.themoviedb.org/3/"
		static let imageBaseURL = "https://image.tmdb.org/t/p/"
		static let ratedShowsURL = "\(baseURL)/account/\(_Constants.accountID)/rated/tv"
		static let ratedMoviesURL = "\(baseURL)/account/\(_Constants.accountID)/rated/movies"
		static let topRatedTVShowsURL = "\(baseURL)tv/top_rated?\(apiKey)"
		static let trendingTVShowsURL = "\(baseURL)trending/tv/day?\(apiKey)"
		static let searchQueryBaseURL = "\(baseURL)search/multi?\(apiKey)"
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

	/// Function to make API calls, without caching
	/// - Parameters:
	///		- request: The `URLRequest`
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

	/// Function to add a rating for a given tv show or movie
	/// - Parameters:
	///		- object: The `ObjectType`
	///		- rating: A `Double` that represents the rating
	/// - Returns: `AnyPublisher<Data, Error>`
	func addRating(for object: ObjectType, rating: Double) -> AnyPublisher<Data, Error> {
		let media = object.type == .movie ? "movie" : "tv"

		guard let url = URL(string: "\(Constants.baseURL)\(media)/\(object.id)/rating") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}

		var request = makeRequest(for: url)
		request.httpBody = try? JSONEncoder().encode(["value": rating])
		request.httpMethod = "POST"
		request.timeoutInterval = 10
		request.allHTTPHeaderFields?["Content-Type"] = "application/json;charset=utf-8"

		return URLSession.shared.dataTaskPublisher(for: request)
			.tryMap { data, _ in
				return data
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	/// Function to reset the cache for the rated movies or tv shows
	/// - Parameter key: A `String` that represents the cache key
	func resetCache(for key: String) {
		apiCache = apiCache.filter { !$0.key.hasPrefix(key) }
	}
}

// ! Reusable

extension Service {
	/// Function to fetch the details for a given tv show or movie
	/// - Parameters:
	///		- id: An `Int` that represents the tv show or movie
	///		- isMovie: `Bool` that checks wether we should fetch the details for a movie, defaults to false
	///		- type: The given type that conforms to `Codable` from which to decode the JSON data
	/// - Returns: `AnyPublisher<(T, Bool), Error>`
	func fetchDetails<T: Codable>(for id: Int, isMovie: Bool = false, expecting type: T.Type) -> AnyPublisher<(T, Bool), Error> {
		let mediaType = isMovie ? "movie" : "tv"
		var urlString = "\(Constants.baseURL)\(mediaType)/\(id)?\(Constants.apiKey)"
		if isMovie { urlString.append("&append_to_response=credits") }

		guard let url = URL(string: urlString) else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}

		return fetchTVShows(request: makeRequest(for: url), expecting: T.self)
			.eraseToAnyPublisher()
	}

	/// Function to fetch season details for a given season
	/// - Parameters:
	///		- season: The `Season` object
	///		- tvShow: The `TVShow` object for the season
	/// - Returns: `AnyPublisher<Season, Error>`
	func fetchSeasonDetails(for season: Season, tvShow: TVShow) -> AnyPublisher<Season, Error> {
		let urlString = "\(Constants.baseURL)tv/\(tvShow.id)/season/\(season.number ?? 0)?\(Constants.apiKey)"
		guard let url = URL(string: urlString) else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}

		return fetchTVShows(withURL: url, expecting: Season.self)
			.eraseToAnyPublisher()
	}

	/// Function to create a reusable `URLRequest`
	/// - Parameter url: The `URL`
	/// - Returns: `URLRequest`
	func makeRequest(for url: URL) -> URLRequest {
		var request = URLRequest(url: url)
		request.allHTTPHeaderFields = [
			"accept": "application/json",
			"Authorization": "Bearer \(_Constants.token)"
		]
		return request
	}
}

// ! ImageFetch

extension Service {
	/// Enum to represent the different types of images
	enum ImageFetch {
		case showPoster(TVShow)
		case mediaPoster(String)
		case showBackdrop(TVShow)
		case movieBackdrop(Movie)
		case seasonPoster(Season)
		case episodeStill(Episode)
		case ratedMoviePoster(RatedMovie)
		case watchProviderLogo(WatchOption)

		var path: String? {
			switch self {
				case .showPoster(let show): return show.coverImage
				case .mediaPoster(let path): return path 
				case .showBackdrop(let show): return show.backgroundCoverImage
				case .movieBackdrop(let movie): return movie.backgroundCoverImage
				case .seasonPoster(let season): return season.coverImage
				case .episodeStill(let episode): return episode.coverImage
				case .ratedMoviePoster(let ratedMovie): return ratedMovie.coverImage
				case .watchProviderLogo(let watchOption): return watchOption.logoImage
			}
		}
	}

	/// Function to get the requested image url
	/// - Parameters:
	///		- image: The `ImageFetch` object
	///		- size: A `String` representing the size of the image
	static func imageURL(_ image: ImageFetch, size: String = "w500") -> URL? {
		guard let path = image.path else { return nil }
		return URL(string: Constants.imageBaseURL + size + "/" + path)
	}
}
