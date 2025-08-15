import UIKit

/// Class to represent the tv show details genre cell
final class TVShowDetailsGenreCell: MediaDetailsBaseCell {
	static let identifier = "TVShowDetailsGenreCell"

	private var genreLabel, episodeAverageDurationLabel, lastAirDateLabel, statusLabel: UILabel!

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		[genreLabel, episodeAverageDurationLabel, lastAirDateLabel, statusLabel].forEach {
			$0?.text = nil
		}
	}

	override func setupUI() {
		genreLabel = createLabel()
		episodeAverageDurationLabel = createLabel(numberOfLines: 1)

		lastAirDateLabel = createLabel(fontWeight: .light)
		statusLabel = createLabel(fontWeight: .light)

		contentView.addSubviews(genreLabel, separatorView, episodeAverageDurationLabel, lastAirDateLabel, statusLabel)
		super.setupUI()
	}

	override func layoutUI() {
		genreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
		genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
		genreLabel.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: -10).isActive = true

		separatorView.topAnchor.constraint(equalTo: genreLabel.topAnchor).isActive = true
		separatorView.trailingAnchor.constraint(equalTo: episodeAverageDurationLabel.leadingAnchor, constant: -10).isActive = true
		setupSizeConstraints(forView: separatorView, width: 1, height: 20)

		episodeAverageDurationLabel.topAnchor.constraint(equalTo: separatorView.topAnchor).isActive = true
		episodeAverageDurationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true

		// took me a while to figure out this fuckery 💀, but here's a ref for it:
		// https://gist.github.com/leptos-null/c26810604e62af00fbb16a3783a4cd26
		episodeAverageDurationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		lastAirDateLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 10).isActive = true
		lastAirDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
		lastAirDateLabel.leadingAnchor.constraint(equalTo: genreLabel.leadingAnchor).isActive = true

		statusLabel.topAnchor.constraint(equalTo: lastAirDateLabel.topAnchor).isActive = true
		statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}

	// ! Reusable

	private func createLabel(fontWeight: UIFont.Weight = .semibold, numberOfLines lines: Int = 0) -> UILabel {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .callout, weight: fontWeight, size: 15)
		label.textColor = .label
		label.numberOfLines = lines
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}
}

extension TVShowDetailsGenreCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: MediaDetailsGenreCellViewModel) {
		guard let genre = viewModel.genre,
			let episodeAverageDuration = viewModel.episodeAverageDuration,
			let lastAirDate = viewModel.lastAirDate,
			let status = viewModel.status else {
				genreLabel.text = "Unknown"
				episodeAverageDurationLabel.text = "0 min"
				lastAirDateLabel.text = "Last aired: "
				statusLabel.text = ""
				return
			}

		let date = dateFormatter.date(from: lastAirDate) ?? Date()

		genreLabel.text = genre
		episodeAverageDurationLabel.text = episodeAverageDuration
		lastAirDateLabel.text = "Last aired: \(shortDateFormatter.string(from: date))"
		statusLabel.text = status

		separatorView.isHidden = episodeAverageDuration.isEmpty ? true : false
	}
}
