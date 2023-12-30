import UIKit

/// Class to represent the app table view cell
final class AppTableViewCell: UITableViewCell {

	static let identifier = "AppTableViewCell"

	@UsesAutoLayout
	private var appNameLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		return label
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		contentView.addSubview(appNameLabel)
		layoutUI()
	}

	// ! Private

	private func layoutUI() {
		appNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
		appNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
		appNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
	}

}

extension AppTableViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	///		- with: The cell's view model
	func configure(with viewModel: AppTableViewCellViewModel) {
		appNameLabel.attributedText = NSMutableAttributedString(
			fullString: "\(viewModel.app.appName)\n\(viewModel.app.appDescription)",
			subString: viewModel.app.appDescription
		)
	}

}
