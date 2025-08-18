import UIKit

@MainActor
protocol CurrentlyWatchingListViewDelegate: AnyObject {
	func currentlyWatchingListView(
		_ currentlyWatchingListView: CurrentlyWatchingListView,
		didSelect trackedTVShow: TrackedTVShow
	)
}

/// Class to represent the currently watching tracked tv shows list view
final class CurrentlyWatchingListView: UIView {
	let viewModel = CurrentlyWatchingListViewViewModel()
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: "Currently watching")

	private lazy var currentlyWatchingTrackedTVShowListCollectionView: UICollectionView = {
		let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, layoutEnvironment in

			switch self.viewModel.sectionIdentifiers[sectionIndex] {
				case .currentlyWatching: return self.setupListConfig(sectionIndex: sectionIndex, layoutEnvironment: layoutEnvironment)
				case .returningSeries: return self.setupListConfig(sectionIndex: sectionIndex, layoutEnvironment: layoutEnvironment)
			}
		}

		let listLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
		collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()

	weak var delegate: CurrentlyWatchingListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		viewModel.delegate = self
		viewModel.setupDiffableDataSource(for: currentlyWatchingTrackedTVShowListCollectionView)
		currentlyWatchingTrackedTVShowListCollectionView.delegate = viewModel

		setupUI()
	}

	// ! Private

	private func setupUI() {
		addSubview(currentlyWatchingTrackedTVShowListCollectionView)
		pinViewToSafeAreas(currentlyWatchingTrackedTVShowListCollectionView)
	}

	private func setupListConfig(sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
		listConfig.headerMode = .supplementary
		listConfig.showsSeparators = false

		listConfig.leadingSwipeActionsConfigurationProvider = { indexPath in
			let sectionIdentifier = self.viewModel.sectionIdentifiers[indexPath.section]

			let leadingAction = UIContextualAction(
				style: .destructive,
				title: sectionIdentifier == .currentlyWatching ? "Returning series" : "Currently watching"
			) { _, _, completion in
				self.viewModel.markShowAsReturningSeries(
					at: indexPath,
					toggle: sectionIdentifier == .currentlyWatching ? true : false
				)
				completion(true)
			}
			leadingAction.backgroundColor = .systemOrange

			let trackNextEpisodeAction = UIContextualAction(style: .destructive, title: "Track next") { _, _, completion in
				self.viewModel.trackNextEpisode(at: indexPath)
				completion(true)
			}
			trackNextEpisodeAction.backgroundColor = .systemGreen

			return UISwipeActionsConfiguration(
				actions: sectionIdentifier == .currentlyWatching ? [leadingAction, trackNextEpisodeAction] : [leadingAction]
			)
		}

		listConfig.trailingSwipeActionsConfigurationProvider = { indexPath in
			let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
				self.viewModel.deleteItem(at: indexPath)
				completion(true)
			}
			let finishedShowAction = UIContextualAction(style: .destructive, title: "Finished") { _, _, completion in
				self.viewModel.deleteItem(at: indexPath)
				completion(true)
			}
			finishedShowAction.backgroundColor = .areeshaPinkColor
			return UISwipeActionsConfiguration(actions: [deleteAction, finishedShowAction])
		}

		return NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
	}
}

// ! CurrentlyWatchingListViewViewModelDelegate

extension CurrentlyWatchingListView: CurrentlyWatchingListViewViewModelDelegate {
	func didSelect(trackedTVShow: TrackedTVShow) {
		delegate?.currentlyWatchingListView(self, didSelect: trackedTVShow)
	}
}
