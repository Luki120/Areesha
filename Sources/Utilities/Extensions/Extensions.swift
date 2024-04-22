import UIKit


extension Array {
	func insertionIndex(of element: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
		var low = 0
		var high = self.count - 1

		while low <= high {
			let mid = (low + high) / 2

			if isOrderedBefore(self[mid], element) {
				low = mid + 1
			} else if isOrderedBefore(element, self[mid]) {
				high = mid - 1
			} else {
				return mid // found at position mid
			}
		}
		return low // not found, would be inserted at position low
	}
}

extension Double {
	func round(to places: Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return Darwin.round(self * divisor) / divisor
	}
}

extension NSMutableAttributedString {
	convenience init(fullString: String, fullStringColor: UIColor, subString: String, subStringColor: UIColor) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: fullStringColor, range: rangeOfFullString)
		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: subStringColor, range: rangeOfSubString)

		self.init(attributedString: attributedString)
	}

	convenience init(fullString: String, subString: String) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: rangeOfFullString)
		attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray, range: rangeOfSubString)
		attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: rangeOfFullString)
		attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 10), range: rangeOfSubString)

		self.init(attributedString: attributedString)
	}
}

extension Task where Success == Never, Failure == Never {
	static func sleep(seconds: Double) async throws {
		let nanoseconds = UInt64(seconds * 1_000_000_000)
		try await Task.sleep(nanoseconds: nanoseconds)
	}
}

extension UIBarButtonItem {
	static func createBackBarButtonItem(forTarget target: Any?, selector: Selector) -> UIBarButtonItem {
		return .init(
			image: UIImage(systemName: "chevron.backward.circle"),
			style: .plain,
			target: target,
			action: selector
		)
	}
}

extension UIColor {
	static let areeshaPinkColor = UIColor(red: 0.78, green: 0.64, blue: 0.83, alpha: 1.0)
}

extension UIImage {
	enum Asset: String {
		case movie = "Movie"
		case tmdb = "TMDB"
	}

	convenience init?(asset: Asset) {
		self.init(named: asset.rawValue)
	}
}

extension UILabel {
	static func createTitleLabel(withTitle title: String, isHidden: Bool = false) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.text = title
		label.isHidden = isHidden
		label.numberOfLines = 0
		return label
	}

	static func createContentUnavailableLabel(withMessage message: String) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.text = message
		label.alpha = 0
		label.textColor = .placeholderText
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}
}

extension UIStackView {
	func addArrangedSubviews(_ views: UIView ...) {
		views.forEach { addArrangedSubview($0) }
	}
}

extension UITapGestureRecognizer {
	func didTapAttributedText(inLabel label: UILabel, inRange targetRange: NSRange) -> Bool {
		guard let attributedString = label.attributedText else { return false }

		let layoutManager = NSLayoutManager()
		let textContainer = NSTextContainer(size: .zero)
		let textStorage = NSTextStorage(attributedString: attributedString)

		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		textContainer.lineBreakMode = label.lineBreakMode
		textContainer.lineFragmentPadding = 0
		textContainer.maximumNumberOfLines = label.numberOfLines

		let labelSize = label.bounds.size
		textContainer.size = labelSize

		let locationOfTouchInLabel = self.location(in: label)
		let textBoundingBox = layoutManager.usedRect(for: textContainer)
		let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
		let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
		let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

		return NSLocationInRange(indexOfCharacter, targetRange)
	}
}

extension UIView {
	var parentViewController: UIViewController? {
		sequence(first: self) { $0.next }
			.lazy.compactMap { $0 as? UIViewController }
			.first
	}

	func addSubviews(_ views: UIView ...) {
		views.forEach { addSubview($0) }
	}

	func createSeasonsButton() -> UIButton {
		let button = UIButton()
		if #available(iOS 15.0, *) {
			var configuration: UIButton.Configuration = .plain()
			configuration.title = "Seasons"
			configuration.baseForegroundColor = .label
			button.configuration = configuration
		}
		else {
			button.setTitle("Seasons", for: .normal)
			button.setTitleColor(.label, for: .normal)
		}
		button.backgroundColor = .areeshaPinkColor
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerCurve = .continuous
		button.layer.cornerRadius = 25
		button.layer.shadowColor = UIColor.label.cgColor
		button.layer.shadowOffset = .init(width: 0, height: 0)
		button.layer.shadowOpacity = 0.5
		button.layer.shadowRadius = 4
		return button
	}

	func createSpinnerView(withStyle style: UIActivityIndicatorView.Style, childOf view: UIView) -> UIActivityIndicatorView {
		let spinnerView = UIActivityIndicatorView(style: style)
		spinnerView.hidesWhenStopped = true
		spinnerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(spinnerView)
		return spinnerView
	}

	func createToastView() -> UIView {
		let view = UIView()
		view.alpha = 0
		view.transform = .init(scaleX: 0.1, y: 0.1)
		view.backgroundColor = .areeshaPinkColor
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 20
		view.layer.shadowColor = UIColor.label.cgColor
		view.layer.shadowOffset = .init(width: 0, height: 0)
		view.layer.shadowOpacity = 0.2
		view.layer.shadowRadius = 4
		return view
	}

	func createToastViewLabel(withMessage message: String) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.text = message
		label.textColor = .label
		label.numberOfLines = 1
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

	func animateToastView(_ toastView: UIView) {
		UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
			toastView.alpha = 1
			toastView.transform = .init(scaleX: 1, y: 1)

			Task {
				try await Task.sleep(seconds: 2)
				UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
					toastView.alpha = 0
					toastView.transform = .init(scaleX: 0.1, y: 0.1)
				}
			}
		}
	}

	func pinViewToAllEdges(
		_ view: UIView,
		topConstant: CGFloat = 0,
		bottomConstant: CGFloat = 0,
		leadingConstant: CGFloat = 0,
		trailingConstant: CGFloat = 0
	) {
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomConstant),
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant),
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant)
		])
	}

	func pinViewToSafeAreas(
		_ view: UIView,
		topConstant: CGFloat = 0,
		bottomConstant: CGFloat = 0,
		leadingConstant: CGFloat = 0,
		trailingConstant: CGFloat = 0
	) {
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topConstant),
			view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant),
			view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: leadingConstant),
			view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: trailingConstant)
		])
	}

	func centerViewOnBothAxes(_ view: UIView) {
		view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}

	func setupHorizontalConstraints(forView view: UIView, leadingConstant: CGFloat = 0, trailingConstant: CGFloat = 0) {
		view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant).isActive = true
		view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant).isActive = true
	}

	func setupSizeConstraints(forView view: UIView, width: CGFloat, height: CGFloat) {
		view.widthAnchor.constraint(equalToConstant: width).isActive = true
		view.heightAnchor.constraint(equalToConstant: height).isActive = true
	}
}

private protocol ReusableView {
	static var reuseIdentifier: String { get }
}

private extension ReusableView {
	static var reuseIdentifier: String { return String(describing: self) }
}

extension UICollectionViewCell: ReusableView {}

extension UITableViewCell: ReusableView {}

extension UICollectionView {
	func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UICollectionViewCell {
		guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("L")
		}
		return cell
	}
}

extension UITableView {
	func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UITableViewCell {
		guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("L")
		}
		return cell
	}
}

@propertyWrapper
struct UsesAutoLayout<T: UIView> {

	var wrappedValue: T {
		didSet {
			wrappedValue.translatesAutoresizingMaskIntoConstraints = false
		}
	}

	init(wrappedValue: T) {
		self.wrappedValue = wrappedValue
		wrappedValue.translatesAutoresizingMaskIntoConstraints = false
	}

}
