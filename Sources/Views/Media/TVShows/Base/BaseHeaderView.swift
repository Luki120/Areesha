import UIKit

/// Base class to implement a header view
class BaseHeaderView: UIView {
	let addRatingsLabel: Bool

	final let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	final let headerImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private(set) var nameLabel: UILabel!
	private(set) var roundedBlurredButtons = [RoundedBlurredButton]()

	private var containerViewHeightConstraint: NSLayoutConstraint!
	private var headerImageViewBottomConstraint: NSLayoutConstraint!
	private var headerImageViewHeightConstraint: NSLayoutConstraint!

	// ! Lifecyle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter addRatingsLabel: `Bool` value to decide wether the ratings label should be added or not
	init(addRatingsLabel: Bool = true) {
		self.addRatingsLabel = addRatingsLabel

		super.init(frame: .zero)
		setupUI()
	}

	/// Function to setup the UI
	func setupUI() {
		nameLabel = createLabel(fontWeight: .heavy)
		nameLabel.numberOfLines = 0

		addSubview(containerView)
		containerView.addSubviews(headerImageView, nameLabel)
	}

	/// Function to layout the UI
	func layoutUI() {
		containerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		headerImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true

		containerViewHeightConstraint = containerView.heightAnchor.constraint(equalTo: heightAnchor)
		containerViewHeightConstraint.isActive = true

		headerImageViewHeightConstraint = headerImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
		headerImageViewHeightConstraint.isActive = true

		headerImageViewBottomConstraint = headerImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		headerImageViewBottomConstraint.isActive = true

		nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
		nameLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true

		if !addRatingsLabel {
			nameLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
		}
	}

	// ! Reusable

	final func createLabel(fontWeight weight: UIFont.Weight = .bold) -> UILabel {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .title2, weight: weight, size: 24)
		label.alpha = 0
		label.textColor = .white
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}
}

// ! Public

extension BaseHeaderView {
	/// Function to create a `UIBarButtonItem`
	///
	/// - Parameters:
	///		- systemImage: A `String` that represents the image's system name
	///		- target: The target
	///		- action: The `Selector`
	/// - Returns: `UIBarButtonItem`
	final func createBarButtonItem(systemImage: String, target: Any?, action: Selector) -> UIBarButtonItem {
		let roundedBlurredButton: RoundedBlurredButton = .init(systemImage: systemImage, isHeader: true)
		roundedBlurredButton.addTarget(target, action: action, for: .touchUpInside)

		roundedBlurredButtons.append(roundedBlurredButton)
		return .init(customView: roundedBlurredButton)
	}

	/// Function to notify the scroll view when the user started scrolling to act accordingly
	///
	/// - Parameter scrollView: The scroll view
	final func scrollViewDidScroll(scrollView: UIScrollView) {
		containerViewHeightConstraint.constant = scrollView.contentInset.top

		let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
		containerView.clipsToBounds = offsetY <= 0

		headerImageViewBottomConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
		headerImageViewHeightConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
	}
}
