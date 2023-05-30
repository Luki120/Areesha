import UIKit


protocol TopHeaderViewViewModelDelegate: AnyObject {
	func didSelectItemAt(indexPath: IndexPath)
}

/// View model class for TopHeaderView
final class TopHeaderViewViewModel: BaseViewModel<TopHeaderCollectionViewCell> {

	weak var delegate: TopHeaderViewViewModelDelegate?

	override func awake() {
		viewModels = [
			.init(sectionText: "Top rated"),
			.init(sectionText: "Trending")
		]
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
	}

}

// ! UICollectionViewDelegate

extension TopHeaderViewViewModel: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.didSelectItemAt(indexPath: indexPath)
	}

}
