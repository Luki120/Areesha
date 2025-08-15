import UIKit

/// Class to represent the rating cell
final class RatingCell: UICollectionViewCell {
	private lazy var starImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(imageView)
		return imageView
	}()

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.pinViewToAllEdges(starImageView)
	}
}

// ! Configurable

extension RatingCell: Configurable {
	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: RatingCellViewModel) {
		starImageView.image = .init(systemName: viewModel.image)
	}
}
