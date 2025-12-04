import UIKit
import SafariServices

/// Controller that'll show the tracked media list view
final class TrackedMediaVC: UIViewController {
	private let trackedMediaListView = TrackedMediaListView()
	private var requestToken = ""

	var coordinator: TrackedMediaCoordinator?

	// ! Lifecycle

	override func loadView() { view = trackedMediaListView }

	override func viewDidLoad() {
		super.viewDidLoad()
		trackedMediaListView.delegate = self
		trackedMediaListView.backgroundColor = .systemBackground

		presentAlert()
	}

	private func presentAlert() {
		guard UserDefaults.standard.integer(forKey: "accountId") == 0 else { return }

		let alertController = UIAlertController(title: "Log in required", message: "Please log in with your TMDB account in order to rate tv shows & movies", preferredStyle: .alert)

		let logInAction = UIAlertAction(title: "Ok", style: .destructive) { _ in
			self.trackedMediaListView.fetchRequestToken { [weak self] requestToken in
				self?.requestToken = requestToken

				let validateTokenURL = "https://www.themoviedb.org/authenticate/\(requestToken)"
				guard let url = URL(string: validateTokenURL) else { return }

				let safariVC = SFSafariViewController(url: url)
				safariVC.delegate = self
				safariVC.modalPresentationStyle = .pageSheet
				self?.present(safariVC, animated: true)
			}
		}
		alertController.addAction(logInAction)
		present(alertController, animated: true)
	}
}

extension TrackedMediaVC: @MainActor SFSafariViewControllerDelegate {
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		trackedMediaListView.createSessionId(requestToken: requestToken)
	}
}

// ! TrackedMediaListViewDelegate

extension TrackedMediaVC: TrackedMediaListViewDelegate {
	func trackedMediaListView(
		_ trackedMediaListView: TrackedMediaListView,
		didSelectItemAt indexPath: IndexPath
	) {
		coordinator?.eventOccurred(with: .cellTapped(indexPath: indexPath))
	}
}
