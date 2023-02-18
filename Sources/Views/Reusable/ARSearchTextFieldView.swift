import UIKit

// https://stackoverflow.com/questions/37102504/proper-naming-convention-for-a-delegate-method-with-no-arguments-except-the-dele
protocol ARSearchTextFieldViewDelegate: AnyObject {
	func didTapCloseButtonInSearchTextFieldView()
}

/// Reusable UIView subclass to display a custom text field to search for TV shows
final class ARSearchTextFieldView: UIView {

	@UsesAutoLayout
	private var textFieldStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.alignment = .center
		stackView.spacing = 8
		return stackView
	}()

	@UsesAutoLayout
	private var closeButton: UIButton = {
		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: "xmark.circle")
		configuration.baseForegroundColor = .label
		return UIButton(configuration: configuration)
	}()

	@UsesAutoLayout
	private var searchTextField: UITextField = {
		let textField = UITextField()
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: textField.frame.height))
		textField.leftViewMode = .always
		textField.textColor = .label
		textField.placeholder = "Search for your favorite TV shows"
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

	var textField: UITextField { return searchTextField }

	weak var delegate: ARSearchTextFieldViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		closeButton.addAction(
			UIAction { [weak self] _ in self?.delegate?.didTapCloseButtonInSearchTextFieldView() },
			for: .touchUpInside
		)
		setupUI()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupUI() {
		addSubview(textFieldStackView)
		textFieldStackView.addArrangedSubviews(closeButton, searchTextField)
		searchTextField.addSubview(searchIconImageView)
	}

	private func layoutUI() {
		pinViewToAllEdges(textFieldStackView)

		setupSizeConstraints(forView: searchTextField, width: 350, height: 50)

		searchIconImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor).isActive = true
		searchIconImageView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor, constant: 15).isActive = true
	}

}
