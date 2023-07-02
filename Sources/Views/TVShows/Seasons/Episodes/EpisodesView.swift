import UIKit

/// Class to represent the episodes view
final class EpisodesView: UIView {

	private let viewModel: EpisodesViewViewModel

	private let compositionalLayout: UICollectionViewCompositionalLayout = {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(160))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(160))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
		section.interGroupSpacing = 15

		return UICollectionViewCompositionalLayout(section: section)
	}()

	private lazy var episodesCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
		collectionView.delegate = viewModel
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		return collectionView
	}()

	private lazy var tvShowImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(imageView, at: 0)
		return imageView
	}()

	private lazy var visualEffectView: UIVisualEffectView = {
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
		visualEffectView.clipsToBounds = true
		visualEffectView.translatesAutoresizingMaskIntoConstraints = false
		tvShowImageView.addSubview(visualEffectView)
		return visualEffectView
	}()

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.text = viewModel.seasonName
		label.numberOfLines = 0
		return label
	}()

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///     - viewModel: The view model object for this view
	init(viewModel: EpisodesViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		viewModel.setupCollectionViewDiffableDataSource(for: episodesCollectionView)
		fetchTVShowImage()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToSafeAreas(episodesCollectionView)
		pinViewToAllEdges(tvShowImageView)
		tvShowImageView.pinViewToAllEdges(visualEffectView)
	}

	// ! Private

	private func fetchTVShowImage() {
		viewModel.fetchTVShowImage { [weak self] image in
			guard let self else { return }

			await MainActor.run {
				UIView.transition(with: self.tvShowImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowImageView.image = image
				}
			}
		}
	}

}
