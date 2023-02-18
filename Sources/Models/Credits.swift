import Foundation

/// API model struct
struct Credits: Codable {
	let cast: [Cast]
}

struct Cast: Codable {
	let name: String
}
