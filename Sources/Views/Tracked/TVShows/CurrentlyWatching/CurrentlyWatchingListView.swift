import UIKit


protocol CurrentlyWatchingListViewDelegate: AnyObject {
	func currentlyWatchingListView(
		_ currentlyWatchingListView: CurrentlyWatchingListView,
		didSelect trackedTVShow: TrackedTVShow
	)
	func didShowToastView(in CurrentlyWatchingListView: CurrentlyWatchingListView)
}

/// Class to represent the currently watching tracked tv shows list view
final class CurrentlyWatchingListView: UIView {

	private(set) lazy var viewModel = CurrentlyWatchingListViewViewModel()
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: "Currently watching")

	private lazy var toastView = createToastView()
	private lazy var toastViewLabel = createToastViewLabel(withMessage: "Already watched.")

	private lazy var currentlyWatchingTrackedTVShowListCollectionView: UICollectionView = {
		let sectionProvider = { sectionIndex, layoutEnvironment in
			self.setupListConfig(sectionIndex: sectionIndex, layoutEnvironment: layoutEnvironment)
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
		currentlyWatchingTrackedTVShowListCollectionView.addSubview(toastView)
		toastView.addSubview(toastViewLabel)

		layoutUI()
	}

	private func layoutUI() {
		pinViewToSafeAreas(currentlyWatchingTrackedTVShowListCollectionView)

		NSLayoutConstraint.activate([
			toastView.centerXAnchor.constraint(equalTo: centerXAnchor),
			toastView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -25),
			toastView.widthAnchor.constraint(equalToConstant: 130),
			toastView.heightAnchor.constraint(equalToConstant: 40)
		])

		toastView.centerViewOnBothAxes(toastViewLabel)
		toastView.setupHorizontalConstraints(forView: toastViewLabel, leadingConstant: 10, trailingConstant: -10)
	}

	private func setupListConfig(sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
		listConfig.headerMode = .supplementary
		listConfig.showsSeparators = false

		listConfig.leadingSwipeActionsConfigurationProvider = { indexPath in
			let leadingAction = UIContextualAction(
				style: .destructive,
				title: sectionIndex == 0 ? "Returning series" : "Currently watching"
			) { _, _, completion in
				self.viewModel.markShowAsReturningSeries(at: indexPath, toggle: sectionIndex == 0 ? true : false)
				completion(true)
			}
			leadingAction.backgroundColor = .systemOrange

			let trackNextEpisodeAction = UIContextualAction(style: .destructive, title: "Track next") { _, _, completion in
				self.viewModel.trackNextEpisode(at: indexPath)
				completion(true)
			}
			trackNextEpisodeAction.backgroundColor = .systemGreen

			return UISwipeActionsConfiguration(
				actions: sectionIndex == 0 ? [leadingAction, trackNextEpisodeAction] : [leadingAction]
			)
		}

		listConfig.trailingSwipeActionsConfigurationProvider = { indexPath in
			let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
				self.viewModel.deleteItem(at: indexPath)
				completion(true)
			}
			let finishedShowAction = UIContextualAction(style: .destructive, title: "Finished") { _, _, completion in
				self.viewModel.finishedShow(at: indexPath)
				completion(true)
			}
			finishedShowAction.backgroundColor = .areeshaPinkColor
			return UISwipeActionsConfiguration(actions: [deleteAction, finishedShowAction])
		}

		return NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
	}

}

// ! Public

extension CurrentlyWatchingListView {

	/// Function to fade in & out the toast view
	func fadeInOutToastView() {
		animateToastView(toastView)
	}

}

// ! CurrentlyWatchingListViewViewModelDelegate

extension CurrentlyWatchingListView: CurrentlyWatchingListViewViewModelDelegate {

	func didSelect(trackedTVShow: TrackedTVShow) {
		delegate?.currentlyWatchingListView(self, didSelect: trackedTVShow)
	}

	func didShowToastView() {
		delegate?.didShowToastView(in: self)
	}

}
