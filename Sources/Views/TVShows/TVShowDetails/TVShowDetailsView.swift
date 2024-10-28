import UIKit


protocol TVShowDetailsViewDelegate: AnyObject {
	func didTapSeasonsButton(in tvShowDetailsView: TVShowDetailsView)
}

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

	private lazy var seasonsButton = createSeasonsButton()
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.title, isHidden: true)

	weak var delegate: TVShowDetailsViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this view
	init(viewModel: TVShowDetailsViewViewModel) {
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
		headerView = viewModel.setupHeaderView(forView: self)

		addSubviews(tvShowDetailsTableView, seasonsButton)
		tvShowDetailsTableView.delegate = self
		tvShowDetailsTableView.tableHeaderView = headerView

		viewModel.setupTableView(tvShowDetailsTableView)

		seasonsButton.addAction(
			UIAction { [weak self] _ in
				guard let self else { return }
				self.delegate?.didTapSeasonsButton(in: self)
			},
			for: .touchUpInside
		)

		layoutUI()
	}

	private func layoutUI() {
		pinViewToAllEdges(tvShowDetailsTableView)

		NSLayoutConstraint.activate([
			seasonsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			seasonsButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -25),
			seasonsButton.widthAnchor.constraint(equalToConstant: 120),
			seasonsButton.heightAnchor.constraint(equalToConstant: 50)
		])		
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
