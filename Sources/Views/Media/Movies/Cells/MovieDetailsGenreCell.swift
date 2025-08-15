import UIKit

/// `UITableViewCell` subclass that'll show the movie's genres + revenue
final class MovieDetailsGenreCell: TVShowDetailsBaseCell {
	static let identifier = "MovieDetailsGenreCell"

	private var genreLabel, revenueLabel: UILabel!

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		[genreLabel, revenueLabel].forEach { $0?.text = nil }
	}

	override func setupUI() {
		genreLabel = createLabel()
		revenueLabel = createLabel(numberOfLines: 1)
		revenueLabel.textAlignment = .right
		contentView.addSubviews(genreLabel, revenueLabel)

		super.setupUI()
	}

	override func layoutUI() {
		genreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
		genreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
		genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
		genreLabel.trailingAnchor.constraint(equalTo: revenueLabel.leadingAnchor, constant: -20).isActive = true

		revenueLabel.topAnchor.constraint(equalTo: genreLabel.topAnchor).isActive = true
		revenueLabel.bottomAnchor.constraint(equalTo: genreLabel.bottomAnchor).isActive = true
		revenueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
	}
}

private extension Formatter {
	static let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 0
		return formatter
	}()
}

// ! Public

extension MovieDetailsGenreCell {
	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: TVShowDetailsGenreCellViewModel) {
		guard let genre = viewModel.genre else {
			genreLabel.text = "Unknown genre"
			return
		}

		genreLabel.text = genre

		guard viewModel.revenue != 0,
			let revenue = Formatter.currencyFormatter.string(for: viewModel.revenue) else { return }

		revenueLabel.text = "Revenue: " + revenue
	}
}
