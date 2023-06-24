import UIKit

/// Class to represent the header image for the details view
final class TVShowDetailsHeaderView: UIView {

	@UsesAutoLayout
	private var containerView: UIView = {
		let view = UIView()
		return view
	}()

	@UsesAutoLayout
	private var tvShowHeaderImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()

	private var tvShowNameLabel, ratingsLabel: UILabel!
	private var containerViewHeightConstraint: NSLayoutConstraint!
	private var tvShowHeaderImageViewBottomConstraint: NSLayoutConstraint!
	private var tvShowHeaderImageViewHeightConstraint: NSLayoutConstraint!

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	// ! Private

	private func setupUI() {
		tvShowNameLabel = createLabel(withFontWeight: .heavy)
		tvShowNameLabel.numberOfLines = 0
		ratingsLabel = createLabel()

		addSubview(containerView)
		containerView.addSubviews(tvShowHeaderImageView, tvShowNameLabel, ratingsLabel)
		layoutUI()
	}

	private func layoutUI() {
		containerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		tvShowHeaderImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true

		containerViewHeightConstraint = containerView.heightAnchor.constraint(equalTo: heightAnchor)
		containerViewHeightConstraint.isActive = true

		tvShowHeaderImageViewHeightConstraint = tvShowHeaderImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
		tvShowHeaderImageViewHeightConstraint.isActive = true

		tvShowHeaderImageViewBottomConstraint = tvShowHeaderImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		tvShowHeaderImageViewBottomConstraint.isActive = true

		tvShowNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
		tvShowNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
		tvShowNameLabel.trailingAnchor.constraint(equalTo: ratingsLabel.leadingAnchor, constant: -10).isActive = true

		tvShowNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		ratingsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
		ratingsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true

		ratingsLabel.setContentHuggingPriority(.required, for: .horizontal)
		ratingsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
	}

	// ! Reusable

	private func createLabel(withFontWeight weight: UIFont.Weight = .bold) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 24, weight: weight)
		label.alpha = 0
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

}

extension TVShowDetailsHeaderView {

	// ! Public

	/// Function to configure the view with its respective view model
	/// - Parameters:
	/// 	- with: The view's view model
	func configure(with viewModel: TVShowDetailsHeaderViewViewModel) {
		tvShowNameLabel.text = viewModel.tvShowNameText
		ratingsLabel.text = viewModel.ratingsText

		Task.detached(priority: .background) {
			let image = try? await viewModel.fetchImage()
			await MainActor.run {
				UIView.transition(with: self.tvShowHeaderImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowHeaderImageView.image = image
				}
				UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
					[self.tvShowNameLabel, self.ratingsLabel].forEach { $0.alpha = 1 }
				}
			}
		}
	}

	/// Function to notify the scroll view when the user started scrolling to act accordingly
	/// - Parameters:
	/// 	- scrollView: The scroll view
	func scrollViewDidScroll(scrollView: UIScrollView) {
		containerViewHeightConstraint.constant = scrollView.contentInset.top

		let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
		containerView.clipsToBounds = offsetY <= 0

		tvShowHeaderImageViewBottomConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
		tvShowHeaderImageViewHeightConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
	}

}
