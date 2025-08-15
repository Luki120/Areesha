import UIKit

/// Class to represent the tv show details cast cell
class MediaDetailsCastCell: MediaDetailsBaseCell {
	class var identifier: String {
		return String(describing: self)
	}

	final let castLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .body, size: 16)
		label.textColor = .label
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		castLabel.text = nil
	}

	override func setupUI() {
		contentView.addSubview(castLabel)
		super.setupUI()
	}

	override func layoutUI() {
		castLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
		castLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
		castLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
		castLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}
}

// ! Public

extension MediaDetailsCastCell {
	/// Function to configure the cell with its respective view model
	/// - Parameter viewModel: The cell's view model
	final func configure(with viewModel: MediaDetailsCastCellViewModel) {
		guard let cast = viewModel.cast else { return }
		castLabel.text = cast.isEmpty ? "Cast unknown" : viewModel.cast
	}
}
