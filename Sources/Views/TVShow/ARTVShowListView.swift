import UIKit


protocol ARTVShowListViewDelegate: AnyObject {
	func arTVShowListView(_ arTVShowListView: ARTVShowListView, didSelect tvShow: TVShow)
}

/// Class to represent the tv shows list view
final class ARTVShowListView: UIView {

	private lazy var viewModel = ARTVShowListViewViewModel(collectionView: tvShowsCollectionView)

	private let compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
		return UICollectionViewCompositionalLayout(section: section)
	}()

	@UsesAutoLayout
	private var tvShowsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsVerticalScrollIndicator = false
		return collectionView
	}()

	var collectionView: UICollectionView { return tvShowsCollectionView }

	weak var delegate: ARTVShowListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(tvShowsCollectionView)
		tvShowsCollectionView.delegate = viewModel
		tvShowsCollectionView.setCollectionViewLayout(compositionalLayout, animated: true)
		viewModel.delegate = self
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToAllEdges(tvShowsCollectionView)
	}

}

// ! ARTVShowListViewViewModelDelegate

extension ARTVShowListView: ARTVShowListViewViewModelDelegate {

	func didSelect(tvShow: TVShow) {
		delegate?.arTVShowListView(self, didSelect: tvShow)
	}

}
