import UIKit


protocol TopHeaderViewViewModelDelegate: AnyObject {
	func didSelectItemAt(indexPath: IndexPath)
}

/// View model class for TopHeaderView
final class TopHeaderViewViewModel: BaseViewModel<TopHeaderCollectionViewCell> {

	weak var delegate: TopHeaderViewViewModelDelegate?

	/// Function to setup the view model, because for some goddamn reason overriding init doesn't seem to work
	func awake() {
		viewModels = [
			.init(sectionText: "Top rated"),
			.init(sectionText: "Trending")
		]
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
		setupDiffableDataSource()
	}

}

// ! UICollectionViewDelegate

extension TopHeaderViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.didSelectItemAt(indexPath: indexPath)
	}

}
