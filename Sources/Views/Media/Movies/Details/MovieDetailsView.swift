import UIKit

/// Class to represent the movie details view
final class MovieDetailsView: UIView {
	private let viewModel: MovieDetailsViewViewModel

	@UsesAutoLayout
	private var movieDetailsTableView: UITableView = {
		let tableView = UITableView()
		tableView.allowsSelection = false
		tableView.backgroundColor = .systemBackground
		tableView.showsVerticalScrollIndicator = false
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

		let scrollableHeight = headerView.frame.height - safeAreaInsets.top

		headerView.scrollViewDidScroll(scrollView: scrollView)
		headerView.animate(titleLabel: titleLabel, in: scrollView, scrollableHeight: scrollableHeight)
	}
}
