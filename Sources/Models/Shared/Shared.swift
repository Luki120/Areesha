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

	enum CodingKeys: String, CodingKey {
		case id
		case name
		case title
		case mediaType = "media_type"
	}

	var type: MediaType {
		return .init(rawValue: mediaType) ?? .unknown
	}
}

/// Enum that represents the types for `ObjectType`
enum MediaType: String {
	case tv, movie, unknown
}
