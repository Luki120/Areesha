import UIKit

protocol EpisodesViewDelegate: AnyObject {
	func didShowToastView(in episodesView: EpisodesView)
}

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
		collectionView.delaysContentTouches = false
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

	private lazy var trackedEpisodeToastView = createToastView()
	private lazy var toastViewLabel = createToastViewLabel(withMessage: "Episode tracked.")

	private var noEpisodesLabel: UILabel = .createContentUnavailableLabel(withMessage: "No episodes for this season yet.")
	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.seasonName)

	weak var delegate: EpisodesViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		fatalError("L")
	}

	/// Designated initializer
	/// - Parameters:
	///		- viewModel: The view model object for this view
	init(viewModel: EpisodesViewViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		viewModel.delegate = self
		viewModel.setupCollectionViewDiffableDataSource(for: episodesCollectionView)

		setupUI()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupUI() {
		fetchTVShowImage()
		addSubviews(trackedEpisodeToastView, noEpisodesLabel)
		trackedEpisodeToastView.addSubview(toastViewLabel)
	}

	private func layoutUI() {
		pinViewToSafeAreas(episodesCollectionView)
		pinViewToAllEdges(tvShowImageView)
		tvShowImageView.pinViewToAllEdges(visualEffectView)

		NSLayoutConstraint.activate([
			trackedEpisodeToastView.centerXAnchor.constraint(equalTo: centerXAnchor),
			trackedEpisodeToastView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -25),
			trackedEpisodeToastView.widthAnchor.constraint(equalToConstant: 130),
			trackedEpisodeToastView.heightAnchor.constraint(equalToConstant: 40)
		])

		centerViewOnBothAxes(noEpisodesLabel)
		setupHorizontalConstraints(forView: noEpisodesLabel, leadingConstant: 10, trailingConstant: -10)

		trackedEpisodeToastView.centerViewOnBothAxes(toastViewLabel)
		trackedEpisodeToastView.setupHorizontalConstraints(forView: toastViewLabel, leadingConstant: 10, trailingConstant: -10)
	}

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

extension EpisodesView {

	// ! Public

	/// Function to fade in & out the toast view
	func fadeInOutToastView() {
		animateToastView(trackedEpisodeToastView)
	}

}

// ! EpisodesViewViewModelDelegate

extension EpisodesView: EpisodesViewViewModelDelegate {

	func didShowToastView() {
		delegate?.didShowToastView(in: self)
	}

	func shouldAnimateNoEpisodesLabel(isDataSourceEmpty: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {	
			if isDataSourceEmpty {
				self.noEpisodesLabel.alpha = 1
				self.episodesCollectionView.alpha = 0
			}
			else {
				self.noEpisodesLabel.alpha = 0
				self.episodesCollectionView.alpha = 1
			}
		}
	}

}
