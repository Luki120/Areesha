import UIKit

/// Class to represent the episode collection view cell
final class EpisodeCollectionViewCell: UICollectionViewCell {

 	override var isHighlighted: Bool {
		didSet {
			contentView.backgroundColor = isHighlighted ? .systemGray3 : .clear
		}
	}

	@UsesAutoLayout
	private var episodeImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 10
		return imageView
	}()

	private var episodeNameLabel, episodeDurationLabel, episodeDescriptionLabel: UILabel!

	private var activeViewModel: EpisodeCollectionViewCellViewModel?

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
		episodeImageView.image = nil
		[episodeNameLabel, episodeDurationLabel, episodeDescriptionLabel].forEach { $0.text = nil }
	}

	// ! Private

	private func setupUI() {
		episodeNameLabel = createLabel()
		episodeDurationLabel = createLabel(withFontSize: 12, textColor: .secondaryLabel)
		episodeDescriptionLabel = createLabel(textColor: .secondaryLabel)
		contentView.addSubviews(episodeImageView, episodeNameLabel, episodeDurationLabel, episodeDescriptionLabel)

		layoutUI()
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			episodeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			episodeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			episodeImageView.widthAnchor.constraint(equalToConstant: 140),
			episodeImageView.heightAnchor.constraint(equalToConstant: 80),

			episodeNameLabel.topAnchor.constraint(equalTo: episodeImageView.topAnchor, constant: 20),
			episodeNameLabel.leadingAnchor.constraint(equalTo: episodeImageView.trailingAnchor, constant: 10),
			episodeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

			episodeDurationLabel.topAnchor.constraint(equalTo: episodeNameLabel.bottomAnchor, constant: 2.5),
			episodeDurationLabel.leadingAnchor.constraint(equalTo: episodeNameLabel.leadingAnchor),

			episodeDescriptionLabel.topAnchor.constraint(equalTo: episodeImageView.bottomAnchor, constant: 10),
			episodeDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			episodeDescriptionLabel.leadingAnchor.constraint(equalTo: episodeImageView.leadingAnchor),
			episodeDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
		])
	}

	// ! Reusable

	private func createLabel(withFontSize size: CGFloat = 14, textColor: UIColor = .label) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: size)
		label.textColor = textColor
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

}

extension EpisodeCollectionViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	///     - with: The cell's view model
	func configure(with viewModel: EpisodeCollectionViewCellViewModel) {
		activeViewModel = viewModel

		episodeNameLabel.text = viewModel.episodeNameText
		episodeDurationLabel.text = viewModel.episodeDurationText
		episodeDescriptionLabel.text = viewModel.episodeDescriptionText

		Task.detached(priority: .background) {
			let image = try? await viewModel.fetchImage()
			await MainActor.run {
				guard self.activeViewModel == viewModel else { return }

				UIView.transition(with: self.episodeImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.episodeImageView.image = image
				}
			}
		}
	}

}
