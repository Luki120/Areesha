import Foundation

/// View model class for `RatedMovieCell`
@MainActor
final class RatedMovieCellViewModel: Hashable, ImageFetching, ObservableObject {
	let id: Int
	let ratedMovie: RatedMovie

	var imageURL: URL?
	var credits: Credits?

	var leadActorName: String {
		return credits?.cast.first?.name ?? ""
	}

	@Published var rating: Double

	/// Designated initializer
	/// - Parameter model: The `RatedMovie` object
	init(_ ratedMovie: RatedMovie) {
		self.id = ratedMovie.id
		self.ratedMovie = ratedMovie
		self.rating = ratedMovie.rating
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	nonisolated
	static func == (lhs: RatedMovieCellViewModel, rhs: RatedMovieCellViewModel) -> Bool {
		return lhs.id == rhs.id
	}
}
