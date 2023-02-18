import UIKit

/// Class to represent the tv show details cast cell
final class ARTVShowDetailsCastTableViewCell: UITableViewCell {

	static let identifier = "ARTVShowDetailsCastTableViewCell"

	@UsesAutoLayout
	private var castLabel = UILabel()

	@UsesAutoLayout
	private var castCrewLabel = UILabel()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		castCrewLabel.text = nil
	}

	// ! Private

	private func setupUI() {
		castLabel = createLabel(withWeight: .bold)
		castCrewLabel = createLabel()

		layoutUI()
	}

	private func layoutUI() {
		castLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
		castLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true

		castCrewLabel.topAnchor.constraint(equalTo: castLabel.topAnchor).isActive = true
		castCrewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
		castCrewLabel.leadingAnchor.constraint(equalTo: castLabel.trailingAnchor, constant: 20).isActive = true
		castCrewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}

	// ! Reusable

	private func createLabel(withWeight weight: UIFont.Weight = .regular) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: weight)
		label.textColor = .label
		label.numberOfLines = 0
		contentView.addSubview(label)
		return label
	}

}

extension ARTVShowDetailsCastTableViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: ARTVShowDetailsCastTableViewCellViewModel) {
		castLabel.text = viewModel.displayCastText
		castCrewLabel.text = viewModel.displayCastCrewText
	}

}
