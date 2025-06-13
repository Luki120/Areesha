import UIKit

/// Base class to implement a header view
class BaseHeaderView: UIView {
	private let addRatingsLabel: Bool

	@UsesAutoLayout
	private(set) var containerView: UIView = {
		let view = UIView()
		return view
	}()

	@UsesAutoLayout
	private(set) var headerImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
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
	/// - Parameters:
	///		- addRatingsLabel: Boolean value to decide wether the ratings label should be added or not
	init(addRatingsLabel: Bool = true) {
		self.addRatingsLabel = addRatingsLabel

		super.init(frame: .zero)
		setupUI()
	}

	/// Function to setup the UI
	func setupUI() {
		nameLabel = createLabel(withFontWeight: .heavy)
		nameLabel.numberOfLines = 0

		addSubview(containerView)
		containerView.addSubviews(headerImageView, nameLabel)

		if !addRatingsLabel { layoutUI() }
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
		nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true

		if !addRatingsLabel {
			nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
		}
	}

	// ! Reusable

	final func createLabel(withFontWeight weight: UIFont.Weight = .bold) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 24, weight: weight)
		label.alpha = 0
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}
}

extension BaseHeaderView {
	// ! Public

	/// Function to create a `UIBarButtonItem`
	///
	/// - Parameters:
	///		- systemImage: A `String` that represents the image's system name
	///		- target: The target
	///		- selector: The `Selector`
	/// - Returns: `UIBarButtonItem`
	final func createBarButtonItem(systemImage: String, target: Any?, action: Selector) -> UIBarButtonItem {
		let roundedBlurredButton: RoundedBlurredButton = .init(systemImage: systemImage, isHeader: true)
		roundedBlurredButton.addTarget(target, action: action, for: .touchUpInside)

		roundedBlurredButtons.append(roundedBlurredButton)
		return .init(customView: roundedBlurredButton)
	}

	/// Function to notify the scroll view when the user started scrolling to act accordingly
	///
	/// - Parameters:
	/// 	- scrollView: The scroll view
	final func scrollViewDidScroll(scrollView: UIScrollView) {
		containerViewHeightConstraint.constant = scrollView.contentInset.top

		let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
		containerView.clipsToBounds = offsetY <= 0

		headerImageViewBottomConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
		headerImageViewHeightConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
	}
}
