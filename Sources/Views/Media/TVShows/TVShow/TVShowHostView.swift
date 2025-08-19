import UIKit

@MainActor
protocol TVShowHostViewDelegate: AnyObject {
	func tvShowHostView(_ tvShowHostView: TVShowHostView, didSelect tvShow: TVShow)
	func tvShowHostView(_ tvShowHostView: TVShowHostView, didSelect movie: Movie)
}

/// Class to represent the tv shows host view
final class TVShowHostView: UIView {
	private let viewModel = TVShowHostViewViewModel()

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
		layoutUI()

		viewModel.delegate = self
		topHeaderView.delegate = self
	}

	// ! Private

	private func setupCollectionView() {
		hostCollectionView.delegate = self
		hostCollectionView.isPagingEnabled = true
		hostCollectionView.setCollectionViewLayout(compositionalLayout, animated: true)
		viewModel.setupDiffableDataSource(for: hostCollectionView)
	}

	private func layoutUI() {
		NSLayoutConstraint.activate([
			topHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
			topHeaderView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			topHeaderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			topHeaderView.heightAnchor.constraint(equalToConstant: 50),

			hostCollectionView.topAnchor.constraint(equalTo: topHeaderView.bottomAnchor),
			hostCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
			hostCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			hostCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
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

	func didSelect(movie: Movie) {
		delegate?.tvShowHostView(self, didSelect: movie)
	}
}

// ! UICollectionViewDelegate

extension TVShowHostView: UICollectionViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let progress = scrollView.contentOffset.x / (scrollView.frame.width * 2)
		let maxDistance = topHeaderView.frame.width * (2 / 3)

		topHeaderView.transparentViewLeadingAnchorConstraint.constant = min(max(progress * maxDistance, 0), maxDistance)
	}

	func scrollViewWillEndDragging(
		_ scrollView: UIScrollView,
		withVelocity velocity: CGPoint,
		targetContentOffset: UnsafeMutablePointer<CGPoint>
	) {
		let itemWidth = scrollView.frame.width
		let index = targetContentOffset.pointee.x / itemWidth
		let indexPath = IndexPath(item: Int(index), section: 0)
		topHeaderView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
	}
}

// ! Public

extension TVShowHostView {
	/// Function to scroll the tv shows list collection view to the top when tapping a tab bar item
	func scrollToTop() {
		// credits ⇝ https://stackoverflow.com/a/56380938
		var visibleCells: [UICollectionViewCell] {
			return hostCollectionView.visibleCells.filter { cell in
				let cellRect = hostCollectionView.convert(cell.frame, to: hostCollectionView.superview)
				return hostCollectionView.frame.contains(cellRect)
			}
		}
		visibleCells.forEach {
			let cell = $0 as? TopRatedTVShowsCell
			cell?.collectionView.setContentOffset(
				CGPoint(x: 0, y: -(cell?.collectionView.safeAreaInsets.top ?? 0)),
				animated: true
			)
		}
	}
}
