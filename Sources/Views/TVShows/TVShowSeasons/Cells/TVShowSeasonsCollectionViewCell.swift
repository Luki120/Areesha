import UIKit

/// Class to represent the tv show seasons collection view cell
final class TVShowSeasonsCollectionViewCell: UICollectionViewCell {

	static let identifier = "TVShowSeasonsCollectionViewCell"

	@UsesAutoLayout
	private var tvShowSeasonImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 5
		return imageView
	}()

	@UsesAutoLayout
	private var seasonNameLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .bold)
		label.textColor = .label
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		contentView.pinViewToAllEdges(tvShowSeasonImageView)

		seasonNameLabel.centerXAnchor.constraint(equalTo: tvShowSeasonImageView.centerXAnchor).isActive = true
		seasonNameLabel.topAnchor.constraint(equalTo: tvShowSeasonImageView.bottomAnchor, constant: 10).isActive = true
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		tvShowSeasonImageView.image = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		contentView.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		contentView.layer.shadowColor = UIColor.label.cgColor
		contentView.layer.shadowOpacity = 0.4
		contentView.layer.shadowRadius = 15
		contentView.addSubviews(tvShowSeasonImageView, seasonNameLabel)
	}

}

// ! Public

extension TVShowSeasonsCollectionViewCell {

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	/// 	- with: The cell's view model
	func configure(with viewModel: TVShowSeasonsCollectionViewCellViewModel) {
		seasonNameLabel.text = viewModel.displaySeasonNameText

		Task.detached(priority: .background) {
			let image = try? await viewModel.fetchTVShowSeasonImage()
			await MainActor.run {
				UIView.transition(with: self.tvShowSeasonImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowSeasonImageView.alpha = 1
					self.tvShowSeasonImageView.image = image
				}
			}
		}		
	}

}
