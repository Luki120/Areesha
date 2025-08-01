import UIKit

/// Class to represent the settings footer view
final class SettingsFooterView: UIView {
	private lazy var footerLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .caption1)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.isUserInteractionEnabled = true
		label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:))))
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	@UsesAutoLayout
	private var tmdbImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		return imageView
	}()

	private var viewModel: SettingsFooterViewViewModel!

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubviews(tmdbImageView, footerLabel)

		NSLayoutConstraint.activate([
			tmdbImageView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
			tmdbImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			tmdbImageView.widthAnchor.constraint(equalToConstant: 120),
			tmdbImageView.heightAnchor.constraint(equalToConstant: 50),

			footerLabel.topAnchor.constraint(equalTo: tmdbImageView.bottomAnchor, constant: 15),
			footerLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}

	// ! Private

	@objc
	private func didTapLabel(_ recognizer: UITapGestureRecognizer) {
		guard let text = footerLabel.attributedText?.string,
			let range = text.range(of: viewModel.subString) else { return }

		if recognizer.didTapAttributedText(inLabel: footerLabel, inRange: NSRange(range, in: text)) {
			guard let url = URL(string: viewModel.urlString) else { return }
			UIApplication.shared.open(url)
		}
	}
}

extension SettingsFooterView {
	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameter with: The cell's view model
	func configure(with viewModel: SettingsFooterViewViewModel) {
		self.viewModel = viewModel

		tmdbImageView.image = viewModel.image

		footerLabel.adjustsFontForContentSizeCategory = true
		footerLabel.attributedText = NSMutableAttributedString(
			fullString: viewModel.fullString,
			fullStringColor: .systemGray,
			subString: viewModel.subString,
			subStringColor: .link
		)
	}
}
