import Foundation

/// View model struct for `AppCell`
@MainActor
struct AppCellViewModel {
	let app: App
}

nonisolated extension AppCellViewModel: Hashable {}
