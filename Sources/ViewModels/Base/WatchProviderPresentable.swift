import Foundation

/// Enum that represents the watch providers' state
enum WatchProvidersState {
	case empty
	case available([TVShowDetailsProvidersCellViewModel])
}

/// Protocol for the setting the state for a watch provider
protocol WatchProviderPresentable {
	/// Function to make the watch provider's state
	/// - Parameters:
	///		- provider: An optional `WatchProvider`
	///		- region: The region
	/// - Returns: `WatchProvidersState`
	func makeState(from provider: WatchProvider?, region: String) -> WatchProvidersState
}

extension WatchProviderPresentable {
	func makeState(from provider: WatchProvider?, region: String = "AR") -> WatchProvidersState {
		guard let region = provider?.results[region] else { return .empty }

		let providers = Set((region.additionals ?? []) + (region.flatrate ?? []))

		let viewModels: [TVShowDetailsProvidersCellViewModel] = providers.compactMap { option in
			guard let url = Service.imageURL(.watchProviderLogo(option), size: "w200") else { return nil }
			return TVShowDetailsProvidersCellViewModel(imageURL: url)
		}

		return viewModels.isEmpty ? .empty : .available(viewModels)
	}	
}
