import UIKit

/// Class to represent the developer table view cell
final class DeveloperTableViewCell: UITableViewCell {

	static let identifier = "DeveloperTableViewCell"

	private var lukiContentView, leptosContentView: UIView!
	private var lukiImageView, leptosImageView: UIImageView!
	private var lukiNameLabel, leptosNameLabel: UILabel!

	@UsesAutoLayout
	private var separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .init(white: 0.5, alpha: 0.5)
		return view
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	// ! Private

	private func setupUI() {
		contentView.backgroundColor = .secondarySystemGroupedBackground

		lukiContentView = UIView()
		lukiContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLuki)))

		leptosContentView = UIView()
		leptosContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLeptos)))

		[lukiContentView, leptosContentView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

		lukiImageView = createDeveloperImageView()
		leptosImageView = createDeveloperImageView()

		lukiNameLabel = createDeveloperNameLabel()
		leptosNameLabel = createDeveloperNameLabel()

		contentView.addSubviews(lukiContentView, separatorView, leptosContentView)
		lukiContentView.addSubviews(lukiImageView, lukiNameLabel)
		leptosContentView.addSubviews(leptosImageView, leptosNameLabel)

		layoutUI()
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			lukiContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			lukiContentView.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor),
			leptosContentView.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor),
			leptosContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			lukiImageView.centerYAnchor.constraint(equalTo: lukiContentView.centerYAnchor),
			lukiImageView.leadingAnchor.constraint(equalTo: lukiContentView.leadingAnchor, constant: 15),

			lukiNameLabel.centerYAnchor.constraint(equalTo: lukiImageView.centerYAnchor),
			lukiNameLabel.leadingAnchor.constraint(equalTo: lukiImageView.trailingAnchor, constant: 10),

			separatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			separatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			separatorView.widthAnchor.constraint(equalToConstant: 0.5),
			separatorView.heightAnchor.constraint(equalToConstant: 40),

			leptosImageView.centerYAnchor.constraint(equalTo: leptosContentView.centerYAnchor),
			leptosImageView.leadingAnchor.constraint(equalTo: leptosContentView.leadingAnchor, constant: 15),

			leptosNameLabel.centerYAnchor.constraint(equalTo: leptosImageView.centerYAnchor),
			leptosNameLabel.leadingAnchor.constraint(equalTo: leptosImageView.trailingAnchor, constant: 10)
		])

		[lukiContentView, leptosContentView].forEach {
			$0.heightAnchor.constraint(equalToConstant: 58).isActive = true
		}

		[lukiImageView, leptosImageView].forEach {
			$0.widthAnchor.constraint(equalToConstant: 40).isActive = true
			$0.heightAnchor.constraint(equalToConstant: 40).isActive = true
		}
	}

	@objc
	private func didTapLuki() {
		guard let url = Developer.lukiGitHubURL else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	@objc
	private func didTapLeptos() {
		guard let url = Developer.leptosGitHubURL else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	// ! Reusable

	private func createDeveloperImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 20
		return imageView
	}

	private func createDeveloperNameLabel() -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.textColor = .label
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}

}

extension DeveloperTableViewCell {

	// ! Public

	/// Function to configure the cell with its respective view model
	/// - Parameters:
	///		- with: The cell's view model
	func configure(with viewModel: DeveloperTableViewCellViewModel) {
		lukiNameLabel.text = viewModel.lukiNameText
		leptosNameLabel.text = viewModel.leptosNameText

		viewModel.fetchImages() { [weak self] images in
			guard let self else { return }

			await MainActor.run {
				UIView.transition(with: self.lukiImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.lukiImageView.alpha = 1
					self.lukiImageView.image = images.first
				}

				UIView.transition(with: self.leptosImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.leptosImageView.alpha = 1
					self.leptosImageView.image = images[1]
				}
			}
		}
	}

}
