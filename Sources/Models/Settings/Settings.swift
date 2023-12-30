import Foundation

/// Enum to represent each developer for the GitHub cell
@frozen enum Developer: String {
	case luki = "Luki120"
	case leptos = "Leptos"

	static let lukiName = luki.rawValue
	static let leptosName = leptos.rawValue

	static let lukiIcon = "https://avatars.githubusercontent.com/u/74214115?v=4"
	static let leptosIcon = "https://avatars.githubusercontent.com/u/40723121?v=4"

	static let lukiGitHubURL = URL(string: "https://github.com/Luki120")
	static let leptosGitHubURL = URL(string: "https://github.com/leptos-null")	
}

/// Enum to represent each app for the app cell
@frozen enum App: String {
	case azure = "Azure"
	case chelsea = "Chelsea"

	var appName: String {
		switch self {
			case .azure, .chelsea: return rawValue
		}
	}

	var appDescription: String {
		switch self {
			case .azure: return "FOSS TOTP 2FA app with a clean, straightforward UI"
			case .chelsea: return "Browse for jailbreak packages"
		}
	}

	var appURL: URL? {
		switch self {
			case .azure: return URL(string: "https://github.com/Luki120/Azure")
			case .chelsea: return URL(string: "https://github.com/Luki120/Chelsea")
		}
	}
}
