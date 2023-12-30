import UIKit

/// Class to represent the app table view cell
final class AppTableViewCell: UITableViewCell {

	static let identifier = "AppTableViewCell"

	private var appNameLabel, appDescriptionLabel: UILabel!

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	// ! Private

	private func setupUI() {
		appNameLabel = createAppLabel()
		appDescriptionLabel = createAppLabel(withFontSize: 10, textColor: .systemGray)

		contentView.addSubviews(appNameLabel, appDescriptionLabel)
		layoutUI()
	}

	private func layoutUI() {
		appNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
		appNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true

		appDescriptionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 2).isActive = true
		appDescriptionLabel.leadingAnchor.constraint(equalTo: appNameLabel.leadingAnchor).isActive = true
	}

	// ! Reusable

	private func createAppLabel(withFontSize size: CGFloat = 16, textColor: UIColor = .label) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: size)
		label.textColor = textColor
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

}

extension AppTableViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	///		- with: The cell's view model
	func configure(with viewModel: AppTableViewCellViewModel) {
		appNameLabel.text = viewModel.app.appName
		appDescriptionLabel.text = viewModel.app.appDescription
	}

}
