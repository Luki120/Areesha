import UIKit

protocol RatingViewDelegate: AnyObject {
	func didAddRating(in ratingView: RatingView)
}

/// Class to represent the rating view
final class RatingView: UIView {
	private let viewModel: RatingViewViewModel

	private lazy var posterImageView = createImageView()
	private lazy var backgroundImageView = createImageView()

	private let compositionalLayout: UICollectionViewCompositionalLayout = {
		let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
			let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(28), heightDimension: .fractionalHeight(1))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let containerWidth = layoutEnvironment.container.effectiveContentSize.width
			let itemWidth: CGFloat = 28
			let spacing: CGFloat = 10

			let numberOfItems = 5

			let totalItemsWidth = CGFloat(numberOfItems) * itemWidth
			let totalSpacingWidth = CGFloat(max(0, numberOfItems - 1)) * spacing
			let totalContentWidth = totalItemsWidth + totalSpacingWidth

			let horizontalInset = max(0, (containerWidth - totalContentWidth) / 2)

			let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(totalContentWidth), heightDimension: .fractionalHeight(1))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			group.interItemSpacing = .fixed(spacing)

			let section = NSCollectionLayoutSection(group: group)
			section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
			return section
		}
		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.scrollDirection = .horizontal

		layout.configuration = config
		return layout
	}()

	private lazy var ratingCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.delegate = viewModel
		collectionView.backgroundColor = .clear
		collectionView.isScrollEnabled = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		return collectionView
	}()

	@UsesAutoLayout
	private var ratingStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.alpha = 0
		stackView.spacing = 10
		return stackView
	}()

	@UsesAutoLayout
	private var ratingSlider: UISlider = {
		let slider = UISlider()
		slider.isContinuous = false
		slider.minimumValue = 1
		slider.maximumValue = 10
		return slider
	}()

	private lazy var sliderValueLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .caption1)
		label.text = String(describing: ratingSlider.value)
		label.textColor = .systemGray
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	@UsesAutoLayout
	private var visualEffectView: UIVisualEffectView = {
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
		visualEffectView.clipsToBounds = true
		return visualEffectView
	}()

	@UsesAutoLayout
	private var rateLabel: UILabel = {
		let label = UILabel()
		label.font = .preferredFont(forTextStyle: .title2, weight: .bold)
		label.textAlignment = .center
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private lazy var ratingButton = createRoundedButton(title: "Rate") { [weak self] in
		guard let self else { return }
		viewModel.addRating(isDecimal: rightBarButtonIsTapped) {
			self.delegate?.didAddRating(in: self)
		}
	}

	private var rightBarButtonIsTapped = false
	weak var delegate: RatingViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this view
	init(viewModel: RatingViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		setupUI()

		viewModel.setupDiffableDataSource(for: ratingCollectionView)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		ratingButton.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		insertSubview(backgroundImageView, at: 0)
		backgroundImageView.addSubview(visualEffectView)
		addSubviews(posterImageView, rateLabel, ratingStackView, ratingButton)
		ratingStackView.addArrangedSubviews(ratingSlider, sliderValueLabel)

		let media = viewModel.object.type == .movie ? "movie" : "show"
		rateLabel.text = "How would you rate this \(media)?"

		setupSlider()
		fetchImage()
		layoutUI()
	}

	private func setupSlider() {
		ratingSlider.addAction(
			UIAction { [weak self] action in
				guard let self else { return }
				guard let slider = action.sender as? UISlider else { return }

				let roundedValue = round(Double(slider.value) / 0.5) * 0.5
				slider.value = Float(roundedValue)
				viewModel.setRating(roundedValue)

				sliderValueLabel.text = String(describing: roundedValue)
			},
			for: .valueChanged
		)		
	}

	private func layoutUI() {
		pinViewToAllEdges(backgroundImageView)
		backgroundImageView.pinViewToAllEdges(visualEffectView)

		NSLayoutConstraint.activate([
			posterImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
			posterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),

			rateLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 35),
			rateLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			rateLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

			ratingCollectionView.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 35),
			ratingCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			ratingCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
			ratingCollectionView.heightAnchor.constraint(equalToConstant: 28),

			ratingStackView.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 35),
			ratingStackView.centerXAnchor.constraint(equalTo: rateLabel.centerXAnchor),

			ratingButton.topAnchor.constraint(equalTo: ratingCollectionView.bottomAnchor, constant: 35),
			ratingButton.centerXAnchor.constraint(equalTo: centerXAnchor)
		])

		setupSizeConstraints(forView: posterImageView, width: 230, height: 350)
		setupSizeConstraints(forView: ratingSlider, width: 200, height: 28)
		setupSizeConstraints(forView: ratingButton, width: 120, height: 50)
	}

	private func fetchImage() {
		viewModel.fetchImages { [weak self] images in
			guard let self else { return }

			await MainActor.run {
				self.backgroundImageView.image = images.first!

				UIView.transition(with: self.posterImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.posterImageView.image = images[1]
				}
			}
		}
	}

	// ! Reusable

	private func createImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}
}

// ! Public

extension RatingView {
	/// Function to fade in & out the rating stack view
	func fadeInOutSlider() {
		rightBarButtonIsTapped.toggle()

		UIView.animate(withDuration: 0.35, delay: 0, options: .transitionCrossDissolve) {
			self.ratingStackView.alpha = self.rightBarButtonIsTapped ? 1 : 0
			self.ratingCollectionView.alpha = self.rightBarButtonIsTapped ? 0 : 1
		}
	}
}
