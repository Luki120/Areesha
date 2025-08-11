import UIKit


protocol TopRatedTVShowsCellDelegate: AnyObject {
	func topRatedTVShowsCell(_ topRatedTVShowsCell: TopRatedTVShowsCell, didSelect tvShow: TVShow)
}

/// Class to represent the top rated tv shows collection view cell
class TopRatedTVShowsCell: UICollectionViewCell {
	static var identifier: String { return String(describing: self) }

	private let compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1 / 2))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
		return UICollectionViewCompositionalLayout(section: section)
	}()

	@UsesAutoLayout
	private var tvShowsCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.alpha = 0
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsVerticalScrollIndicator = false
		return collectionView
	}()

	var collectionView: UICollectionView { return tvShowsCollectionView }

	private lazy var spinnerView = createSpinnerView(withStyle: .large, childOf: contentView)
	private lazy var viewModel = TVShowListViewViewModel(collectionView: tvShowsCollectionView)

	weak var delegate: TopRatedTVShowsCellDelegate?

	// ! Lifecyle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		tvShowsCollectionView.delegate = viewModel
		viewModel.delegate = self
		setupUI()
		setupViewModel(viewModel)
	}

	/// Function to setup the view model & dynamically fetch tv shows based on the type
	func setupViewModel(_ viewModel: TVShowListViewViewModel) {
		viewModel.fetchTopRatedTVShows()
	}

	// ! Private

	private func setupUI() {
		contentView.addSubview(tvShowsCollectionView)
		tvShowsCollectionView.setCollectionViewLayout(compositionalLayout, animated: true)
		spinnerView.startAnimating()

		layoutUI()
	}

	private func layoutUI() {
		contentView.centerViewOnBothAxes(spinnerView)
		setupSizeConstraints(forView: spinnerView, width: 100, height: 100)

		contentView.pinViewToAllEdges(tvShowsCollectionView)
	}
}

// ! TVShowListViewViewModelDelegate

extension TopRatedTVShowsCell: TVShowListViewViewModelDelegate {
	func didLoadTVShows() {
		spinnerView.stopAnimating()
		viewModel.applySnapshot()

		UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
			self.tvShowsCollectionView.alpha = 1
		}
	}

	func didSelect(tvShow: TVShow) {
		delegate?.topRatedTVShowsCell(self, didSelect: tvShow)
	}
}
