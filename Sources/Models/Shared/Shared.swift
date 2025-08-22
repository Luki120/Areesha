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
struct Genre: Codable, Hashable {
	let name: String
}
