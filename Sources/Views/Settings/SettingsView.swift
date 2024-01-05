import UIKit


protocol SettingsViewDelegate: AnyObject {
	func settingsView(_ settingsView: SettingsView, didTap app: App)
	func didTapSourceCodeCell(in settingsView: SettingsView)
}

/// Class to represent the settings view
final class SettingsView: UIView {

	private let viewModel = SettingsViewViewModel()

	@UsesAutoLayout
	private var settingsTableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.backgroundColor = .systemGroupedBackground
		if #available(iOS 15, *) {
			tableView.sectionHeaderTopPadding = 0
		}
 		else {
			tableView.estimatedSectionHeaderHeight = 38
		}
		tableView.register(DeveloperTableViewCell.self, forCellReuseIdentifier: DeveloperTableViewCell.identifier)
		tableView.register(AppTableViewCell.self, forCellReuseIdentifier: AppTableViewCell.identifier)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VanillaCell")
		return tableView
	}()

	weak var delegate: SettingsViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(settingsTableView)
		settingsTableView.delegate = viewModel
		settingsTableView.tableFooterView = viewModel.setupFooterView(forView: self)

		viewModel.delegate = self
		viewModel.setupTableView(settingsTableView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToAllEdges(settingsTableView)
	}

}

// ! SettingsViewViewModelDelegate

extension SettingsView: SettingsViewViewModelDelegate {

	func didTapApp(_ app: App) {
		delegate?.settingsView(self, didTap: app)
	}

	func didTapSourceCodeCell() {
		delegate?.didTapSourceCodeCell(in: self)
	}

}
