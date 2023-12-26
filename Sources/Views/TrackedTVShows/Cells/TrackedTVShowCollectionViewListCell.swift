import UIKit

/// Class to represent the tracked tv show collection view list cell
final class TrackedTVShowCollectionViewListCell: UICollectionViewListCell {

	var viewModel: TrackedTVShowCollectionViewCellViewModel?

	override func updateConfiguration(using state: UICellConfigurationState) {
		var newConfiguration = TrackedTVShowContentConfiguration().updated(for: state)
		newConfiguration.tvShowNameText = viewModel?.tvShowNameText
		newConfiguration.lastSeenText = viewModel?.lastSeenText
		newConfiguration.viewModel = viewModel

		contentConfiguration = newConfiguration
	}

}

/// Struct to represent the content configuration for the tracked tv show cell
struct TrackedTVShowContentConfiguration: UIContentConfiguration, Hashable {

	var tvShowNameText: String?
	var lastSeenText: String?
	var viewModel: TrackedTVShowCollectionViewCellViewModel?

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

	private var activeViewModel: TrackedTVShowCollectionViewCellViewModel!

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

	private var tvShowNameLabel, lastSeenLabel: UILabel!

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init(configuration: TrackedTVShowContentConfiguration) {
		super.init(frame: .zero)

		setupUI()
		layoutUI()
		self.configuration = configuration
	}

	// ! Private

	private func setupUI() {
		tvShowNameLabel = createLabel(withFontWeight: .bold)
		lastSeenLabel = createLabel(textColor: .secondaryLabel)

		addSubviews(seasonImageView, tvShowNameLabel, lastSeenLabel)
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

			lastSeenLabel.topAnchor.constraint(equalTo: tvShowNameLabel.bottomAnchor, constant: 2.5),
			lastSeenLabel.leadingAnchor.constraint(equalTo: tvShowNameLabel.leadingAnchor)
		])
	}

	private func apply(configuration: TrackedTVShowContentConfiguration) {
		guard currentConfiguration != configuration else { return }
		currentConfiguration = configuration

		guard let viewModel = configuration.viewModel else { return }
		configure(with: viewModel)

		tvShowNameLabel.text = configuration.tvShowNameText
		lastSeenLabel.text = configuration.lastSeenText
	}

	private func configure(with viewModel: TrackedTVShowCollectionViewCellViewModel) {
		activeViewModel = viewModel

		Task.detached(priority: .background) {
			let image = try? await viewModel.fetchImage()
			await MainActor.run {
				guard self.activeViewModel == viewModel else { return }

				UIView.transition(with: self.seasonImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.seasonImageView.alpha = 1
					self.seasonImageView.image = image
				}
			}
		}
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
