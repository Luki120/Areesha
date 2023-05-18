import UIKit

/// Class to represent the tv show seasons view
final class TVShowSeasonsView: UIView {

	private let viewModel: TVShowSeasonsViewViewModel

	private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 50)

		let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300), heightDimension: .absolute(330))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: bounds.size.height / 2 - 182, leading: 70, bottom: 0, trailing: 20)
		section.visibleItemsInvalidationHandler = { items, offset, environment in
			items.forEach { item in
				let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2)
				let minScale: CGFloat = 0.9
				let maxScale: CGFloat = 1.2
				let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
				item.transform = .init(scaleX: scale, y: scale)
			}
		}

		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.scrollDirection = .horizontal

		return UICollectionViewCompositionalLayout(section: section, configuration: config)
	}()

	private lazy var seasonsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.delegate = viewModel
		collectionView.dataSource = viewModel
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.register(TVShowSeasonsCollectionViewCell.self, forCellWithReuseIdentifier: TVShowSeasonsCollectionViewCell.identifier)
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

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: the view model object for this view
	init(viewModel: TVShowSeasonsViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		viewModel.delegate = self
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToAllEdges(seasonsCollectionView)
	}

}

// ! TVShowSeasonsViewViewModelDelegate

extension TVShowSeasonsView: TVShowSeasonsViewViewModelDelegate {

	func didLoadTVShowSeasons() {
		seasonsCollectionView.reloadData()
	}

}
