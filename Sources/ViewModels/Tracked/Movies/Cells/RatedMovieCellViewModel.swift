import Foundation

/// View model struct for `RatedMovieCell`
@MainActor
struct RatedMovieCellViewModel: Hashable, ImageFetching {
	private let id: Int
	private let credits: Credits

	let rating: Double
	let ratedMovie: RatedMovie
	var imageURL: URL?

	var leadActorName: String {
		return credits.cast.first?.name ?? ""
	}

	/// Designated initializer
	/// - Parameter model: The `RatedMovie` object
	init(_ ratedMovie: RatedMovie) {
		self.id = ratedMovie.id
		self.rating = ratedMovie.rating
		self.credits = ratedMovie.movie?.credits ?? Credits(cast: [], crew: [])
		self.ratedMovie = ratedMovie
	}
}
