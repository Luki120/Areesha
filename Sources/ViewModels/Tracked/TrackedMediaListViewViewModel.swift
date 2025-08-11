import UIKit

protocol TrackedMediaListViewViewModelDelegate: AnyObject {
	func didSelectItem(at indexPath: IndexPath)
}

/// View model struct for `TrackedMediaListView`
final class TrackedMediaListViewViewModel: NSObject {
	weak var delegate: TrackedMediaListViewViewModelDelegate?

	private let cellViewModels: [TrackedMediaListCellViewModel] = [
		.init(text: "Currently watching", imageName: "play"),
		.init(text: "Finished", imageName: "checkmark")
	]

	// ! UICollectionViewDiffableDataSource

	private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TrackedMediaListCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Section, TrackedMediaListCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TrackedMediaListCellViewModel>

	private var dataSource: DataSource!

	private enum Section {
		case main
	}
}

// ! CollectionView

extension UICollectionViewListCell {
	func configureCell(with viewModel: TrackedMediaListCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.text
		content.image = UIImage(systemName: viewModel.imageName)
		content.imageProperties.tintColor = .areeshaPinkColor

		contentConfiguration = content
	}
}

extension TrackedMediaListViewViewModel: UICollectionViewDelegate {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
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
		applySnapshot()
	}

	private func applySnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(cellViewModels)
		dataSource.apply(snapshot)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelectItem(at: indexPath)
	}
}
