import UIKit

/// Class to represent the top header collection view cell
final class TopHeaderCell: UICollectionViewCell {
	@UsesAutoLayout
	private var cellLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.textColor = .darkGray
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()

 	override var isSelected: Bool {
		didSet {
			UIView.transition(with: cellLabel, duration: 0.5, options: .transitionCrossDissolve) {
				self.cellLabel.textColor = self.isSelected ? .label : .darkGray
			}
		}
	}

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(cellLabel)
		contentView.centerViewOnBothAxes(cellLabel)
	}
}

// ! Configurable

extension TopHeaderCell: Configurable {
	func configure(with viewModel: TopHeaderCellViewModel) {
		cellLabel.text = viewModel.sectionName
	}
}
