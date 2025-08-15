import UIKit

@MainActor
protocol RatedMoviesViewDelegate: AnyObject {
	func ratedMoviesView(_ ratedMoviesView: RatedMoviesView, didTap ratedMovie: RatedMovie)
}

/// Class to represent the rated movies list view
final class RatedMoviesView: UIView {
	private lazy var viewModel = RatedMoviesViewViewModel(collectionView: ratedMoviesCollectionView)
	weak var delegate: RatedMoviesViewDelegate?

	private let compositionalLayout: UICollectionViewCompositionalLayout = {
		let item = NSCollectionLayoutItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1 / 4),
				heightDimension: .fractionalWidth((1 / 4) * 1.65)
			)
		)

		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1),
				heightDimension: .estimated(300)
			),
			subitem: item,
			count: 4
		)
		group.interItemSpacing = .fixed(10)

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
		section.interGroupSpacing = 30

		return UICollectionViewCompositionalLayout(section: section)
	}()

	@UsesAutoLayout
	private var ratedMoviesCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .systemGroupedBackground
		collectionView.showsVerticalScrollIndicator = false
		return collectionView
	}()

	private var refreshControl = UIRefreshControl()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	// ! Private

	private func setupUI() {
		viewModel.delegate = self

		addSubview(ratedMoviesCollectionView)
		ratedMoviesCollectionView.delegate = viewModel
		ratedMoviesCollectionView.refreshControl = refreshControl
		ratedMoviesCollectionView.setCollectionViewLayout(compositionalLayout, animated: true)
		pinViewToSafeAreas(ratedMoviesCollectionView)

		refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
	}

	@objc
	private func didPullToRefresh() {
		Task {
			await viewModel.fetchRatedMovies()
		}
	}
}

// ! RatedMoviesViewViewModelDelegate

extension RatedMoviesView: RatedMoviesViewViewModelDelegate {
	func didTap(movie: RatedMovie) {
		delegate?.ratedMoviesView(self, didTap: movie)
	}
}
