import UIKit

@MainActor
protocol TopHeaderViewViewModelDelegate: AnyObject {
	func didSelectItem(at indexPath: IndexPath)
}

/// View model class for `TopHeaderView`
@MainActor
final class TopHeaderViewViewModel: BaseViewModel<TopHeaderCell> {
	weak var delegate: TopHeaderViewViewModelDelegate?

	override func awake() {
		viewModels = [
			.init(sectionName: "Top rated"),
			.init(sectionName: "Trending")
		]
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
	}
}

// ! UICollectionViewDelegate

extension TopHeaderViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.didSelectItem(at: indexPath)
	}
}
