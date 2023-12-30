import UIKit


protocol TrackedTVShowListViewViewModelDelegate: AnyObject {
	func didSelectItemAt(indexPath: IndexPath)
}

/// View model struct for TrackedTVShowsListView
final class TrackedTVShowListViewViewModel: NSObject {

	weak var delegate: TrackedTVShowListViewViewModelDelegate?

	private let cellViewModels: [TrackedTVShowCollectionViewListCellViewModel] = [
		.init(text: "Currently watching", imageName: "play"),
		.init(text: "Finished", imageName: "checkmark")
	]

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TrackedTVShowCollectionViewListCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, TrackedTVShowCollectionViewListCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, TrackedTVShowCollectionViewListCellViewModel>

	private var dataSource: DataSource!

	@frozen private enum Sections {
		case main
	}

}

// ! CollectionView

extension UICollectionViewListCell {

	func configureCell(with viewModel: TrackedTVShowCollectionViewListCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.text
		content.image = UIImage(systemName: viewModel.imageName)
		content.imageProperties.tintColor = .areeshaPinkColor

		contentConfiguration = content
	}

}

extension TrackedTVShowListViewViewModel: UICollectionViewDelegate {

	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///		- collectionView: The collection view
	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			cell.configureCell(with: viewModel)
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier in
			let cell = collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: identifier
			)
			return cell
		}
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(cellViewModels)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelectItemAt(indexPath: indexPath)
	}

}
