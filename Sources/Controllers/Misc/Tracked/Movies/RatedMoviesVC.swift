import UIKit

/// Controller that'll show the rated movies view
final class RatedMoviesVC: BaseVC {
	private let ratedMoviesView = RatedMoviesView()

	var coordinator: TrackedMediaCoordinator?

	// ! Lifecycle

	override func loadView() { view = ratedMoviesView }

	override func viewDidLoad() {
		super.viewDidLoad()

		ratedMoviesView.delegate = self
		ratedMoviesView.backgroundColor = .systemBackground
	}

	override func didTapLeftBarButton() {
		coordinator?.eventOccurred(with: .backButtonTapped)
	}
}

// ! RatedMoviesViewDelegate

extension RatedMoviesVC: RatedMoviesViewDelegate {
	func ratedMoviesView(_ ratedMoviesView: RatedMoviesView, didTap ratedMovie: RatedMovie) {
		guard let movie = ratedMovie.movie else { return }
		coordinator?.eventOccurred(with: .ratedMovieCellTapped(movie: movie))
	}
}
