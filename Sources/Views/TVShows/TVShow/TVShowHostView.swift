import UIKit


protocol TVShowHostViewDelegate: AnyObject {
	func tvShowHostView(_ tvShowHostView: TVShowHostView, didSelect tvShow: TVShow)
}

/// Class to represent the tv shows host view
final class TVShowHostView: UIView {

	let viewModel = TVShowHostViewViewModel()

	private let compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)

		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.scrollDirection = .horizontal

		return UICollectionViewCompositionalLayout(section: section, configuration: config)
	}()

	@UsesAutoLayout
	private var hostCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}()

	weak var delegate: TVShowHostViewDelegate?

	@UsesAutoLayout
	private var topHeaderView = TopHeaderView()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubviews(topHeaderView, hostCollectionView)
		setupCollectionView()

		viewModel.delegate = self
		viewModel.topHeaderView = topHeaderView
		topHeaderView.delegate = self
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupCollectionView() {
		hostCollectionView.dataSource = viewModel
		hostCollectionView.delegate = viewModel
		hostCollectionView.isPagingEnabled = true
		hostCollectionView.setCollectionViewLayout(compositionalLayout, animated: true)
		hostCollectionView.register(TopRatedTVShowsCollectionViewCell.self, forCellWithReuseIdentifier: TopRatedTVShowsCollectionViewCell.identifier)
		hostCollectionView.register(TrendingTVShowsCollectionViewCell.self, forCellWithReuseIdentifier: TrendingTVShowsCollectionViewCell.identifier)
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			topHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
			topHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
			topHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
			topHeaderView.heightAnchor.constraint(equalToConstant: 50),

			hostCollectionView.topAnchor.constraint(equalTo: topHeaderView.bottomAnchor),
			hostCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
			hostCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			hostCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	private func scrollTo(itemAt indexPath: IndexPath) {
		let indexPath = IndexPath(item: indexPath.item, section: 0)
		hostCollectionView.scrollToItem(at: indexPath, at: [], animated: true)
	}

}

// ! TopHeaderViewDelegate

extension TVShowHostView: TopHeaderViewDelegate {

	func topHeaderView(_ topHeaderView: TopHeaderView, didSelectItemAt indexPath: IndexPath) {
		scrollTo(itemAt: indexPath)
	}

}

// ! TVShowHostViewViewModelDelegate

extension TVShowHostView: TVShowHostViewViewModelDelegate {

	func didSelect(tvShow: TVShow) {
		delegate?.tvShowHostView(self, didSelect: tvShow)
	}

}