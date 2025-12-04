import UIKit

/// `UIButton` subclass that represents a rounded blurred button, to use with navigation items
final class RoundedBlurredButton: UIButton {
	private lazy var blurEffectView: UIVisualEffectView = {
		let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
		effectView.frame = bounds
		effectView.backgroundColor = .clear
		effectView.isUserInteractionEnabled = false

		if let imageView {
			imageView.backgroundColor = .clear
			bringSubviewToFront(imageView)
		}

		return effectView
	}()

	private var darkStyle: Void {
		tintColor = .white
		backgroundColor = nil
		blurEffectView.alpha = 1
	}

	private var lightStyle: Void {
		tintColor = .areeshaPinkColor
		backgroundColor = .tertiarySystemFill
		blurEffectView.alpha = 0
	}

	enum ViewContext {
		case normal
		case header(status: Bool)
	}

	private let systemVersion = Double(UIDevice.current.systemVersion) ?? 0

	let systemImage: String
	let isHeader: Bool

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	///
	/// - Parameters:
	/// 	- systemImage: A `String` that represents the image's system name
	/// 	- isHeader: A `Bool` to check if the button is overlapping a `UITableView` header, defaults to `false`
	init(systemImage: String, isHeader: Bool = false) {
		self.systemImage = systemImage
		self.isHeader = isHeader
		super.init(frame: .zero)
		setupUI()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard systemVersion < 26.0 else { return }

		if !isHeader {
			setupStyles()
		}
	}

	// ! Private

	private func setupUI() {
		frame = .init(origin: .zero, size: .init(width: 28, height: 28))

		let imageConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
		setImage(.init(systemName: systemImage, withConfiguration: imageConfig), for: .normal)

		guard systemVersion < 26.0 else { return }

		clipsToBounds = true
		layer.cornerRadius = 14
		insertSubview(blurEffectView, at: 0)

		setupStyles()
	}
}

// ! Public

extension RoundedBlurredButton {
	/// Function to setup the button's styling
	///
	/// - Parameter context: The `ViewContext` object
	func setupStyles(for context: ViewContext = .normal) {
		switch context {
			case .normal: traitCollection.userInterfaceStyle == .dark ? darkStyle : lightStyle
			case .header(let status):
				guard traitCollection.userInterfaceStyle == .light else { return }
				status ? lightStyle : darkStyle
		}
	}
}
