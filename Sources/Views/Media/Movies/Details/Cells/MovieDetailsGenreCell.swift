import UIKit

/// `UITableViewCell` subclass that'll show the movie's genres + revenue
final class MovieDetailsGenreCell: MediaDetailsBaseCell {
	static let identifier = "MovieDetailsGenreCell"

	private var viewModel: MediaDetailsGenreCellViewModel!
	private var genreLabel, budgetRevenueLabel: UILabel!

	// ! Lifecycle

	override func prepareForReuse() {
		super.prepareForReuse()
		[genreLabel, budgetRevenueLabel].forEach { $0?.text = nil }
	}

	override func setupUI() {
		genreLabel = createLabel()
		budgetRevenueLabel = createLabel(numberOfLines: 1)
		budgetRevenueLabel.textAlignment = .right
		budgetRevenueLabel.isUserInteractionEnabled = true
		budgetRevenueLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBudgetRevenueLabel)))
		contentView.addSubviews(genreLabel, budgetRevenueLabel)

		super.setupUI()
	}

	override func layoutUI() {
		NSLayoutConstraint.activate([
			genreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			genreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			genreLabel.trailingAnchor.constraint(equalTo: budgetRevenueLabel.leadingAnchor, constant: -20),

			budgetRevenueLabel.topAnchor.constraint(equalTo: genreLabel.topAnchor),
			budgetRevenueLabel.bottomAnchor.constraint(equalTo: genreLabel.bottomAnchor),
			budgetRevenueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
		])

		budgetRevenueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
	}

	// ! Private

	private func fadeTransition() {
		budgetRevenueLabel.text = ""

		let transition = CATransition()
		transition.type = .fade
		transition.duration = 0.5
		transition.timingFunction = .init(name: .easeInEaseOut)
		budgetRevenueLabel.layer.add(transition, forKey: nil)
	}

	private func configureBudgetRevenueLabel() -> String {
		let budget = viewModel.budget ?? 0
		let revenue = viewModel.revenue ?? 0

		var value = 0
		var prefixText = ""

		if viewModel.budgetRevenueType == .budget {
			value = budget
			prefixText = "Budget: "
		}
		else if viewModel.revenue != 0 {
			value = revenue
			prefixText = "Revenue: "
		}
		else {
			value = budget
			prefixText = "Budget: "
			viewModel.budgetRevenueType = .budget
			budgetRevenueLabel.isUserInteractionEnabled = false
		}

		guard let formattedValue = Formatter.currencyFormatter.string(for: value) else {
			budgetRevenueLabel.text = nil
			return ""
		}

		return prefixText + formattedValue
	}

	@objc
	private func didTapBudgetRevenueLabel() {
		viewModel.budgetRevenueType = viewModel.budgetRevenueType == .revenue ? .budget : .revenue	
		configure(with: viewModel)
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
	func configure(with viewModel: MediaDetailsGenreCellViewModel) {
		self.viewModel = viewModel
		genreLabel.text = viewModel.genre == "" ? "Unknown genre" : viewModel.genre

		guard viewModel.budget != 0 || viewModel.revenue != 0 else {
			budgetRevenueLabel.text = nil
			budgetRevenueLabel.isUserInteractionEnabled = false
			return
		}

		fadeTransition()
		budgetRevenueLabel.text = configureBudgetRevenueLabel()
	}
}
