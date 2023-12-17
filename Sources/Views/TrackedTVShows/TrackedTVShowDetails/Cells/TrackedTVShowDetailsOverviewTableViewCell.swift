import UIKit

/// Class to represent the tracked tv show details overview cell
final class TrackedTVShowDetailsOverviewTableViewCell: TVShowDetailsBaseTableViewCell {

	static let identifier = "TrackedTVShowDetailsOverviewTableViewCell"

	@UsesAutoLayout
	private var overviewLabel: UILabel = {
		let label = UILabel()
		label.textColor = .label
		label.numberOfLines = 0
		return label
	}()

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		overviewLabel.text = nil
	}

	override func setupUI() {
		contentView.addSubview(overviewLabel)
		super.setupUI()
	}

	override func layoutUI() {
		contentView.pinViewToAllEdges(
			overviewLabel,
			topConstant: 20,
			bottomConstant: -20,
			leadingConstant: 20,
			trailingConstant: -20
		)
	}

}

extension TrackedTVShowDetailsOverviewTableViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: TrackedTVShowDetailsOverviewTableViewCellViewModel) {
		overviewLabel.text = viewModel.overviewText
	}

}
