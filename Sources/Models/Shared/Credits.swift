import Foundation

/// Credits model struct
struct Credits: Codable, Hashable {
	let cast: [Cast]
	let crew: [Crew]
}

/// Cast model struct
struct Cast: Codable, Hashable {
	let name: String
}

/// Crew model struct
struct Crew: Codable, Hashable {
	let job: String
	let name: String
}
