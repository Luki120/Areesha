import Foundation

/// Watch provider model struct
struct WatchProvider: Codable {
	let id: Int
	let results: [String: Region]
}

/// Region model struct
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

/// Watch option model struct
struct WatchOption: Codable, Hashable {
	let logoImage: String?

	enum CodingKeys: String, CodingKey {
		case logoImage = "logo_path"
	}
}
