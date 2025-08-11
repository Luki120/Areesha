import Foundation

/// API response model struct
struct APIResponse: Codable {
	let results: [TVShow]
}

/// Search response model struct
struct SearchResponse: Codable {
	let results: [ObjectType]
}

/// Genre model struct
struct Genre: Codable {
	let name: String
}

/// Object type model struct
struct ObjectType: Codable {
	let id: Int
	let name: String?
	let title: String?
	let mediaType: String
	let coverImage: String?

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case title
		case mediaType = "media_type"
		case coverImage = "poster_path"
	}

	var type: MediaType {
		return .init(rawValue: mediaType) ?? .unknown
	}
}

extension ObjectType {
	/// Initializer to create an `ObjectType` from a `TVShow` object
	/// - Parameter tvShow: The `TVShow` object
	init(from tvShow: TVShow) {
		self.id = tvShow.id
		self.name = tvShow.name
		self.title = nil
		self.mediaType = "tv"
		self.coverImage = tvShow.coverImage
	}

	/// Initializer to create an `ObjectType` from a `Movie` object
	/// - Parameter movie: The `Movie` object
	init(from movie: Movie) {
		self.id = movie.id
		self.name = nil
		self.title = movie.title
		self.mediaType = "movie"
		self.coverImage = movie.coverImage
	}
}

/// Enum that represents the types for `ObjectType`
enum MediaType: String {
	case tv, movie, unknown
}
