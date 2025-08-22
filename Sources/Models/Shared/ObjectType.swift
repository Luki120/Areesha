import Foundation

/// Object type model struct
struct ObjectType: Codable {
	let id: Int
	let name: String?
	let title: String?
	let genreIDs: [Int]?
	let mediaType: String
	let coverImage: String?
	let description: String?
	let backgroundCoverImage: String?

	enum CodingKeys: String, CodingKey {
		case id, name, title
		case genreIDs = "genre_ids"
		case mediaType = "media_type"
		case coverImage = "poster_path"
		case description = "overview"
		case backgroundCoverImage = "backdrop_path"
	}

	var isEmpty: Bool {
		backgroundCoverImage == nil && genreIDs == [] && description == ""
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
		self.genreIDs = []
		self.mediaType = "tv"
		self.coverImage = tvShow.coverImage
		self.description = tvShow.description
		self.backgroundCoverImage = tvShow.backgroundCoverImage
	}

	/// Initializer to create an `ObjectType` from a `Movie` object
	/// - Parameter movie: The `Movie` object
	init(from movie: Movie) {
		self.id = movie.id
		self.name = nil
		self.title = movie.title
		self.genreIDs = []
		self.mediaType = "movie"
		self.coverImage = movie.coverImage
		self.description = movie.description
		self.backgroundCoverImage = movie.backgroundCoverImage
	}
}

/// Enum that represents the types for `ObjectType`
enum MediaType: String {
	case tv, movie, unknown
}
