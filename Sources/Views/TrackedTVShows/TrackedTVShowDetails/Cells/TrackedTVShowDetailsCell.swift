import UIKit

/// Class to represent the tracked tv show details episode details cell
final class TrackedTVShowDetailsCell: TVShowDetailsBaseCell {
	static let identifier = "TrackedTVShowDetailsCell"

	private var episodeNumberLabel, episodeAirDateLabel: UILabel!

	private lazy var dateFormatter = createDateFormatter(withDateFormat: "yyyy-MM-dd")
	private lazy var shortDateFormatter = createDateFormatter(withDateFormat: "MMM d, yyyy")

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
		label.font = .systemFont(ofSize: 18)
		label.textColor = .label
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

	private func createDateFormatter(withDateFormat format: String) -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter
	}
}

extension TrackedTVShowDetailsCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	///		- with: The cell's view model
	func configure(with viewModel: TrackedTVShowDetailsCellViewModel) {
		let date = dateFormatter.date(from: viewModel.episodeAirDate) ?? Date()

		episodeNumberLabel.text = "Episode \(viewModel.episodeNumber)"
		episodeAirDateLabel.text = shortDateFormatter.string(from: date)
	}
}
