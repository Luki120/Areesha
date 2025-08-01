import UIKit

/// Class to represent the tv show details overview cell
class TVShowDetailsDescriptionCell: TVShowDetailsBaseCell {
	class var identifier: String {
		return "TVShowDetailsDescriptionCell"
	}

	final let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .body)
		label.textColor = .label
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		descriptionLabel.text = nil
	}

	override func setupUI() {
		contentView.addSubview(descriptionLabel)
		super.setupUI()
	}

	override func layoutUI() {
		contentView.pinViewToAllEdges(
			descriptionLabel,
			topConstant: 20,
			bottomConstant: -20,
			leadingConstant: 20,
			trailingConstant: -20
		)
	}
}

extension TVShowDetailsDescriptionCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	final func configure(with viewModel: TVShowDetailsDescriptionCellViewModel) {
		descriptionLabel.text = viewModel.description
	}
}
