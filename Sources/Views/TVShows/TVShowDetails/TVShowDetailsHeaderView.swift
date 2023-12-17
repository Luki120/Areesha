import UIKit

/// Class to represent the header image for the tv show details view
final class TVShowDetailsHeaderView: BaseHeaderView {

	private var ratingsLabel: UILabel!

	// ! Lifecycle

	override func setupUI() {
		super.setupUI()
		ratingsLabel = createLabel()
		containerView.addSubview(ratingsLabel)

		layoutUI()
	}

	override func layoutUI() {
		super.layoutUI()
		nameLabel.trailingAnchor.constraint(equalTo: ratingsLabel.leadingAnchor, constant: -10).isActive = true

		nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		ratingsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
		ratingsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true

		ratingsLabel.setContentHuggingPriority(.required, for: .horizontal)
		ratingsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
	}

}

extension TVShowDetailsHeaderView {

	// ! Public

	/// Function to configure the view with its respective view model
	/// - Parameters:
	/// 	- with: The view's view model
	func configure(with viewModel: TVShowDetailsHeaderViewViewModel) {
		nameLabel.text = viewModel.tvShowNameText
		ratingsLabel.text = viewModel.ratingsText

		Task.detached(priority: .background) {
			let image = try? await viewModel.fetchImage()
			await MainActor.run {
				UIView.transition(with: self.headerImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.headerImageView.image = image
				}
				UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
					[self.nameLabel, self.ratingsLabel].forEach { $0.alpha = 1 }
				}
			}
		}
	}

}
