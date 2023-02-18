import Combine
import UIKit


protocol ARTVShowSearchListViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
}

/// View model class for ARTVShowSearchView
final class ARTVShowSearchListViewViewModel: NSObject, ObservableObject {

	let searchQuerySubject = PassthroughSubject<String, Never>()

	private var cellViewModels = [ARTVShowSearchCollectionViewListCellViewModel]()
	private var searchedTVShows = [TVShow]() {
		didSet {
			for tvShow in searchedTVShows {
				let viewModel = ARTVShowSearchCollectionViewListCellViewModel(tvShowNameText: tvShow.name)

				if !cellViewModels.contains(viewModel) {
					cellViewModels.append(viewModel)
				}
			}
		}
	}

	weak var delegate: ARTVShowSearchListViewViewModelDelegate?

	private var subscriptions = Set<AnyCancellable>()

	// ! UITableViewDiffableDataSource

	@frozen private enum Sections: Hashable {
		case main
	}

	private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ARTVShowSearchCollectionViewListCellViewModel>
	private typealias DataSource = UICollectionViewDiffableDataSource<Sections, ARTVShowSearchCollectionViewListCellViewModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Sections, ARTVShowSearchCollectionViewListCellViewModel>

	private var dataSource: DataSource!
	private var snapshot: Snapshot!

	override init() {
		super.init()
		setupSearchQuerySubject()
	}

	private func setupSearchQuerySubject() {
		searchQuerySubject
			.debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
			.sink { [weak self] in
				self?.cellViewModels.removeAll()
				self?.fetchSearchedTVShow(withQuery: $0)
			}
			.store(in: &subscriptions)
	}

	// ! Public

	/// Function to get the queried tv show by name
	/// - Parameters:
	///		- fromQuery: an optional string to represent the given query,
	///		defaulting to nil if none was provided
	func fetchSearchedTVShow(withQuery query: String? = nil) {
		guard let url = URL(string: "\(ARService.Constants.searchTVShowBaseURL)&query=\(query ?? "")") else { return }

		ARService.sharedInstance.fetchTVShows(withURL: url, expecting: APIResponse.self)
			.catch { _ in Just(APIResponse(results: [])) }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] searchedTVShows in
				self?.searchedTVShows = searchedTVShows.results
				self?.applySnapshot()
			}
			.store(in: &subscriptions)
	}

}

// ! CollectionView

extension ARTVShowSearchListViewViewModel {

	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///		- collectionView: the collection view
	func setupCollectionViewDiffableDataSource(_ collectionView: UICollectionView) {
		let cellRegistration = CellRegistration { cell, _, viewModel in
			var content = cell.defaultContentConfiguration()
			content.text = viewModel.displayTVShowNameText

			cell.contentConfiguration = content
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

extension ARTVShowSearchListViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(tvShow: searchedTVShows[indexPath.row])
	}

}
