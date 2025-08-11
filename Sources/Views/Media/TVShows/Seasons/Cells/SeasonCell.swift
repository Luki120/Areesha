import UIKit

/// Class to represent the tv show season collection view cell
final class SeasonCell: UICollectionViewCell {
	static let identifier = "SeasonCell"

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
		label.font = .preferredFont(forTextStyle: .title3, weight: .bold, size: 18)
		label.textColor = .label
		label.numberOfLines = 2
		label.textAlignment = .center
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private var activeViewModel: SeasonCellViewModel?

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		activeViewModel = nil
		seasonNameLabel.text = nil
		tvShowSeasonImageView.image = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		contentView.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		contentView.layer.shadowColor = UIColor.label.cgColor
		contentView.layer.shadowOpacity = 0.2
		contentView.layer.shadowRadius = 15
		contentView.addSubviews(tvShowSeasonImageView, seasonNameLabel)

		layoutUI()
	}

	private func layoutUI() {
		contentView.pinViewToAllEdges(tvShowSeasonImageView)

		seasonNameLabel.topAnchor.constraint(equalTo: tvShowSeasonImageView.bottomAnchor, constant: 10).isActive = true
		seasonNameLabel.leadingAnchor.constraint(equalTo: tvShowSeasonImageView.leadingAnchor).isActive = true
		seasonNameLabel.trailingAnchor.constraint(equalTo: tvShowSeasonImageView.trailingAnchor).isActive = true
	}
}

extension SeasonCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: SeasonCellViewModel) {
		activeViewModel = viewModel
		seasonNameLabel.text = viewModel.seasonName

		Task(priority: .background) {
			let image = try? await viewModel.fetchImage()
			await MainActor.run {
				guard self.activeViewModel == viewModel else { return }

				UIView.transition(with: self.tvShowSeasonImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowSeasonImageView.alpha = 1
					self.tvShowSeasonImageView.image = image
				}
			}
		}
	}
}
