import UIKit


protocol TVShowRatingViewDelegate: AnyObject {
	func didAddRating(in tvShowRatingView: TVShowRatingView)
}

/// Class to represent the TV show rating view
final class TVShowRatingView: UIView {
	private let viewModel: TVShowRatingViewViewModel

	private lazy var tvShowPosterImageView = createImageView()
	private lazy var tvShowImageView = createImageView()

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
	private var visualEffectView: UIVisualEffectView = {
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
		visualEffectView.clipsToBounds = true
		return visualEffectView
	}()

	@UsesAutoLayout
	private var rateShowLabel: UILabel = {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 22)
		label.text = "How would you rate this show?"
		return label
	}()

	private lazy var ratingButton = createRoundedButton(title: "Rate") { [weak self] in
		guard let self else { return }
		viewModel.addRating {
			self.delegate?.didAddRating(in: self)
		}		
	}

	weak var delegate: TVShowRatingViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this view
	init(viewModel: TVShowRatingViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		setupUI()

		viewModel.setupCollectionViewDiffableDataSource(for: ratingCollectionView)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		ratingButton.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		insertSubview(tvShowImageView, at: 0)
		tvShowImageView.addSubview(visualEffectView)
		addSubviews(tvShowPosterImageView, rateShowLabel, ratingButton)

		fetchTVShowImage()
		layoutUI()
	}

	private func layoutUI() {
		pinViewToAllEdges(tvShowImageView)
		tvShowImageView.pinViewToAllEdges(visualEffectView)

		NSLayoutConstraint.activate([
			tvShowPosterImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
			tvShowPosterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),

			rateShowLabel.topAnchor.constraint(equalTo: tvShowPosterImageView.bottomAnchor, constant: 35),
			rateShowLabel.centerXAnchor.constraint(equalTo: tvShowPosterImageView.centerXAnchor),

			ratingCollectionView.topAnchor.constraint(equalTo: rateShowLabel.bottomAnchor, constant: 35),
			ratingCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			ratingCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
			ratingCollectionView.heightAnchor.constraint(equalToConstant: 28),

			ratingButton.topAnchor.constraint(equalTo: ratingCollectionView.bottomAnchor, constant: 35),
			ratingButton.centerXAnchor.constraint(equalTo: centerXAnchor)
		])

		setupSizeConstraints(forView: tvShowPosterImageView, width: 230, height: 350)
		setupSizeConstraints(forView: ratingButton, width: 120, height: 50)
	}

	private func fetchTVShowImage() {
		viewModel.fetchTVShowImages { [weak self] images in
			guard let self else { return }

			await MainActor.run {
				self.tvShowImageView.image = images.first!

				UIView.transition(with: self.tvShowPosterImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowPosterImageView.image = images[1]
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
