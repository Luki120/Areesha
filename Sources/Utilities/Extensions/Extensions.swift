import UIKit


extension UIColor {
	static let areeshaPinkColor = UIColor(red: 0.78, green: 0.64, blue: 0.83, alpha: 1.0)
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
		view.addSubview(spinnerView)
		return spinnerView
	}

	func pinViewToAllEdges(
		_ view: UIView,
		topConstant: CGFloat = 0,
		bottomConstant: CGFloat = 0,
		leadingConstant: CGFloat = 0,
		trailingConstant: CGFloat = 0,
		pinToSafeArea: Bool = false
	) {
		guard pinToSafeArea else {
			NSLayoutConstraint.activate([
				view.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
				view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomConstant),
				view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant),
				view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant)
			])
			return
		}
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topConstant),
			view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant),
			view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: leadingConstant),
			view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: trailingConstant)
		])
	}

	func centerViewOnBothAxes(_ view: UIView) {
		NSLayoutConstraint.activate([
			view.centerXAnchor.constraint(equalTo: centerXAnchor),
			view.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	func setupHorizontalConstraints(forView view: UIView, leadingConstant: CGFloat, trailingConstant: CGFloat) {
		NSLayoutConstraint.activate([
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant),
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant)
		])
	}

	func setupSizeConstraints(forView view: UIView, width: CGFloat, height: CGFloat) {
		NSLayoutConstraint.activate([
			view.widthAnchor.constraint(equalToConstant: width),
			view.heightAnchor.constraint(equalToConstant: height)
		])
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
