import Foundation

/// API model struct
struct WatchProvider: Codable {
	let id: Int
	let results: [String: Region]
}

struct Region: Codable {
	let link: String?
	let flatrate: [WatchOption]?
	let additionals: [WatchOption]?

	enum CodingKeys: String, CodingKey {
		case link
		case flatrate
		case additionals = "ads"
	}
}

struct WatchOption: Codable, Hashable {
	let logoImage: String?

	enum CodingKeys: String, CodingKey {
		case logoImage = "logo_path"
	}
}
