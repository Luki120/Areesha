import UIKit


protocol TVShowListViewDelegate: AnyObject {
	func tvShowListView(_ tvShowListView: TVShowListView, didSelect tvShow: TVShow)
}

/// Class to represent the tv shows list view
final class TVShowListView: UIView {

	let viewModel = TVShowHostViewViewModel()

	@UsesAutoLayout
	private var hostCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 0
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}()

	weak var delegate: TVShowListViewDelegate?

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

extension TVShowListView: TopHeaderViewDelegate {

	func topHeaderView(_ topHeaderView: TopHeaderView, didSelectItemAt indexPath: IndexPath) {
		scrollTo(itemAt: indexPath)
	}

}

// ! TVShowHostViewViewModelDelegate

extension TVShowListView: TVShowHostViewViewModelDelegate {

	func didSelect(tvShow: TVShow) {
		delegate?.tvShowListView(self, didSelect: tvShow)
	}

}
