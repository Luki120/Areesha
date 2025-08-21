import UIKit

/// Class to represent the tracked tv show list cell
final class TrackedTVShowListCell: UICollectionViewListCell, Configurable {
	var viewModel: TrackedTVShowCellViewModel?

	override func updateConfiguration(using state: UICellConfigurationState) {
		var newConfiguration = TrackedTVShowContentConfiguration().updated(for: state)
		newConfiguration.name = viewModel?.name
		newConfiguration.rating = viewModel?.rating
		newConfiguration.lastSeen = viewModel?.lastSeen
		newConfiguration.viewModel = viewModel

		contentConfiguration = newConfiguration
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		viewModel = nil
	}

	func configure(with viewModel: TrackedTVShowCellViewModel) {
		self.viewModel = viewModel
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

	@UsesAutoLayout
	private var tvShowImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.alpha = 0
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerCurve = .continuous
		imageView.layer.cornerRadius = 8
		return imageView
	}()

	@UsesAutoLayout
	private var ratingStarsView = RatingStarsView()

	private var imageTask: Task<Void, Error>?
	private var tvShowNameLabel, lastSeenLabel: UILabel!

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
		tvShowNameLabel = createLabel(fontWeight: .bold)
		lastSeenLabel = createLabel(textColor: .secondaryLabel)

		addSubviews(tvShowImageView, tvShowNameLabel, lastSeenLabel)
		layoutUI()
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			tvShowImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
			tvShowImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
			tvShowImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

			tvShowNameLabel.topAnchor.constraint(equalTo: tvShowImageView.topAnchor, constant: 20),
			tvShowNameLabel.leadingAnchor.constraint(equalTo: tvShowImageView.trailingAnchor, constant: 20),
			tvShowNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

			lastSeenLabel.topAnchor.constraint(equalTo: tvShowNameLabel.bottomAnchor, constant: 2.5),
			lastSeenLabel.leadingAnchor.constraint(equalTo: tvShowNameLabel.leadingAnchor)
		])

		setupSizeConstraints(forView: tvShowImageView, width: 130, height: 75)
	}

	private func apply(configuration: TrackedTVShowContentConfiguration) {
		guard currentConfiguration != configuration else { return }
		currentConfiguration = configuration
		tvShowImageView.image = nil

		guard let viewModel = configuration.viewModel else { return }
		configure(with: viewModel)
		configureRating(with: viewModel)

		tvShowNameLabel.text = viewModel.name
		lastSeenLabel.text = viewModel.lastSeen
	}

	private func configure(with viewModel: TrackedTVShowCellViewModel) {
		imageTask?.cancel()
		imageTask = Task {
			let (image, isFromNetwork) = try await viewModel.fetchImage()
			guard !Task.isCancelled else { return }

			await MainActor.run {
				self.tvShowImageView.image = image

				if isFromNetwork {
					UIView.transition(with: self.tvShowImageView, duration: 0.5, options: .transitionCrossDissolve) {
						self.tvShowImageView.alpha = 1
					}
				}
				else {
					self.tvShowImageView.alpha = 1
				}
			}
		}
	}

	private func configureRating(with viewModel: TrackedTVShowCellViewModel) {
		guard viewModel.listType == .finished && viewModel.rating != 0 else {
			ratingStarsView.removeFromSuperview()
			return
		}

		ratingStarsView.updateStars(for: viewModel.rating, size: 12)
		lastSeenLabel.removeFromSuperview()

		addSubview(ratingStarsView)
		ratingStarsView.topAnchor.constraint(equalTo: tvShowNameLabel.bottomAnchor, constant: 8).isActive = true
		ratingStarsView.leadingAnchor.constraint(equalTo: tvShowNameLabel.leadingAnchor).isActive = true
	}

	// ! Reusable

	private func createLabel(
		fontWeight weight: UIFont.Weight = .regular,
		textColor: UIColor = .label
	) -> UILabel {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .callout, weight: weight, size: 14)
		label.textColor = textColor
		label.numberOfLines = 0
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}
}
