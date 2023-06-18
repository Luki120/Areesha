import UIKit

protocol SeasonsViewDelegate: AnyObject {
	func seasonsView(_ seasonsView: SeasonsView, didSelect season: Season, from tvShow: TVShow)
}

/// Class to represent the tv show seasons view
final class SeasonsView: UIView {

	private let viewModel: SeasonsViewViewModel

	private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
			guard let self else { return nil }

			let effectiveContainerSize = layoutEnvironment.container.effectiveContentSize

			let widthFraction: CGFloat = 3 / 5 // ratio of cell width to collection view width
			let heightFraction: CGFloat = 1 / 2 // ratio of cell height to collection view height
			
			let layoutContainerEffectiveHeight = effectiveContainerSize.height
			let itemHeight = layoutContainerEffectiveHeight * heightFraction
			let verticalSpacing: CGFloat = (layoutEnvironment.container.contentSize.height - itemHeight) / 2

			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let interSpacing: CGFloat = 24
			let normalItemWidth: CGFloat = 252
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(widthFraction), heightDimension: .fractionalHeight(heightFraction))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
			group.edgeSpacing = .init(leading: .fixed(interSpacing), top: .fixed(verticalSpacing), trailing: .fixed(interSpacing), bottom: nil)

			let layoutContainerEffectiveWidth = effectiveContainerSize.width
			let itemWidth = layoutContainerEffectiveWidth * widthFraction
			let horizontalSpacing = (layoutEnvironment.container.contentSize.width - itemWidth) / 2 - interSpacing

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
		collectionView.register(SeasonsCollectionViewCell.self, forCellWithReuseIdentifier: SeasonsCollectionViewCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		return collectionView
	}()

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.text = viewModel.title
		label.numberOfLines = 0
		return label
	}()

	weak var delegate: SeasonsViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: the view model object for this view
	init(viewModel: SeasonsViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		viewModel.delegate = self
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToAllEdges(seasonsCollectionView)
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

}
