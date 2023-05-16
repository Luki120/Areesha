import UIKit

/// Base TV show details table view cell class to clean up initialization code
class TVShowDetailsBaseTableViewCell: UITableViewCell {

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	func setupUI() {
		layoutUI()
	}

	func layoutUI() {}

}
