import UIKit

/// Class to represent the header image for the tracked tv show details view
final class TrackedTVShowDetailsHeaderView: BaseHeaderView {
	// ! Public

	/// Function to configure the view with its respective view model
	/// - Parameters:
	/// 	- with: The view's view model
	func configure(with viewModel: TrackedTVShowDetailsHeaderViewViewModel) {
		nameLabel.text = viewModel.episodeNameText

		Task.detached(priority: .background) {
			let image = try? await viewModel.fetchImage()
			await MainActor.run {
				UIView.transition(with: self.headerImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.headerImageView.image = image
				}
				UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
					self.nameLabel.alpha = 1
				}
			}
		}
	}
}
