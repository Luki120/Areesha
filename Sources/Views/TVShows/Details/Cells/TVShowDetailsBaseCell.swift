import UIKit

/// Base TV show details table view cell class to clean up initialization code with reusable components
class TVShowDetailsBaseCell: UITableViewCell {
	final let separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	final lazy var dateFormatter = createDateFormatter(dateFormat: "yyyy-MM-dd")
	final lazy var shortDateFormatter = createDateFormatter(dateFormat: "MMM d, yyyy")

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
