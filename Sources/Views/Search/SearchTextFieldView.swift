import UIKit

// https://stackoverflow.com/questions/37102504/proper-naming-convention-for-a-delegate-method-with-no-arguments-except-the-dele
@MainActor
protocol SearchTextFieldViewDelegate: AnyObject {
	func didTapCloseButton(in searchTextFieldView: SearchTextFieldView)
	func didTapClearButton(in searchTextFieldView: SearchTextFieldView)
}

/// UIView subclass to display a custom text field to search for movies or tv shows
final class SearchTextFieldView: UIView {
	@UsesAutoLayout
	private var textFieldStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.alignment = .center
		stackView.spacing = 8
		return stackView
	}()

	@UsesAutoLayout
	private var searchTextField: UITextField = {
		let textField = UITextField()
		textField.font = .preferredFont(forTextStyle: .headline)
		textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 45, height: textField.frame.height))
		textField.rightView = UIView(frame: .init(x: 0, y: 0, width: 45, height: textField.frame.height))
		textField.leftViewMode = .always
		textField.rightViewMode = .always
		textField.textColor = .label
		textField.placeholder = "Search for movies, tv shows"
		textField.adjustsFontForContentSizeCategory = true
		textField.layer.borderColor = UIColor.darkGray.cgColor
		textField.layer.borderWidth = 1
		textField.layer.cornerCurve = .continuous
		textField.layer.cornerRadius = 25
		return textField
	}()

	@UsesAutoLayout
	private var searchIconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "magnifyingglass")
		imageView.tintColor = .label
		imageView.clipsToBounds = true
		return imageView
	}()

	private var closeButton, clearAllButton: UIButton!

	var textField: UITextField { return searchTextField }
	var clearButton: UIButton { return clearAllButton }

	weak var delegate: SearchTextFieldViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupButtons()
	}

	// ! Private

	private func setupUI() {
		closeButton = createButton()
		clearAllButton = createButton(withTintColor: .darkGray)
		clearAllButton.alpha = 0

		addSubview(textFieldStackView)
		textFieldStackView.addArrangedSubviews(closeButton, searchTextField)

		searchTextField.addSubviews(searchIconImageView, clearAllButton)

		layoutUI()
	}

	private func layoutUI() {
		pinViewToAllEdges(textFieldStackView)

		[closeButton, clearAllButton].forEach { setupSizeConstraints(forView: $0, width: 30, height: 30) }
		setupSizeConstraints(forView: searchTextField, width: 350, height: 50)

		searchIconImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor).isActive = true
		searchIconImageView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor, constant: 15).isActive = true

		clearAllButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor).isActive = true
		clearAllButton.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: -15).isActive = true
	}

	private func setupButtons() {
		closeButton.addAction(
			UIAction { [weak self] _ in
				guard let self else { return }
				self.delegate?.didTapCloseButton(in: self)
			},
			for: .touchUpInside
		)
		clearAllButton.addAction(
			UIAction { [weak self] _ in
				guard let self else { return }
				self.delegate?.didTapClearButton(in: self)
			},
			for: .touchUpInside
		)
	}

	// ! Reusable

	private func createButton(withTintColor tintColor: UIColor = .label) -> UIButton {
		let button = UIButton()
		if #available(iOS 15.0, *) {
			var configuration: UIButton.Configuration = .plain()
			configuration.image = UIImage(systemName: "xmark.circle") ?? UIImage()
			configuration.baseForegroundColor = tintColor
			button.configuration = configuration
		}
		else {
			let configuration = UIImage.SymbolConfiguration(pointSize: 20)

			button.tintColor = tintColor
			button.setImage(.init(systemName: "xmark.circle", withConfiguration: configuration) ?? UIImage(), for: .normal)
		}
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}
}
