import UIKit

/// Class to represent the movie details view
final class MovieDetailsView: UIView {
	private let viewModel: MovieDetailsViewViewModel

	@UsesAutoLayout
	private var movieDetailsTableView: UITableView = {
		let tableView = UITableView()
		tableView.allowsSelection = false
		tableView.backgroundColor = .systemBackground
		tableView.register(MovieDetailsKeyInfoCell.self, forCellReuseIdentifier: MovieDetailsKeyInfoCell.identifier)
		tableView.register(MovieDetailsGenreCell.self, forCellReuseIdentifier: MovieDetailsGenreCell.identifier)
		tableView.register(MovieDetailsDescriptionCell.self, forCellReuseIdentifier: MovieDetailsDescriptionCell.identifier)
		tableView.register(MovieDetailsCastCell.self, forCellReuseIdentifier: MovieDetailsCastCell.identifier)
		tableView.register(MovieDetailsProvidersCell.self, forCellReuseIdentifier: MovieDetailsProvidersCell.identifier)
		return tableView
	}()

	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.title, isHidden: true)

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameter viewModel: The view model object for this view
	init(viewModel: MovieDetailsViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)

		setupUI()
	}

	// ! Private

	private func setupUI() {
		addSubview(movieDetailsTableView)
		pinViewToAllEdges(movieDetailsTableView)

		movieDetailsTableView.delegate = self
		movieDetailsTableView.tableHeaderView = viewModel.setupHeaderView(forView: self)
		viewModel.setupTableView(movieDetailsTableView)
	}
}

// ! UITableViewDelegate

extension MovieDetailsView: UITableViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let headerView = movieDetailsTableView.tableHeaderView as? MediaDetailsHeaderView else {
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
