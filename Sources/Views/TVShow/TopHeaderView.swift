import UIKit


protocol TopHeaderViewDelegate: AnyObject {
	func topHeaderView(_ topHeaderView: TopHeaderView, didSelectItemAt indexPath: IndexPath)
}

/// Class to display a collection view to switch between top rated & trending TV shows
final class TopHeaderView: UIView {

	@UsesAutoLayout
	private var topHeaderCollectionView: UICollectionView = {
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.minimumInteritemSpacing = 0
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
		collectionView.backgroundColor = .systemBackground
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}()

	@UsesAutoLayout
	private var horizontalScrollingIndicatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .areeshaPinkColor
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 2
		return view
	}()

	@UsesAutoLayout
	private var transparentView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}()

	var collectionView: UICollectionView { topHeaderCollectionView }
	var transparentViewLeadingAnchorConstraint: NSLayoutConstraint!

	weak var delegate: TopHeaderViewDelegate?

	private lazy var viewModel = TopHeaderViewViewModel(collectionView: topHeaderCollectionView)

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		viewModel.awake()
		viewModel.delegate = self
		topHeaderCollectionView.delegate = viewModel

		let selectedIndexPath = IndexPath(item: 0, section: 0)
		topHeaderCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
	}

	// ! Private

	private func setupUI() {
		transparentView.addSubview(horizontalScrollingIndicatorView)
		addSubviews(topHeaderCollectionView, transparentView)
		layoutUI()
	}

	private func layoutUI() {
		pinViewToAllEdges(topHeaderCollectionView)

		transparentViewLeadingAnchorConstraint = transparentView.leadingAnchor.constraint(equalTo: leadingAnchor)
		transparentViewLeadingAnchorConstraint.isActive = true

		transparentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		transparentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 2).isActive = true
		transparentView.heightAnchor.constraint(equalToConstant: 4).isActive = true

		transparentView.pinViewToAllEdges(
			horizontalScrollingIndicatorView,
			leadingConstant: 35,
			trailingConstant: -35
		)
	}

}

// ! TopHeaderViewViewModelDelegate

extension TopHeaderView: TopHeaderViewViewModelDelegate {

	func didSelectItemAt(indexPath: IndexPath) {
		delegate?.topHeaderView(self, didSelectItemAt: indexPath)
	}

}