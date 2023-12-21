import UIKit


extension Array {
	func insertionIndexOf(_ element: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
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

extension UILabel {
	static func createTitleLabel(withTitle title: String, isHidden: Bool = false) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.text = title
		label.isHidden = isHidden
		label.numberOfLines = 0
		return label
	}
}

extension UIStackView {
	func addArrangedSubviews(_ views: UIView ...) {
		views.forEach { addArrangedSubview($0) }
	}
}

extension UIView {
	var parentViewController: UIViewController? {
		var parentResponder: UIResponder? = self
		while parentResponder != nil {
			parentResponder = parentResponder?.next

			guard let viewController = parentResponder as? UIViewController else { return nil }
			return viewController
		}
		return nil
	}

	func addSubviews(_ views: UIView ...) {
		views.forEach { addSubview($0) }
	}

	func createSpinnerView(withStyle style: UIActivityIndicatorView.Style, childOf view: UIView) -> UIActivityIndicatorView {
		let spinnerView = UIActivityIndicatorView(style: style)
		spinnerView.hidesWhenStopped = true
		spinnerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(spinnerView)
		return spinnerView
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

extension UITableViewCell: ReusableView {}

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
