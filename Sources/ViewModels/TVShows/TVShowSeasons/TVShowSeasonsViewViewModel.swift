import Combine
import UIKit

protocol TVShowSeasonsViewViewModelDelegate: AnyObject {
	func didLoadTVShowSeasons()
	func didSelect(season: Season, from tvShow: TVShow)
}

/// View model class for TVShowSeasonsView
final class TVShowSeasonsViewViewModel: NSObject {

	var title: String { return tvShow.name }

	private let tvShow: TVShow

	private var subscriptions = Set<AnyCancellable>()
	private var viewModels = [TVShowSeasonsCollectionViewCellViewModel]()

	private var seasons = [Season]() {
		didSet {
			for season in seasons {
				let imageURLString = "\(Service.Constants.baseImageURL)w500/\(season.posterPath ?? "")"
				guard let url = URL(string: imageURLString), let seasonName = season.name else { return }
				let viewModel = TVShowSeasonsCollectionViewCellViewModel(imageURL: url, seasonNameText: seasonName)

				if !viewModels.contains(viewModel) && !seasonName.contains("Specials") {
					viewModels.append(viewModel)
				}
			}
		}
	}

	weak var delegate: TVShowSeasonsViewViewModelDelegate?

	/// Designated initializer
	/// - Parameters:
	///     - tvShow: the tv show model object
	init(tvShow: TVShow) {
		self.tvShow = tvShow
		super.init()
		fetchTVShowSeasons()
	}

	// ! Private

	private func fetchTVShowSeasons() {
		let urlString = "\(Service.Constants.baseURL)tv/\(tvShow.id)?api_key=\(Service.Constants.apiKey)"
		guard let url = URL(string: urlString) else { return }	

		Service.sharedInstance.fetchTVShows(withURL: url, expecting: TVShow.self)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] tvShow in
				guard let seasons = tvShow.seasons else { return }
				self?.seasons = seasons.filter { $0[keyPath: \.name!].contains("Specials") == false }
				self?.delegate?.didLoadTVShowSeasons()
			}
			.store(in: &subscriptions)
	}

}

// ! UICollectionView

extension TVShowSeasonsViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModels.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: TVShowSeasonsCollectionViewCell.identifier,
			for: indexPath
		) as? TVShowSeasonsCollectionViewCell else {
			return UICollectionViewCell()
		}
		cell.configure(with: viewModels[indexPath.item])
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		delegate?.didSelect(season: seasons[indexPath.item], from: tvShow)
	}

}
