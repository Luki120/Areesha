import Foundation

/// Account response model struct
struct AccountResponse: Codable {
	let id: Int
}

/// Token response model struct
struct TokenResponse: Codable {
	let requestToken: String

	enum CodingKeys: String, CodingKey {
		case requestToken = "request_token"
	}
}

/// Session id response model struct
struct SessionIdResponse: Codable {
	let sessionId: String

	enum CodingKeys: String, CodingKey {
		case sessionId = "session_id"
	}
}
