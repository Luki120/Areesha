import Combine
import UIKit


protocol TVShowSearchListViewViewModelDelegate: AnyObject {
	func didSelect(tvShow: TVShow)
	func shouldAnimateNoResultsLabel(isDataSourceEmpty: Bool)
}

/// View model class for `TVShowSearchListView`
final class TVShowSearchListViewViewModel: BaseViewModel<UICollectionViewListCell>, ObservableObject {
	private let searchQuerySubject = PassthroughSubject<String, Never>()
	private var searchedTVShows = [TVShow]() {
		didSet {
			orderedViewModels += searchedTVShows.compactMap { tvShow in
				return TVShowSearchListCellViewModel(id: tvShow.id, tvShowNameText: tvShow.name)
			}
		}
	}

	private var subscriptions = Set<AnyCancellable>()
	weak var delegate: TVShowSearchListViewViewModelDelegate?

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
		setupSearchQuerySubject()
	}

	private func fetchSearchedTVShow(withQuery query: String? = nil) {
		guard let query,
			let urlString = "\(Service.Constants.searchTVShowBaseURL)&query=\(query)"
				.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
			let url = URL(string: urlString) else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: APIResponse.self)
			.catch { _ in Just(APIResponse(results: [])) }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] searchedTVShows in
				guard let self else { return }
				self.searchedTVShows = searchedTVShows.results
				applySnapshot(isOrderedSet: true)

				delegate?.shouldAnimateNoResultsLabel(isDataSourceEmpty: self.searchedTVShows.isEmpty)
			}
			.store(in: &subscriptions)
	}

	private func setupSearchQuerySubject() {
		searchQuerySubject
			.debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
			.sink { [weak self] in
				self?.orderedViewModels.removeAll()
				self?.fetchSearchedTVShow(withQuery: $0)
			}
			.store(in: &subscriptions)
	}
}

extension TVShowSearchListViewViewModel {
	// ! Public

	/// Function to send the query subject
	/// - Parameters:
	///		- subject: A string representing the query subject
	func sendQuerySubject(_ subject: String) {
		searchQuerySubject.send(subject)
	}
}

// ! CollectionView

extension UICollectionViewListCell: Configurable {
	func configure(with viewModel: TVShowSearchListCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.tvShowNameText
		content.textProperties.font = .systemFont(ofSize: 18, weight: .semibold)

		contentConfiguration = content
	}
}

extension TVShowSearchListViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(tvShow: searchedTVShows[indexPath.item])
	}
}
