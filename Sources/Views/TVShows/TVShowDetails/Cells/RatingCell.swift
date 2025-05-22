import UIKit


final class RatingCell: UICollectionViewCell {

	private lazy var starImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = .init(systemName: "star")
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

extension RatingCell {

	func configure(with viewModel: RatingCellViewModel) {
		starImageView.image = .init(systemName: viewModel.image)
	}

}
