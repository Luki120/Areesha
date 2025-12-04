import Foundation

/// View model struct for `TVShowDetailsGenreCell`
@MainActor
struct MediaDetailsGenreCellViewModel {
	let genre: String?
	let episodeAverageDuration: String?
	let lastAirDate: String?
	let status: String?
	let budget: Int?
	let revenue: Int?

	var budgetRevenueType: BudgetRevenueType = .revenue

	enum BudgetRevenueType {
		case budget, revenue
	}

	/// Designated initializer
	/// - Parameters:
	///		- genre: A nullable `String` to represent the genre
	///		- episodeAverageDuration: A nullable `String` to represent the episode average duration
	///		- lastAirDate: A nullable `String` to represent the last air date
	///		- status: A nullable `String` to represent the status
	///		- budget: A nullable `Int` to represent the budget for movies
	///		- revenue: A nullable `Int` to represent the revenue for movies
	init(
		genre: String? = nil,
		episodeAverageDuration: String? = nil,
		lastAirDate: String? = nil,
		status: String? = nil,
		budget: Int? = nil,
		revenue: Int? = nil
	) {
		self.genre = genre
		self.episodeAverageDuration = episodeAverageDuration
		self.lastAirDate = lastAirDate
		self.status = status
		self.budget = budget
		self.revenue = revenue
	}
}

nonisolated extension MediaDetailsGenreCellViewModel: Hashable {}
