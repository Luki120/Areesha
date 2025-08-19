import Foundation

/// View model struct for `MovieDetailsKeyInfoCell`
@MainActor
struct MovieDetailsKeyInfoCellViewModel: Hashable {
	let airDate: String
	let director: String
	let duration: Double
}
