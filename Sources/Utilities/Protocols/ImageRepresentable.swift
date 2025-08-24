import Foundation

/// Protocol that provides relative image paths for different media assets
protocol ImageRepresentable {
	var logoPath: String? { get }
	var posterPath: String? { get }
	var backdropPath: String? { get }
}

extension ImageRepresentable {
	var logoPath: String? { return nil }
	var posterPath: String? { return nil }
	var backdropPath: String? { return nil }
}
