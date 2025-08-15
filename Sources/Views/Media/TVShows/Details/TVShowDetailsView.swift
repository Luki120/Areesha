import UIKit

@MainActor
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
		tableView.register(TVShowDetailsGenreCell.self, forCellReuseIdentifier: TVShowDetailsGenreCell.identifier)
		tableView.register(MediaDetailsDescriptionCell.self, forCellReuseIdentifier: MediaDetailsDescriptionCell.identifier)
		tableView.register(MediaDetailsCastCell.self, forCellReuseIdentifier: MediaDetailsCastCell.identifier)
		tableView.register(MediaDetailsProvidersCell.self, forCellReuseIdentifier: MediaDetailsProvidersCell.identifier)
		return tableView
	}()

	private lazy var seasonsButton = createRoundedButton { [weak self] in
		guard let self else { return }
		self.delegate?.didTapSeasonsButton(in: self)
	}

	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.title, isHidden: true)

	weak var delegate: TVShowDetailsViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this view
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
		layoutUI()
	}

	private func layoutUI() {
		pinViewToAllEdges(tvShowDetailsTableView)
		pinRoundedButton(seasonsButton)
	}
}

// ! Public

extension TVShowDetailsView {
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

extension TVShowDetailsView: UITableViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let headerView = tvShowDetailsTableView.tableHeaderView as? TVShowDetailsHeaderView else {
			return
		}

		headerView.scrollViewDidScroll(scrollView: scrollView)

		let kScrollableHeight = headerView.frame.size.height - safeAreaInsets.top
		let scrolledEnough = scrollView.contentOffset.y > kScrollableHeight

		UIView.animate(withDuration: 0.35, delay: 0, options: scrolledEnough ? .curveEaseIn : .curveEaseOut) {
			self.titleLabel.alpha = scrolledEnough ? 1 : 0
			if scrolledEnough { self.titleLabel.isHidden = false }

			headerView.roundedBlurredButtons.forEach {
				$0.setupStyles(for: .header(status: scrolledEnough))
			}
		} completion: { isFinished in
			guard UIDevice.current.hasDynamicIsland else { return }

			if isFinished && !scrolledEnough {
				self.titleLabel.isHidden = true
			}
		}
	}
}
