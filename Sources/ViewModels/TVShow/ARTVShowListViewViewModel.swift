import Combine
import UIKit


protocol ARTVShowListViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
}

/// View model class for ARTVShowListView
final class ARTVShowListViewViewModel: NSObject {

	private var cellViewModels = [ARTVShowCollectionViewCellViewModel]()
	private var tvShows = [TVShow]() {
		didSet {
			for tvShow in tvShows {
				let imageURLString = "\(ARService.Constants.baseImageURL)w500/\(tvShow.poster_path ?? "")"
				guard let url = URL(string: imageURLString) else { return }
				let viewModel = ARTVShowCollectionViewCellViewModel(imageURL: url)

				if !cellViewModels.contains(viewModel) {
					cellViewModels.append(viewModel)
				}
			}
		}
	}

	private var subscriptions = Set<AnyCancellable>()

	weak var delegate: ARTVShowListViewViewModelDelegate?

	// ! UITableViewDiffableDataSource

	@frozen private enum Sections: Hashable {
		case main
	}

	private typealias CellRegistration = UICollectionView.CellRegistration<ARTVShowCollectionViewCell, ARTVShowCollectionViewCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, ARTVShowCollectionViewCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, ARTVShowCollectionViewCellViewModel>

	private var dataSource: DataSource!
	private var snapshot: Snapshot!

	// ! Public

	/// Function to get the top rated TV shows
	func fetchTVShows() {
		guard let url = URL(string: ARService.Constants.topRatedTVShowsURL) else { return }

		ARService.sharedInstance.fetchTVShows(withURL: url, expecting: APIResponse.self)
			.catch { _ in Just(APIResponse(results: [])) }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] tvShows in
				self?.tvShows = tvShows.results
				self?.applySnapshot()
			}
			.store(in: &subscriptions)
	}

}

// ! CollectionView

extension ARTVShowListViewViewModel {

	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///		- collectionView: the collection view
	func setupCollectionViewDiffableDataSource(_ collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			Task {
				await cell.configure(with: viewModel)
			}
		}

		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identifier -> UICollectionViewCell? in
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
		snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(cellViewModels)

		dataSource.apply(snapshot, animatingDifferences: true)
	}

}

extension ARTVShowListViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(tvShow: tvShows[indexPath.row])
	}

}
