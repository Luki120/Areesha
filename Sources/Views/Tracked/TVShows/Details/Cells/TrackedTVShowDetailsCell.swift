import UIKit

/// Class to represent the tracked tv show details episode details cell
final class TrackedTVShowDetailsCell: MediaDetailsBaseCell {
	static let identifier = "TrackedTVShowDetailsCell"

	private var episodeNumberLabel, episodeAirDateLabel: UILabel!

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		episodeNumberLabel.text = nil
		episodeAirDateLabel.text = nil
	}

	override func setupUI() {
		episodeNumberLabel = createLabel()
		episodeAirDateLabel = createLabel()

		contentView.addSubviews(episodeNumberLabel, episodeAirDateLabel)
		super.setupUI()
	}

	override func layoutUI() {
		episodeNumberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
		episodeNumberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
		episodeNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true

		episodeAirDateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
		episodeAirDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
		episodeAirDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}

	// ! Reusable

	private func createLabel() -> UILabel {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .body, size: 18)
		label.textColor = .label
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}
}

extension TrackedTVShowDetailsCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: TrackedTVShowDetailsCellViewModel) {
		let date = dateFormatter.date(from: viewModel.episodeAirDate) ?? Date()

		episodeNumberLabel.text = "Episode \(viewModel.episodeNumber)"
		episodeAirDateLabel.text = shortDateFormatter.string(from: date)
	}
}
