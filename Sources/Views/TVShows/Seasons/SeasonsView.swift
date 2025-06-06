import UIKit

protocol SeasonsViewDelegate: AnyObject {
	func seasonsView(_ seasonsView: SeasonsView, didSelect season: Season, from tvShow: TVShow)
}

/// Class to represent the tv show seasons view
final class SeasonsView: UIView {
	private let viewModel: SeasonsViewViewModel

	private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
			guard let self else { return nil }

			let containerSize = layoutEnvironment.container.contentSize
			let effectiveContainerSize = layoutEnvironment.container.effectiveContentSize
			let effectiveContainerHeight = effectiveContainerSize.height

			// the space on each side of a cell;
			// the total space between two cells would be twice this value
			let interSpacing: CGFloat = 24
			let cellAspectRatio: CGFloat = 3/2 // the poster images have an aspect ratio of about 3:2
			let neighborVisibleRatio: CGFloat = 0.15 // how much of the neighboring cells we should see
			// the horizontal layout should look (at the minimum) as follows:
			//   1. `cellWidth * neighborVisibleRatio` of the leading cell
			//   2. `interSpacing * 2` padding
			//   3. `cellWidth` of the center cell
			//   4. `interSpacing * 2` padding
			//   5. `cellWidth * neighborVisibleRatio` of the trailing cell
			// to satisfy this, we describe the following constraint:
			//   ((cellWidth * neighborVisibleRatio) * 2 + (interSpacing * 2) * 2 + cellWidth) <= effectiveContainerSize.width
			// to solve for `cellWidth`:
			//   cellWidth <= (effectiveContainerSize.width - interSpacing * 4) / (neighborVisibleRatio * 2 + 1)

			let maxCellWidth: CGFloat = (effectiveContainerSize.width - interSpacing * 4) / (neighborVisibleRatio * 2 + 1)
			let maxCellRatio: CGFloat = maxCellWidth / effectiveContainerHeight
			let widthFraction: CGFloat = min(0.4, maxCellRatio) // ratio of cell width to collection view height
			let heightFraction: CGFloat = widthFraction * cellAspectRatio // ratio of cell height to collection view height

			let derivedCellSize = CGSize(
				width: effectiveContainerHeight * widthFraction,
				height: effectiveContainerHeight * heightFraction
			)

			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			// the spacing needed above the group such that it appears vertically centered
			let verticalSpacing: CGFloat = (containerSize.height - derivedCellSize.height) / 2
			// the spacing needed on each of the horizontal edges so that edge cells are horizontally centered in the group
			let horizontalSpacing = (containerSize.width - derivedCellSize.width) / 2 - interSpacing

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(widthFraction), heightDimension: .fractionalHeight(heightFraction))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			group.edgeSpacing = .init(leading: .fixed(interSpacing), top: .fixed(verticalSpacing), trailing: .fixed(interSpacing), bottom: nil)

			let section = NSCollectionLayoutSection(group: group)
			section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalSpacing, bottom: 0, trailing: horizontalSpacing)
			section.visibleItemsInvalidationHandler = { items, offset, environment in
				items.forEach { item in
					let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2)
					let minScale: CGFloat = 0.9
					let maxScale: CGFloat = 1.2
					let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
					item.transform = .init(scaleX: scale, y: scale)
				}
			}
			return section
		}
		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.scrollDirection = .horizontal

		layout.configuration = config
		return layout
	}()

	private lazy var seasonsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.delegate = viewModel
		collectionView.dataSource = viewModel
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.register(SeasonCell.self, forCellWithReuseIdentifier: SeasonCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		return collectionView
	}()

	private let noSeasonsLabel: UILabel = .createContentUnavailableLabel(withMessage: "No seasons for this show yet.")
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.title)

	weak var delegate: SeasonsViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this view
	init(viewModel: SeasonsViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		viewModel.delegate = self

		setupUI()
	}

	// ! Private

	private func setupUI() {
		pinViewToAllEdges(seasonsCollectionView)
		addSubview(noSeasonsLabel)

		centerViewOnBothAxes(noSeasonsLabel)
		setupHorizontalConstraints(forView: noSeasonsLabel, leadingConstant: 10, trailingConstant: -10)
	}
}

// ! Public

extension SeasonsView {
	/// Function to fix the swipe pop gesture recognizer
	/// - Parameters:
	///		- for: The navigation controller object
	func fixSwipePopGesture(for controller: UINavigationController) {
		guard let popGestureRecognizer = controller.interactivePopGestureRecognizer else { return }
		seasonsCollectionView.panGestureRecognizer.require(toFail: popGestureRecognizer)
	}
}

// ! SeasonsViewViewModelDelegate

extension SeasonsView: SeasonsViewViewModelDelegate {
	func didLoadTVShowSeasons() {
		seasonsCollectionView.reloadData()
	}

	func didSelect(season: Season, from tvShow: TVShow) {
		delegate?.seasonsView(self, didSelect: season, from: tvShow)
	}

	func shouldAnimateNoSeasonsLabel(isDataSourceEmpty: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {	
			if isDataSourceEmpty {
				self.noSeasonsLabel.alpha = 1
				self.seasonsCollectionView.alpha = 0
			}
			else {
				self.noSeasonsLabel.alpha = 0
				self.seasonsCollectionView.alpha = 1
			}
		}
	}
}
