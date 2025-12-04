import Foundation

/// View model struct for the source code table view cell
@MainActor
struct SourceCodeCellViewModel {
	let text: String
}

nonisolated extension SourceCodeCellViewModel: Hashable {}
