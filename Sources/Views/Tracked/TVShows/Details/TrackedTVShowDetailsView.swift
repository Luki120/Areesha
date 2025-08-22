import UIKit

@MainActor
protocol TrackedTVShowDetailsViewDelegate: AnyObject {
	func didTapSeasonsButton(in trackedTVShowDetailsView: TrackedTVShowDetailsView, tvShow: TVShow)
}

/// Class to represent the tracked tv show details view
final class TrackedTVShowDetailsView: UIView {
	// ! Lifecycle

	private let viewModel: TrackedTVShowDetailsViewViewModel

	@UsesAutoLayout
	private var trackedTVShowDetailsTableView: UITableView = {
		let tableView = UITableView()
		tableView.allowsSelection = false
		tableView.backgroundColor = .systemBackground
		tableView.register(TrackedTVShowDetailsCell.self, forCellReuseIdentifier: TrackedTVShowDetailsCell.identifier)
		tableView.register(TrackedTVShowDetailsDescriptionCell.self, forCellReuseIdentifier: TrackedTVShowDetailsDescriptionCell.identifier)
		return tableView
	}()

	private var headerView: MediaDetailsHeaderView {
		viewModel.setupEpisodeHeaderView(forView: self)
	}

	private lazy var seasonsButton = createRoundedButton { [weak self] in
		guard let self else { return }
		delegate?.didTapSeasonsButton(in: self, tvShow: viewModel.tvShow)		
	}

	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.title, isHidden: true)

	weak var delegate: TrackedTVShowDetailsViewDelegate?

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this view
	init(viewModel: TrackedTVShowDetailsViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		setupUI()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		seasonsButton.layer.shadowColor = UIColor.label.cgColor
	}

	// ! Private

	private func setupUI() {
		addSubviews(trackedTVShowDetailsTableView, seasonsButton)
		trackedTVShowDetailsTableView.delegate = self
		trackedTVShowDetailsTableView.tableHeaderView = headerView

		viewModel.setupTableView(trackedTVShowDetailsTableView)
		layoutUI()
	}

	private func layoutUI() {
		pinViewToAllEdges(trackedTVShowDetailsTableView)
		pinRoundedButton(seasonsButton)
	}
}

// ! Public

extension TrackedTVShowDetailsView {
	/// Function to create a `UIBarButtonItem`
	///
	/// - Parameters:
	///		- systemImage: A `String` that represents the image's system name
	///		- target: The target
	///		- action: The `Selector`
	/// - Returns: `UIBarButtonItem`
	func createBarButtonItem(systemImage: String, target: Any?, action: Selector) -> UIBarButtonItem {
		return headerView.createBarButtonItem(systemImage: systemImage, target: target, action: action)
	}
}

// ! UITableViewDelegate

extension TrackedTVShowDetailsView: UITableViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let headerView = trackedTVShowDetailsTableView.tableHeaderView as? MediaDetailsHeaderView else {
			return
		}

		let scrollableHeight = headerView.frame.height - safeAreaInsets.top

		headerView.scrollViewDidScroll(scrollView: scrollView)
		headerView.animate(titleLabel: titleLabel, in: scrollView, scrollableHeight: scrollableHeight)
	}
}
