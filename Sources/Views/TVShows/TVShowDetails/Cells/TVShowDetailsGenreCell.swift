import UIKit

/// Class to represent the tv show details genre cell
final class TVShowDetailsGenreCell: TVShowDetailsBaseCell {
	static let identifier = "TVShowDetailsGenreCell"

	private var genreLabel, episodeAverageDurationLabel, lastAirDateLabel, statusLabel: UILabel!

	@UsesAutoLayout
	private var separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray
		return view
	}()

	private lazy var dateFormatter = createDateFormatter(withDateFormat: "yyyy-MM-dd")
	private lazy var shortDateFormatter = createDateFormatter(withDateFormat: "MMM d, yyyy")

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		genreLabel.text = nil
		episodeAverageDurationLabel.text = nil
		lastAirDateLabel.text = nil
		statusLabel.text = nil
	}

	override func setupUI() {
		genreLabel = createLabel()
		episodeAverageDurationLabel = createLabel(numberOfLines: 1)

		lastAirDateLabel = createLabel(withWeight: .light)
		statusLabel = createLabel(withWeight: .light)

		contentView.addSubviews(genreLabel, separatorView, episodeAverageDurationLabel, lastAirDateLabel, statusLabel)
		super.setupUI()
	}

	override func layoutUI() {
		genreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
		genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
		genreLabel.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: -10).isActive = true

		separatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
		separatorView.trailingAnchor.constraint(equalTo: episodeAverageDurationLabel.leadingAnchor, constant: -10).isActive = true
		setupSizeConstraints(forView: separatorView, width: 1, height: 20)

		episodeAverageDurationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
		episodeAverageDurationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true

		// took me a while to figure out this fuckery 💀, but here's a ref for it:
		// https://gist.github.com/leptos-null/c26810604e62af00fbb16a3783a4cd26
		episodeAverageDurationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		lastAirDateLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 10).isActive = true
		lastAirDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
		lastAirDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true

		statusLabel.topAnchor.constraint(equalTo: lastAirDateLabel.topAnchor).isActive = true
		statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}

	// ! Reusable

	private func createLabel(withWeight weight: UIFont.Weight = .semibold, numberOfLines lines: Int = 0) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 15, weight: weight)
		label.textColor = .label
		label.numberOfLines = lines
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

	private func createDateFormatter(withDateFormat format: String) -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter
	}
}

extension TVShowDetailsGenreCell {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	///		- with: The cell's view model
	func configure(with viewModel: TVShowDetailsGenreCellViewModel) {
		guard let genreText = viewModel.genreText,
			let episodeAverageDurationText = viewModel.episodeAverageDurationText,
			let lastAirDateText = viewModel.lastAirDateText,
			let statusText = viewModel.statusText else {
				genreLabel.text = "Unknown"
				episodeAverageDurationLabel.text = "0 min"
				lastAirDateLabel.text = "Last aired: "
				statusLabel.text = ""
				return
			}

		let date = dateFormatter.date(from: lastAirDateText) ?? Date()

		genreLabel.text = genreText
		episodeAverageDurationLabel.text = episodeAverageDurationText
		lastAirDateLabel.text = "Last aired: \(shortDateFormatter.string(from: date))"
		statusLabel.text = statusText

		separatorView.isHidden = episodeAverageDurationText.isEmpty ? true : false
	}
}
