import UIKit

/// `UITableViewCell` subclass that'll show information like the movie's director, revenue, etc
final class MovieDetailsKeyInfoCell: MediaDetailsBaseCell {
	static let identifier = "MovieDetailsKeyInfoCell"

	private var airDateLabel, directorLabel, durationLabel: UILabel!

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		[airDateLabel, directorLabel, durationLabel].forEach { $0?.text = nil }
	}

	override func setupUI() {
		airDateLabel = createLabel()
		directorLabel = createLabel(numberOfLines: 1)
		durationLabel = createLabel(numberOfLines: 1)

		super.setupUI()
	}

	override func layoutUI() {
		NSLayoutConstraint.activate([
			directorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			directorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			directorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

			airDateLabel.topAnchor.constraint(equalTo: directorLabel.bottomAnchor, constant: 10),
			airDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			airDateLabel.leadingAnchor.constraint(equalTo: directorLabel.leadingAnchor),

			durationLabel.topAnchor.constraint(equalTo: airDateLabel.topAnchor),
			durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
		])
	}
}

// ! Public

extension MovieDetailsKeyInfoCell {
	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: MovieDetailsKeyInfoCellViewModel) {
		let airDate = dateFormatter.date(from: viewModel.airDate) ?? Date()

		airDateLabel.attributedText = .init(
			fullString: (airDate > Date() ? "Air date: " : "Aired: ") + shortDateFormatter.string(from: airDate),
			subString: (airDate > Date() ? "Air date: " : "Aired: "),
			attributes: [.font: UIFont.preferredFont(forTextStyle: .callout, weight: .regular, size: 15)],
			subStringAttributes: [.font: UIFont.preferredFont(forTextStyle: .callout, weight: .medium, size: 15)]
		)
		directorLabel.text = "Directed by: " + (viewModel.director.isEmpty ? "Unknown" : viewModel.director)

		let duration = viewModel.duration
		durationLabel.text = duration == 0 ? "" : Formatter.hourFormatter.string(from: viewModel.duration * 60)
	}
}

private extension Formatter {
	static let hourFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.hour, .minute]
		return formatter
	}()
}

private extension NSAttributedString {
	convenience init(
		fullString: String,
		subString: String,
		attributes: [NSAttributedString.Key: Any] = [:],
		subStringAttributes: [NSAttributedString.Key: Any] = [:]
	) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		attributedString.addAttributes(attributes, range: rangeOfFullString)
		attributedString.addAttributes(subStringAttributes, range: rangeOfSubString)

		self.init(attributedString: attributedString)
	}
}