import UIKit

/// Class to represent the episodes view
final class EpisodesView: UIView {

	let viewModel: EpisodesViewViewModel

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

	@UsesAutoLayout
	private var tvShowImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()

	@UsesAutoLayout
	private var visualEffectView: UIVisualEffectView = {
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
		visualEffectView.clipsToBounds = true
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
	///     - viewModel: the view model object for this view
	init(viewModel: EpisodesViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		viewModel.setupCollectionViewDiffableDataSource(for: episodesCollectionView)
		insertSubview(tvShowImageView, at: 0)
		tvShowImageView.addSubview(visualEffectView)
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
		Task.detached(priority: .background) {
			let imageURLString = "\(Service.Constants.baseImageURL)w1280/\(self.viewModel.tvShow.posterPath ?? "")"
			guard let imageURL = URL(string: imageURLString) else { return }

			let image = try? await ImageManager.sharedInstance.fetchImageAsync(imageURL)
			await MainActor.run {
				UIView.transition(with: self.tvShowImageView, duration: 0.5, options: .transitionCrossDissolve) {
					self.tvShowImageView.image = image
				}
			}
		}
	}

}
