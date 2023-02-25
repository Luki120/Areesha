import UIKit

/// Class to represent the TV show details view
final class TVShowDetailsView: UIView {

	private let viewModel: TVShowDetailsViewViewModel
	private var headerView: TVShowDetailsHeaderView!

	@UsesAutoLayout
	private var tvShowDetailsTableView: UITableView = {
		let tableView = UITableView()
		tableView.allowsSelection = false
		tableView.backgroundColor = .systemBackground
		tableView.register(TVShowDetailsGenreTableViewCell.self, forCellReuseIdentifier: TVShowDetailsGenreTableViewCell.identifier)
		tableView.register(TVShowDetailsOverviewTableViewCell.self, forCellReuseIdentifier: TVShowDetailsOverviewTableViewCell.identifier)
		tableView.register(TVShowDetailsCastTableViewCell.self, forCellReuseIdentifier: TVShowDetailsCastTableViewCell.identifier)
		tableView.register(TVShowDetailsNetworksTableViewCell.self, forCellReuseIdentifier: TVShowDetailsNetworksTableViewCell.identifier)
		return tableView
	}()

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.text = viewModel.title
		label.isHidden = true
		label.numberOfLines = 0
		return label
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: the view model object for this view
	init(viewModel: TVShowDetailsViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		setupTableView()
		viewModel.setupTableView(tvShowDetailsTableView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToAllEdges(tvShowDetailsTableView)
	}

	// ! Private

	private func setupTableView() {
		headerView = viewModel.setupHeaderView(forView: self)

		addSubview(tvShowDetailsTableView)
		tvShowDetailsTableView.delegate = self
		tvShowDetailsTableView.tableHeaderView = headerView
	}

}

// ! UITableViewDelegate

extension TVShowDetailsView: UITableViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let headerView = tvShowDetailsTableView.tableHeaderView as? TVShowDetailsHeaderView,
			let vc = parentViewController as? TVShowDetailsVC else { return }

		headerView.scrollViewDidScroll(scrollView: scrollView)

		let kNavigationBarHeight = (window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) +
			(vc.navigationController?.navigationBar.frame.height ?? 0)
		let kScrollableHeight = headerView.frame.size.height - kNavigationBarHeight

		let scrolledEnough = scrollView.contentOffset.y > kScrollableHeight

		UIView.animate(withDuration: 0.5, delay: 0, options: scrolledEnough ? .curveEaseIn: .curveEaseOut) {
			self.titleLabel.alpha = scrolledEnough ? 1 : 0
			if scrolledEnough { self.titleLabel.isHidden = false }
		}
	}

}
