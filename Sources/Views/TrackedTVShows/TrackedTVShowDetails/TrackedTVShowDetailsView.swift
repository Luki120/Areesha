import UIKit


protocol TrackedTVShowDetailsViewDelegate: AnyObject {
	func didTapSeasonsButton(in trackedTVShowDetailsView: TrackedTVShowDetailsView, tvShow: TVShow)
}

/// Class to represent the tracked tv show details view
final class TrackedTVShowDetailsView: UIView {
	// ! Lifecycle

	private let viewModel: TrackedTVShowDetailsViewViewModel
	private var headerView: TrackedTVShowDetailsHeaderView!

	@UsesAutoLayout
	private var trackedTVShowDetailsTableView: UITableView = {
		let tableView = UITableView()
		tableView.allowsSelection = false
		tableView.backgroundColor = .systemBackground
		tableView.register(TrackedTVShowDetailsCell.self, forCellReuseIdentifier: TrackedTVShowDetailsCell.identifier)
		tableView.register(TrackedTVShowDetailsOverviewCell.self, forCellReuseIdentifier: TrackedTVShowDetailsOverviewCell.identifier)
		return tableView
	}()

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
	/// - Parameters:
	///		- viewModel: The view model object for this view
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
		headerView = viewModel.setupEpisodeHeaderView(forView: self)

		addSubviews(trackedTVShowDetailsTableView, seasonsButton)
		trackedTVShowDetailsTableView.delegate = self
		trackedTVShowDetailsTableView.tableHeaderView = headerView

		viewModel.setupTrackedTVShowDetailsTableView(trackedTVShowDetailsTableView)
		layoutUI()
	}

	private func layoutUI() {
		pinViewToAllEdges(trackedTVShowDetailsTableView)
		pinRoundedButton(seasonsButton)
	}
}

// ! UITableViewDelegate

extension TrackedTVShowDetailsView: UITableViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let headerView = trackedTVShowDetailsTableView.tableHeaderView as? TrackedTVShowDetailsHeaderView,
			let vc = parentViewController as? TrackedTVShowDetailsVC else { return }

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
