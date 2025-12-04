import Foundation

/// View model struct for `MovieDetailsKeyInfoCell`
@MainActor
struct MovieDetailsKeyInfoCellViewModel {
	let airDate: String
	let director: String
	let duration: Double
}

nonisolated extension MovieDetailsKeyInfoCellViewModel: Hashable {}
