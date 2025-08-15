import UIKit

/// Class to represent the tv show details providers cell
class MediaDetailsProvidersCell: MediaDetailsBaseCell {
	class var identifier: String {
		return String(describing: self)
	}

	@UsesAutoLayout
	private var whereToWatchLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .callout, weight: .bold)
		label.text = "Watch on"
		label.textColor = .label
		label.numberOfLines = 0
		return label
	}()

	@UsesAutoLayout
	private var watchProvidersScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()

	@UsesAutoLayout
	private var watchProvidersStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.spacing = 10
		stackView.alignment = .center
		return stackView
	}()

	private var justWatchImageView: UIImageView!

	// ! Lifecycle

	override func setupUI() {
		justWatchImageView = createImageView(roundingCorners: false)
		justWatchImageView.image = UIImage(asset: .justWatch)

		contentView.addSubviews(whereToWatchLabel, watchProvidersScrollView)
		watchProvidersScrollView.addSubviews(watchProvidersStackView, separatorView, justWatchImageView)

		super.setupUI()
	}

	override func layoutUI() {
		NSLayoutConstraint.activate([
			whereToWatchLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			whereToWatchLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

			watchProvidersScrollView.topAnchor.constraint(equalTo: whereToWatchLabel.bottomAnchor, constant: 10),
			watchProvidersScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			watchProvidersScrollView.leadingAnchor.constraint(equalTo: whereToWatchLabel.leadingAnchor),
			watchProvidersScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

			watchProvidersStackView.topAnchor.constraint(equalTo: watchProvidersScrollView.topAnchor),
			watchProvidersStackView.leadingAnchor.constraint(equalTo: watchProvidersScrollView.leadingAnchor),
			watchProvidersStackView.heightAnchor.constraint(equalTo: watchProvidersScrollView.heightAnchor),

			separatorView.topAnchor.constraint(equalTo: watchProvidersStackView.topAnchor),
			separatorView.leadingAnchor.constraint(equalTo: watchProvidersStackView.trailingAnchor, constant: 10),

			justWatchImageView.topAnchor.constraint(equalTo: separatorView.topAnchor),
			justWatchImageView.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: 10),
			justWatchImageView.trailingAnchor.constraint(equalTo: watchProvidersScrollView.trailingAnchor)
		])

		setupSizeConstraints(forView: separatorView, width: 1, height: 40)
		setupSizeConstraints(forView: justWatchImageView, width: 80, height: 40)
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		watchProvidersStackView.subviews.forEach {
			guard let imageView = $0 as? UIImageView else { return }
			imageView.image = nil
		}
	}

	// ! Private

	private func createImageView(roundingCorners: Bool = true) -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false

		if roundingCorners {
			imageView.layer.cornerCurve = .continuous
			imageView.layer.cornerRadius = 8	
		}

		return imageView
	}

	private func createEmptyResultsLabel() {
		[watchProvidersStackView, separatorView, justWatchImageView].forEach {
			$0?.removeFromSuperview() 
		}

		let emptyResultsLabel = UILabel()
		emptyResultsLabel.text = "No information available"
		emptyResultsLabel.font = .preferredFont(forTextStyle: .callout)
		emptyResultsLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(emptyResultsLabel)

		emptyResultsLabel.topAnchor.constraint(equalTo: whereToWatchLabel.bottomAnchor, constant: 10).isActive = true
		emptyResultsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
		emptyResultsLabel.leadingAnchor.constraint(equalTo: whereToWatchLabel.leadingAnchor).isActive = true
	}
}

// ! Public

extension MediaDetailsProvidersCell {
	/// Function to configure the cell with its respective watch provider state
	/// - Parameter with: The cell's state
	final func configure(with state: WatchProvidersState) {		
		switch state {
			case .empty: createEmptyResultsLabel()
			case .available(let viewModels):
				watchProvidersStackView.subviews.forEach { $0.removeFromSuperview() }

				viewModels.forEach { viewModel in
					let watchProviderImageView = createImageView()

					setupSizeConstraints(forView: watchProviderImageView, width: 40, height: 40)
					watchProvidersStackView.addArrangedSubview(watchProviderImageView)

					Task {
						let image = try await viewModel.fetchImage()

						await MainActor.run {
							UIView.transition(with: watchProviderImageView, duration: 0.35, options: .transitionCrossDissolve) {
								watchProviderImageView.image = image
							}
						}
					}
				}
		}
	}
}
