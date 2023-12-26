import UIKit


protocol FinishedTrackedTVShowListViewDelegate: AnyObject {
	func finishedTrackedTVShowListView(
		_ finishedTrackedTVShowListView: FinishedTrackedTVShowListView,
		didSelect trackedTVShow: TrackedTVShow
	)
}

/// Class to represent the finished tracked tv shows list view
final class FinishedTrackedTVShowListView: UIView {

	private lazy var viewModel = FinishedTrackedTVShowListViewViewModel()
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: "Finished")

	private lazy var finishedTrackedTVShowsListCollectionView: UICollectionView = {
		var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
		layoutConfig.showsSeparators = false
		layoutConfig.trailingSwipeActionsConfigurationProvider = { indexPath in
			let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
				self.viewModel.deleteItem(at: indexPath)
				completion(true)
			}
			return UISwipeActionsConfiguration(actions: [deleteAction])
		}

		let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
		collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()

	weak var delegate: FinishedTrackedTVShowListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		viewModel.delegate = self
		viewModel.setupDiffableDataSource(for: finishedTrackedTVShowsListCollectionView)
		addSubview(finishedTrackedTVShowsListCollectionView)
		finishedTrackedTVShowsListCollectionView.delegate = viewModel
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToSafeAreas(finishedTrackedTVShowsListCollectionView)
	}

}

// ! FinishedTrackedTVShowListViewViewModelDelegate

extension FinishedTrackedTVShowListView: FinishedTrackedTVShowListViewViewModelDelegate {

	func didSelect(trackedTVShow: TrackedTVShow) {
		delegate?.finishedTrackedTVShowListView(self, didSelect: trackedTVShow)
	}

}
