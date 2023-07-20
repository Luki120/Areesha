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

	private lazy var trackedEpisodeToastView: UIView = {
		let view = UIView()
		view.alpha = 0
		view.transform = .init(scaleX: 0.1, y: 0.1)
		view.backgroundColor = .areeshaPinkColor
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 20
		view.layer.shadowColor = UIColor.label.cgColor
		view.layer.shadowOffset = .init(width: 0, height: 0.5)
		view.layer.shadowOpacity = 0.2
		view.layer.shadowRadius = 4
		episodesCollectionView.addSubview(view)
		return view
	}()

	private lazy var toastViewLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14)
		label.text = "Episode tracked."
		label.textColor = .label
		label.numberOfLines = 0
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		trackedEpisodeToastView.addSubview(label)
		return label
	}()

	private(set) lazy var titleLabel: UILabel = .createTitleLabel(withTitle: viewModel.seasonName)

	weak var delegate: EpisodesViewDelegate?

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
		viewModel.delegate = self
		viewModel.setupCollectionViewDiffableDataSource(for: episodesCollectionView)
		fetchTVShowImage()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		pinViewToSafeAreas(episodesCollectionView)
		pinViewToAllEdges(tvShowImageView)
		tvShowImageView.pinViewToAllEdges(visualEffectView)

		NSLayoutConstraint.activate([
			trackedEpisodeToastView.centerXAnchor.constraint(equalTo: centerXAnchor),
			trackedEpisodeToastView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -25),
			trackedEpisodeToastView.widthAnchor.constraint(equalToConstant: 130),
			trackedEpisodeToastView.heightAnchor.constraint(equalToConstant: 40)
		])

		trackedEpisodeToastView.centerViewOnBothAxes(toastViewLabel)
		trackedEpisodeToastView.setupHorizontalConstraints(forView: toastViewLabel, leadingConstant: 10, trailingConstant: -10)
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

extension EpisodesView {

	// ! Public

	/// Function to fade in & out the toast view
	func fadeInOutToastView() {
 		UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
			self.trackedEpisodeToastView.alpha = 1
			self.trackedEpisodeToastView.transform = .init(scaleX: 1, y: 1)

			Task {
				try await Task.sleep(seconds: 2)
				UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
					self.trackedEpisodeToastView.alpha = 0
					self.trackedEpisodeToastView.transform = .init(scaleX: 0.1, y: 0.1)
				}
			}
		}
	}

}

// ! EpisodesViewViewModelDelegate

extension EpisodesView: EpisodesViewViewModelDelegate {

	func didShowToastView() {
		delegate?.didShowToastView(in: self)
	}

}
