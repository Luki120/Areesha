import UIKit

// https://stackoverflow.com/questions/37102504/proper-naming-convention-for-a-delegate-method-with-no-arguments-except-the-dele
protocol ARTVShowSearchListViewDelegate: AnyObject {
	func didTapCloseButtonInTVShowSearchListView()
	func arTVShowSearchListView(_ arTVShowSearchListView: ARTVShowSearchListView, didSelect tvShow: TVShow)
}

/// Class that'll show the searched tv shows in a collection view
final class ARTVShowSearchListView: UIView {

	private let viewModel = ARTVShowSearchListViewViewModel()

	@UsesAutoLayout
	private var searchTextFieldView = ARSearchTextFieldView()

	@UsesAutoLayout
	private var listCollectionView: UICollectionView = {
		let layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
		let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
		collectionView.backgroundColor = .systemBackground
		return collectionView
	}()

	weak var delegate: ARTVShowSearchListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		searchTextFieldView.delegate = self
		searchTextFieldView.textField.delegate = self
		searchTextFieldView.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		viewModel.setupCollectionViewDiffableDataSource(listCollectionView)
		viewModel.delegate = self
		setupUI()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupUI() {
		listCollectionView.delegate = viewModel
		addSubviews(searchTextFieldView, listCollectionView)
	}

	private func layoutUI() {
		searchTextFieldView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
		searchTextFieldView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
		searchTextFieldView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true

		listCollectionView.topAnchor.constraint(equalTo: searchTextFieldView.bottomAnchor, constant: 15).isActive = true
		listCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
		listCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		listCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
	}

	// ! Selectors

	@objc
	private func textFieldDidChange(_ textField: UITextField) {
		let textToSearch = textField.text!.trimmingCharacters(in: .newlines)
		guard !textToSearch.isEmpty else { return }
		viewModel.searchQuerySubject.send(textToSearch)
	}

}

// ! ARSearchTextFieldViewDelegate

extension ARTVShowSearchListView: ARSearchTextFieldViewDelegate {

	func didTapCloseButtonInSearchTextFieldView() {
		delegate?.didTapCloseButtonInTVShowSearchListView()
	}

}

extension ARTVShowSearchListView: ARTVShowSearchListViewViewModelDelegate {
	func didSelect(tvShow: TVShow) {
		delegate?.arTVShowSearchListView(self, didSelect: tvShow)
	}
}

// ! UITextFieldDelegate

extension ARTVShowSearchListView: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchTextFieldView.textField.resignFirstResponder()
		return true
	}

}
