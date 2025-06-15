import UIKit

/// Class to represent the tv show details providers cell
final class TVShowDetailsProvidersCell: TVShowDetailsBaseCell {
	static let identifier = "TVShowDetailsProvidersCell"

	@UsesAutoLayout
	private var whereToWatchLabel: UILabel = {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 16)
		label.text = "Watch on"
		label.textColor = .label
		label.numberOfLines = 0
		return label
	}()

	@UsesAutoLayout
	private var watchProvidersStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.spacing = 10
		stackView.alignment = .center
		return stackView
	}()

	@UsesAutoLayout
	private var separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemGray
		return view
	}()

	private var justWatchImageView: UIImageView!

	// ! Lifecycle

	override func setupUI() {
		justWatchImageView = createImageView(roundingCorners: false)
		justWatchImageView.image = UIImage(asset: .justWatch)
		contentView.addSubviews(whereToWatchLabel, watchProvidersStackView, separatorView, justWatchImageView)

		super.setupUI()
	}

	override func layoutUI() {
		NSLayoutConstraint.activate([
			whereToWatchLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
			whereToWatchLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

			watchProvidersStackView.topAnchor.constraint(equalTo: whereToWatchLabel.bottomAnchor, constant: 10),
			watchProvidersStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
			watchProvidersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

			separatorView.topAnchor.constraint(equalTo: watchProvidersStackView.topAnchor),
			separatorView.leadingAnchor.constraint(equalTo: watchProvidersStackView.trailingAnchor, constant: 10),

			justWatchImageView.topAnchor.constraint(equalTo: separatorView.topAnchor),
			justWatchImageView.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: 10),
		])

		setupSizeConstraints(forView: separatorView, width: 1, height: 40)
		setupSizeConstraints(forView: justWatchImageView, width: 80, height: 40)	
	}

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
		emptyResultsLabel.font = .preferredFont(forTextStyle: .body)
		emptyResultsLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(emptyResultsLabel)

		emptyResultsLabel.topAnchor.constraint(equalTo: whereToWatchLabel.bottomAnchor, constant: 10).isActive = true
		emptyResultsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
		emptyResultsLabel.leadingAnchor.constraint(equalTo: whereToWatchLabel.leadingAnchor).isActive = true
	}
}

extension TVShowDetailsProvidersCell {
	// ! Public

	/// Function to configure the cell with its respective watch provider state
	/// - Parameter with: The cell's state
	func configure(with state: TVShowDetailsViewViewModel.WatchProvidersState) {		
		switch state {
			case .empty: createEmptyResultsLabel()

			case .available(let viewModels):
				watchProvidersStackView.subviews.forEach { $0.removeFromSuperview() }

				viewModels.forEach { viewModel in
					let watchProviderImageView = createImageView()

					setupSizeConstraints(forView: watchProviderImageView, width: 40, height: 40)			
					watchProvidersStackView.addArrangedSubview(watchProviderImageView)

					Task.detached(priority: .background) {
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
