import UIKit

@MainActor
protocol RatingViewDelegate: AnyObject {
	func didAddRating(in ratingView: RatingView)
}

/// Class to represent the rating view
final class RatingView: UIView {
	private let viewModel: RatingViewViewModel

	private lazy var posterImageView = createImageView()
	private lazy var backgroundImageView = createImageView()

	private lazy var ratingCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
		collectionView.delegate = viewModel
		collectionView.backgroundColor = .clear
		collectionView.isScrollEnabled = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		return collectionView
	}()

	@UsesAutoLayout
	private var mainScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		return scrollView
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

	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.title)

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
		viewModel.bind(to: ratingCollectionView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		ratingCollectionView.collectionViewLayout.invalidateLayout()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		ratingButton.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		insertSubview(backgroundImageView, at: 0)
		backgroundImageView.addSubview(visualEffectView)
		addSubview(mainScrollView)
		mainScrollView.addSubviews(posterImageView, rateLabel, ratingStackView, ratingButton)
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
		pinViewToSafeAreas(mainScrollView)
		backgroundImageView.pinViewToAllEdges(visualEffectView)

		let contentGuide = mainScrollView.contentLayoutGuide
		let frameGuide = mainScrollView.frameLayoutGuide

		NSLayoutConstraint.activate([
			posterImageView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 30),
			posterImageView.centerXAnchor.constraint(equalTo: frameGuide.centerXAnchor),

			rateLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 35),
			rateLabel.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor),
			rateLabel.trailingAnchor.constraint(equalTo: frameGuide.trailingAnchor),

			ratingCollectionView.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 35),
			ratingCollectionView.leadingAnchor.constraint(equalTo: frameGuide.leadingAnchor),
			ratingCollectionView.trailingAnchor.constraint(equalTo: frameGuide.trailingAnchor),
			ratingCollectionView.heightAnchor.constraint(equalToConstant: 28),

			ratingStackView.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 35),
			ratingStackView.centerXAnchor.constraint(equalTo: frameGuide.centerXAnchor),

			ratingButton.topAnchor.constraint(equalTo: ratingCollectionView.bottomAnchor, constant: 35),
			ratingButton.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -20),
			ratingButton.centerXAnchor.constraint(equalTo: frameGuide.centerXAnchor)
		])

		setupSizeConstraints(forView: posterImageView, width: 230, height: 350)
		setupSizeConstraints(forView: ratingSlider, width: 200, height: 28)
		setupSizeConstraints(forView: ratingButton, width: 120, height: 50)
	}

	private func fetchImage() {
		Task {
			let images = await viewModel.fetchImages()

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

	private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
		return UICollectionViewCompositionalLayout { _, layoutEnvironment in
			let itemWidth: CGFloat = 28
			let spacing: CGFloat = 10
			let numberOfItems = 5

			let totalItemsWidth = CGFloat(numberOfItems) * itemWidth
			let totalSpacingWidth = CGFloat(numberOfItems - 1) * spacing
			let totalContentWidth = totalItemsWidth + totalSpacingWidth

			let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .fractionalHeight(1))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(totalContentWidth), heightDimension: .fractionalHeight(1))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfItems)
			group.interItemSpacing = .fixed(spacing)

			let containerWidth = layoutEnvironment.container.effectiveContentSize.width
			let horizontalInset = max(0, (containerWidth - totalContentWidth) / 2)

			let section = NSCollectionLayoutSection(group: group)
			section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
			return section
		}
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
