import UIKit

@MainActor
protocol TrackedMediaListViewViewModelDelegate: AnyObject {
	func didSelectItem(at indexPath: IndexPath)
}

/// View model struct for `TrackedMediaListView`
@MainActor
final class TrackedMediaListViewViewModel: BaseViewModel<TrackedMediaListCell> {
	weak var delegate: TrackedMediaListViewViewModelDelegate?

	override func awake() {
		viewModels = [
			.init(text: "Currently watching", imageName: "play"),
			.init(text: "Finished", imageName: "checkmark"),
			.init(text: "Rated movies", imageName: "star")
		]
		onCellRegistration = { cell, viewModel in
			cell.configure(with: viewModel)
		}
	}
}

// ! Configurable

final class TrackedMediaListCell: UICollectionViewListCell {}

extension TrackedMediaListCell: Configurable {
	func configure(with viewModel: TrackedMediaListCellViewModel) {
		var content = defaultContentConfiguration()
		content.text = viewModel.text
		content.image = UIImage(systemName: viewModel.imageName)
		content.imageProperties.tintColor = .areeshaPinkColor

		contentConfiguration = content
	}
}

// ! UICollectionViewDelegate

extension TrackedMediaListViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelectItem(at: indexPath)
	}
}
