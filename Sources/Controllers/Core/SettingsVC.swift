import UIKit

/// Controller that'll show the settings view
final class SettingsVC: UIViewController {

	private let settingsView = SettingsView()

	var coordinator: SettingsCoordinator?

	// ! Lifecycle

	override func loadView() { view = settingsView }

	override func viewDidLoad() {
		super.viewDidLoad()
		settingsView.delegate = self
		settingsView.backgroundColor = .systemBackground
	}
}

// ! SettingsViewDelegate

extension SettingsVC: SettingsViewDelegate {

	func settingsView(_ settingsView: SettingsView, didTap app: App) {
		coordinator?.eventOccurred(with: .appCellTapped(app: app))
	}

	func didTapSourceCodeCell(in settingsView: SettingsView) {
		coordinator?.eventOccurred(with: .sourceCodeCellTapped)
	}

}
