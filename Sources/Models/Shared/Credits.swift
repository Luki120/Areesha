import Foundation

/// Credits model struct
struct Credits: Codable {
	let cast: [Cast]
	let crew: [Crew]
}

/// Cast model struct
struct Cast: Codable {
	let name: String
}

/// Crew model struct
struct Crew: Codable {
	let job: String
	let name: String
}
