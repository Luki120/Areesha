import UIKit

/// Class to represent the tracked tv show list cell
final class TrackedTVShowListCell: UICollectionViewListCell {
	var viewModel: TrackedTVShowCellViewModel?

	override func updateConfiguration(using state: UICellConfigurationState) {
		var newConfiguration = TrackedTVShowContentConfiguration().updated(for: state)
		newConfiguration.name = viewModel?.name
		newConfiguration.rating = viewModel?.rating
		newConfiguration.lastSeen = viewModel?.lastSeen
		newConfiguration.viewModel = viewModel

		contentConfiguration = newConfiguration
	}
}

/// Struct to represent the content configuration for the tracked tv show cell
struct TrackedTVShowContentConfiguration: UIContentConfiguration, Hashable {
	var name: String?
	var rating: Double?
	var lastSeen: String?
	var viewModel: TrackedTVShowCellViewModel?

	func makeContentView() -> UIView & UIContentView {
		return TrackedTVShowContentView(configuration: self)
	}

	func updated(for state: UIConfigurationState) -> TrackedTVShowContentConfiguration {
		return self
	}
}

/// Class to represent the content view for the tracked tv show cell
final class TrackedTVShowContentView: UIView, UIContentView {
	private var currentConfiguration: TrackedTVShowContentConfiguration!

	var configuration: UIContentConfiguration {
		get { currentConfiguration }
		set {
			guard let newConfiguration = newValue as? TrackedTVShowContentConfiguration else { return }
			apply(configuration: newConfiguration)
		}
	}

	private var activeViewModel: TrackedTVShowCellViewModel!

	@UsesAutoLayout
	private var seasonImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 8
		return imageView
	}()

	@UsesAutoLayout
	private var ratingStarImageView: UIImageView = {
		let configuration: UIImage.SymbolConfiguration = .init(pointSize: 12)

		let imageView = UIImageView()
		imageView.image = .init(systemName: "star.fill", withConfiguration: configuration)
		imageView.tintColor = .systemYellow
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()

	private var tvShowNameLabel, detailsLabel: UILabel!

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init(configuration: TrackedTVShowContentConfiguration) {
		super.init(frame: .zero)

		setupUI()
		self.configuration = configuration
	}

	// ! Private

	private func setupUI() {
		tvShowNameLabel = createLabel(withFontWeight: .bold)
		detailsLabel = createLabel(textColor: .secondaryLabel)

		addSubviews(seasonImageView, tvShowNameLabel, detailsLabel)
		layoutUI()
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			seasonImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
			seasonImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
			seasonImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			seasonImageView.widthAnchor.constraint(equalToConstant: 130),
			seasonImageView.heightAnchor.constraint(equalToConstant: 75),

			tvShowNameLabel.topAnchor.constraint(equalTo: seasonImageView.topAnchor, constant: 20),
			tvShowNameLabel.leadingAnchor.constraint(equalTo: seasonImageView.trailingAnchor, constant: 20),
			tvShowNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

			detailsLabel.topAnchor.constraint(equalTo: tvShowNameLabel.bottomAnchor, constant: 2.5),
			detailsLabel.leadingAnchor.constraint(equalTo: tvShowNameLabel.leadingAnchor)
		])
	}

	private func apply(configuration: TrackedTVShowContentConfiguration) {
		guard currentConfiguration != configuration else { return }
		currentConfiguration = configuration

		guard let viewModel = configuration.viewModel else { return }
		configure(with: viewModel)
		configureRating(with: viewModel)

		tvShowNameLabel.text = viewModel.name
		detailsLabel.text = viewModel.listType == .finished ? viewModel.ratingLabel : viewModel.lastSeen
	}

	private func configure(with viewModel: TrackedTVShowCellViewModel) {
		activeViewModel = viewModel

		Task.detached(priority: .background) {
			guard let (image, isFromNetwork) = try? await viewModel.fetchImage() else { return }
			await MainActor.run {
				guard self.activeViewModel == viewModel else { return }

				if isFromNetwork {
					UIView.transition(with: self.seasonImageView, duration: 0.5, options: .transitionCrossDissolve) {
						self.seasonImageView.alpha = 1
						self.seasonImageView.image = image
					}
				}
				else {
					self.seasonImageView.alpha = 1
					self.seasonImageView.image = image
				}
			}
		}
	}

	private func configureRating(with viewModel: TrackedTVShowCellViewModel) {
		guard viewModel.listType == .finished && viewModel.rating != 0 else {
			ratingStarImageView.removeFromSuperview()
			return
		}

		addSubview(ratingStarImageView)
		ratingStarImageView.centerYAnchor.constraint(equalTo: detailsLabel.centerYAnchor).isActive = true
		ratingStarImageView.leadingAnchor.constraint(equalTo: detailsLabel.trailingAnchor, constant: 5).isActive = true
	}

	// ! Reusable

	private func createLabel(
		withFontWeight weight: UIFont.Weight = .regular,
		textColor: UIColor = .label
	) -> UILabel {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: weight)
		label.textColor = textColor
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}
}
