import UIKit

@MainActor
protocol FinishedListViewDelegate: AnyObject {
	func finishedListView(_ finishedListView: FinishedListView, didSelect ratedTVShow: RatedTVShow)
}

/// Class to represent the finished tracked tv shows list view
final class FinishedListView: UIView {
	private lazy var viewModel = FinishedListViewViewModel(collectionView: finishedListCollectionView)
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: "Finished")

	private lazy var finishedListCollectionView: UICollectionView = {
		var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
		layoutConfig.showsSeparators = false

		let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
		collectionView.refreshControl = refreshControl
		collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
		return collectionView
	}()

	private var refreshControl = UIRefreshControl()

	weak var delegate: FinishedListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		viewModel.delegate = self
		addSubview(finishedListCollectionView)
		pinViewToSafeAreas(finishedListCollectionView)
		finishedListCollectionView.delegate = viewModel
	}

	@objc
	private func didPullToRefresh() {
		Task {
			await viewModel.fetchRatedShows()
		}
	}
}

// ! FinishedListViewViewModelDelegate

extension FinishedListView: FinishedListViewViewModelDelegate {
	func didSelect(ratedTVShow: RatedTVShow) {
		delegate?.finishedListView(self, didSelect: ratedTVShow)
	}
}
