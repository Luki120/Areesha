import UIKit

/// Base media details table view cell class to clean up initialization code with reusable components
class MediaDetailsBaseCell: UITableViewCell {
	final let separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private(set) final lazy var dateFormatter = createDateFormatter(dateFormat: "yyyy-MM-dd")
	private(set) final lazy var shortDateFormatter = createDateFormatter(dateFormat: "MMM d, yyyy")

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	/// Function available to subclasses to setup the cell's UI
	func setupUI() {
		layoutUI()
	}

	/// Function available to subclasses to lay out the cell's UI
	func layoutUI() {}

	// ! Reusable

	private
	final func createDateFormatter(dateFormat: String) -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = dateFormat
		return dateFormatter
	}

	/// Function to create a reusable label
	/// - Parameter lines: An `Int` that represents the number of lines
	final func createLabel(numberOfLines lines: Int = 0) -> UILabel {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .callout, weight: .medium, size: 15)
		label.textColor = .label
		label.numberOfLines = lines
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		return label
	}
}

extension NSAttributedString {
	convenience init(
		fullString: String,
		subString: String,
		attributes: [NSAttributedString.Key: Any] = [:],
		subStringAttributes: [NSAttributedString.Key: Any] = [:]
	) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		attributedString.addAttributes(attributes, range: rangeOfFullString)
		attributedString.addAttributes(subStringAttributes, range: rangeOfSubString)

		self.init(attributedString: attributedString)
	}
}
