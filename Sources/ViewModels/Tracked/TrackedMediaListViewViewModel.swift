import Combine
import UIKit

@MainActor
protocol TrackedMediaListViewViewModelDelegate: AnyObject {
	func didSelectItem(at indexPath: IndexPath)
}

/// View model struct for `TrackedMediaListView`
@MainActor
final class TrackedMediaListViewViewModel: BaseViewModel<TrackedMediaListCell> {
	weak var delegate: TrackedMediaListViewViewModelDelegate?
	private var subscriptions = Set<AnyCancellable>()

	override func awake() {
		viewModels = [
			.init(text: "Currently watching", imageName: "play"),
			.init(text: "Finished", imageName: "checkmark"),
			.init(text: "Rated movies", imageName: "star")
		]
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
	}
}

// ! Auth

extension TrackedMediaListViewViewModel {
	/// Function to fetch a request token
	///	- Parameter completion: `@escaping` closure that takes a `String` & returns nothing
	func fetchRequestToken(completion: @escaping (String) -> ()) async {
		guard let url = URL(string: Service.Constants.requestTokenURL) else { return }

		await Service.sharedInstance.fetch(withURL: url, expecting: TokenResponse.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { response, _ in
				completion(response.requestToken)
			}
			.store(in: &subscriptions)
	}

	/// Function to create a session id
	///	- Parameter requestToken: A `String` that represents the request token
	func createSessionId(requestToken: String) async {
		await Service.sharedInstance.createSessionId(requestToken: requestToken)
			.catch { error in print("ERROR: \(error)"); return Just(Data()) }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] data in
				Task {
					let response = try JSONDecoder().decode(SessionIdResponse.self, from: data)
					UserDefaults.standard.set(response.sessionId, forKey: "sessionId")

					await self?.fetchAccountId(sessionId: response.sessionId)
				}
			}
			.store(in: &subscriptions)
	}

	/// Function to fetch the account id
	///	- Parameter sessionId: A `String` that represents the session id
	func fetchAccountId(sessionId: String) async {
		guard let url = URL(string: Service.Constants.accountDetailsURL + sessionId) else { return }

		await Service.sharedInstance.fetch(withURL: url, expecting: AccountResponse.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { response, _ in
				UserDefaults.standard.set(response.id, forKey: "accountId")
			}
			.store(in: &subscriptions)
	}
}

// ! Configurable

final class TrackedMediaListCell: UICollectionViewListCell {}

extension TrackedMediaListCell: Configurable {
	func configure(with viewModel: TrackedMediaListCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.text
		content.image = UIImage(systemName: viewModel.imageName)
		content.imageProperties.tintColor = .areeshaPinkColor

		contentConfiguration = content
	}
}

// ! UICollectionViewDelegate

extension TrackedMediaListViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelectItem(at: indexPath)
	}
}
