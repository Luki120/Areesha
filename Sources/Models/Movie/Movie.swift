import Foundation

/// Movie model struct
struct Movie: Codable {
	let id: Int
	let title: String
	let description: String

	enum CodingKeys: String, CodingKey {
		case id
		case title
		case description = "overview"
	}
}
