import Combine
import UIKit

protocol SearchListViewViewModelDelegate: AnyObject {
	func didSelect(object: ObjectType)
	func shouldAnimateNoResultsLabel(isDataSourceEmpty: Bool)
}

/// View model class for `SearchListView`
final class SearchListViewViewModel: BaseViewModel<UICollectionViewListCell>, ObservableObject {
	private let searchQuerySubject = PassthroughSubject<String, Never>()
	private var searchedResults = [ObjectType]() {
		didSet {
			orderedViewModels += searchedResults.map { media in
				return SearchListCellViewModel(
					id: media.id,
					name: (media.type == .movie ? media.title : media.name) ?? ""
				)
			}
		}
	}

	private var subscriptions = Set<AnyCancellable>()
	weak var delegate: SearchListViewViewModelDelegate?

	override init(collectionView: UICollectionView) {
		super.init(collectionView: collectionView)
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
		setupSearchQuerySubject()
	}

	private func fetch(query: String? = nil) {
		guard let query,
			let urlString = "\(Service.Constants.searchQueryBaseURL)&query=\(query)"
				.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
			let url = URL(string: urlString) else { return }

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: SearchResponse.self)
			.catch { _ in Just(SearchResponse(results: [])) }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] response in
				guard let self else { return }
				let filteredResults = response.results.filter { $0.type == .movie || $0.type == .tv }
				self.searchedResults = filteredResults
				applySnapshot(isOrderedSet: true)

				delegate?.shouldAnimateNoResultsLabel(isDataSourceEmpty: self.searchedResults.isEmpty)
			}
			.store(in: &subscriptions)
	}

	private func setupSearchQuerySubject() {
		searchQuerySubject
			.debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
			.sink { [weak self] in
				self?.orderedViewModels.removeAll()
				self?.fetch(query: $0)
			}
			.store(in: &subscriptions)
	}
}

// ! Public

extension SearchListViewViewModel {
	/// Function to send the query subject
	/// - Parameter subject: A `String` representing the query subject
	func sendQuerySubject(_ subject: String) {
		searchQuerySubject.send(subject)
	}
}

// ! CollectionView

extension UICollectionViewListCell: Configurable {
	func configure(with viewModel: SearchListCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.name
		content.textProperties.font = .preferredFont(forTextStyle: .headline, weight: .semibold, size: 18)

		contentConfiguration = content
	}
}

extension SearchListViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(object: searchedResults[indexPath.item])
	}
}
