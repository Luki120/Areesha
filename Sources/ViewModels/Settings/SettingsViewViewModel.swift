import UIKit

@MainActor
protocol SettingsViewViewModelDelegate: AnyObject {
	func didTapApp(_ app: App)
	func didTapSourceCodeCell()
}

/// View model class for `SettingsView`
@MainActor
final class SettingsViewViewModel: NSObject {
	weak var delegate: SettingsViewViewModelDelegate?

	// ! UITableViewDiffableDataSource

	@MainActor
	fileprivate struct Item {
		let id = UUID()
		let viewModel: AnyHashable
	}

	@MainActor
	fileprivate struct Section {
		let name: String
		let viewModels: [Item]

		static let developers: Section = .init(name: "Developers",
			viewModels: [
				.init(viewModel:
					DeveloperCellViewModel(
						lukiImageURL: URL(string: Developer.lukiIcon),
						leptosImageURL: URL(string: Developer.leptosIcon),
						lukiName: Developer.lukiName,
						leptosName: Developer.leptosName
					)
				)
			]
		)

		static let apps: Section = .init(name: "Other apps you may like",
			viewModels: [
				.init(viewModel: AppCellViewModel(app: .azure)),
				.init(viewModel: AppCellViewModel(app: .chelsea))
			]
		)

		static let sourceCode: Section = .init(name: "View the source",
			viewModels: [
				.init(viewModel: SourceCodeCellViewModel(text: "Source Code"))
			]
		)
	}

	private let sections: [Section] = [.developers, .apps, .sourceCode]

	private typealias DataSource = UITableViewDiffableDataSource<Section, Item>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

	private var dataSource: DataSource!

	private func setupFooterViewModel() -> SettingsFooterViewViewModel {
		var copyrightLabel: String {
			if #available(iOS 15.0, *) {
				return "© 2023-\(Date.now.formatted(.dateTime.year())) Luki120"
			}
			else {
				return "© 2023-\(Calendar.current.component(.year, from: Date())) Luki120"
			}
		}

		return .init(
			image: UIImage(asset: .tmdb),
			fullString: "Movie icon by icons8\n\n\(copyrightLabel)",
			subString: "icons8",
			urlString: "https://icons8.com/icon/EYpsuynPA2Ra/clapperboard"
		)
	}
}

// ! UITableView

private extension UITableViewCell {
	func configure(with viewModel: SourceCodeCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.text
		content.textProperties.font = .preferredFont(forTextStyle: .callout)

		contentConfiguration = content
	}
}

extension SettingsViewViewModel: UITableViewDelegate {
	private
	final class WorkingDataSource: DataSource {
		override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
			let section = self.snapshot().sectionIdentifiers[section]
			return section.name
		}
	}

	/// Function to setup the table view's footer
	/// - Parameters:
	///		- view: The view that owns the table view, therefore the footer
	func setupFooterView(forView view: UIView) -> SettingsFooterView {
		let footerView = SettingsFooterView()
		footerView.frame = .init(x: 0, y: 0, width: view.frame.size.width, height: 140)
		footerView.configure(with: setupFooterViewModel())
		return footerView
	}

	/// Function to setup the table view's diffable data source
	/// - Parameters:
	///		- tableView: The table view
	func setupTableView(_ tableView: UITableView) {
		dataSource = WorkingDataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
			guard let self else { fatalError() }

			switch sections[indexPath.section] {
				case .developers:
					guard let developerViewModel = item.viewModel as? DeveloperCellViewModel else { fatalError() }

					let cell: DeveloperCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: developerViewModel)
					return cell

				case .apps:
					guard let appViewModel = item.viewModel as? AppCellViewModel else { fatalError() }

					let cell: AppCell = tableView.dequeueReusableCell(for: indexPath)
					cell.configure(with: appViewModel)
					return cell

				case .sourceCode:
					guard let sourceCodeViewModel = item.viewModel as? SourceCodeCellViewModel else { fatalError() }

					let cell = tableView.dequeueReusableCell(withIdentifier: "VanillaCell", for: indexPath)
					cell.configure(with: sourceCodeViewModel)
					return cell

				default: fatalError()
			}
		}
		applySnapshot()
	}

	private func applySnapshot() {
		var snapshot = Snapshot()
		snapshot.appendSections(sections)
		sections.forEach { snapshot.appendItems($0.viewModels, toSection: $0) }
		dataSource.apply(snapshot)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch sections[indexPath.section] {
			case .developers: return 58
			default: break
		}

		return 44
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		switch sections[indexPath.section] {
			case .apps:
				guard let viewModel = sections[indexPath.section].viewModels[indexPath.row].viewModel as? AppCellViewModel else {
					return
				}
				delegate?.didTapApp(viewModel.app)

			case .sourceCode: delegate?.didTapSourceCodeCell()

			default: break
		}
	}
}

nonisolated extension SettingsViewViewModel.Item: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: SettingsViewViewModel.Item, rhs: SettingsViewViewModel.Item) -> Bool {
		return lhs.id == rhs.id
	}
}

nonisolated extension SettingsViewViewModel.Section: Hashable {}
