import UIKit

// https://stackoverflow.com/questions/37102504/proper-naming-convention-for-a-delegate-method-with-no-arguments-except-the-dele
protocol SearchTextFieldViewDelegate: AnyObject {
	func didTapCloseButton(in searchTextFieldView: SearchTextFieldView)
	func didTapClearButton(in searchTextFieldView: SearchTextFieldView)
}

/// UIView subclass to display a custom text field to search for TV shows
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
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: textField.frame.height))
		textField.leftViewMode = .always
		textField.textColor = .label
		textField.placeholder = "Search for TV shows"
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

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupUI() {
		closeButton = createButton(usesAutoLayout: true)
		clearAllButton = createButton(withImage: "xmark.circle", tintColor: .darkGray)
		clearAllButton.alpha = 0

		addSubview(textFieldStackView)
		textFieldStackView.addArrangedSubviews(closeButton, searchTextField)

		searchTextField.addSubviews(searchIconImageView, clearButton)
		searchTextField.rightView = clearButton
		searchTextField.rightViewMode = .always
	}

	private func layoutUI() {
		pinViewToAllEdges(textFieldStackView)

		setupSizeConstraints(forView: searchTextField, width: 350, height: 50)

		searchIconImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor).isActive = true
		searchIconImageView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor, constant: 15).isActive = true
	}

	private func setupButtons() {
		closeButton.addAction(
			UIAction { [weak self] _ in
				guard let self = self else { return }
				self.delegate?.didTapCloseButton(in: self)
			},
			for: .touchUpInside
		)
		clearButton.addAction(
			UIAction { [weak self] _ in
				guard let self = self else { return }
				self.delegate?.didTapClearButton(in: self)
			},
			for: .touchUpInside
		)
	}

	// ! Reusable

	private func createButton(
		withImage systemName: String = "xmark.circle",
		tintColor: UIColor = .label,
		usesAutoLayout: Bool = false
	) -> UIButton {
		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: systemName) ?? UIImage()
		configuration.baseForegroundColor = tintColor

		let button = UIButton()
		button.configuration = configuration
		button.translatesAutoresizingMaskIntoConstraints = !usesAutoLayout
		return button
	}

}
