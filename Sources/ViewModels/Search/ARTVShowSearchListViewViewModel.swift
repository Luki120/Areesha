import Combine
import UIKit


protocol ARTVShowSearchListViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
}

/// View model class for ARTVShowSearchView
final class ARTVShowSearchListViewViewModel: ARBaseViewModel<UICollectionViewListCell>, ObservableObject {

	let searchQuerySubject = PassthroughSubject<String, Never>()

	private var searchedTVShows = [TVShow]() {
		didSet {
			for tvShow in searchedTVShows {
				let viewModel = ARTVShowSearchCollectionViewListCellViewModel(tvShowNameText: tvShow.name)

				if !viewModels.contains(viewModel) {
					viewModels.append(viewModel)
				}
			}
		}
	}

	weak var delegate: ARTVShowSearchListViewViewModelDelegate?

	private var subscriptions = Set<AnyCancellable>()

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
		setupSearchQuerySubject()
	}

	private func setupSearchQuerySubject() {
		searchQuerySubject
			.debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
			.sink { [weak self] in
				self?.viewModels.removeAll()
				self?.fetchSearchedTVShow(withQuery: $0)
			}
			.store(in: &subscriptions)
	}

}

extension ARTVShowSearchListViewViewModel {

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

extension UICollectionViewListCell: Configurable {
	func configure(with viewModel: ARTVShowSearchCollectionViewListCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.displayTVShowNameText
		content.textProperties.font = .systemFont(ofSize: 18, weight: .semibold)

		contentConfiguration = content
	}
}

extension ARTVShowSearchListViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(tvShow: searchedTVShows[indexPath.row])
	}

}
