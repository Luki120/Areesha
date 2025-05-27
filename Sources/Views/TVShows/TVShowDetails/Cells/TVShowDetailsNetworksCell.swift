import UIKit

/// Class to represent the tv show details networks cell
final class TVShowDetailsNetworksCell: TVShowDetailsBaseCell {
	static let identifier = "TVShowDetailsNetworksCell"

	@UsesAutoLayout
	private var networksTitleLabel = UILabel()

	@UsesAutoLayout
	private var networksNamesLabel = UILabel()

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		networksNamesLabel.text = nil
	}

	override func setupUI() {
		networksTitleLabel = createLabel(withWeight: .bold)
		networksNamesLabel = createLabel()
		super.setupUI()
	}

	override func layoutUI() {
		networksTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
		networksTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true

		networksNamesLabel.topAnchor.constraint(equalTo: networksTitleLabel.bottomAnchor, constant: 5).isActive = true
		networksNamesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
		networksNamesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
		networksNamesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
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

extension TVShowDetailsNetworksCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: TVShowDetailsNetworksCellViewModel) {
		networksTitleLabel.text = viewModel.networksTitleText
		networksNamesLabel.text = viewModel.networksNamesText
	}
}
