import UIKit

// https://stackoverflow.com/questions/37102504/proper-naming-convention-for-a-delegate-method-with-no-arguments-except-the-dele
protocol ARTVShowSearchListViewDelegate: AnyObject {
	func didTapCloseButton(in searchTextFieldView: ARSearchTextFieldView)
	func didTapClearButton(in searchTextFieldView: ARSearchTextFieldView)
	func arTVShowSearchListView(_ arTVShowSearchListView: ARTVShowSearchListView, didSelect tvShow: TVShow)
}

/// Class that'll show the searched tv shows in a collection view
final class ARTVShowSearchListView: UIView {

	private lazy var viewModel = ARTVShowSearchListViewViewModel(collectionView: listCollectionView)

	@UsesAutoLayout
	private var searchTextFieldView: ARSearchTextFieldView = {
		let view = ARSearchTextFieldView()
		view.alpha = 0
		view.transform = .init(translationX: 0, y: -50)
		return view
	}()

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
		setupStuff()
		setupUI()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	// ! Private

	private func setupStuff() {
		searchTextFieldView.delegate = self
		searchTextFieldView.textField.delegate = self
		searchTextFieldView.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		viewModel.delegate = self
		listCollectionView.delegate = viewModel
	}

	private func setupUI() {
		addSubviews(searchTextFieldView, listCollectionView)
		Task {
			try await Task.sleep(seconds: 0.20)
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
	 			self.searchTextFieldView.alpha = 1
				self.searchTextFieldView.transform = .init(translationX: 0, y: 0)
			}
		}
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
		UIView.transition(with: searchTextFieldView.clearButton, duration: 0.35, options: .transitionCrossDissolve) {
			self.searchTextFieldView.clearButton.alpha = textField.text?.count ?? 0 > 0 ? 1 : 0	
		}
		guard !textToSearch.isEmpty else { return }
		viewModel.searchQuerySubject.send(textToSearch)
	}

}

extension ARTVShowSearchListView {

	// Public

	/// Function to become the text field's first responder when needed
	func becomeTextFieldFirstResponder() {
		searchTextFieldView.textField.becomeFirstResponder()
	}

	/// Function to resign the text field's first responder when needed
	func resignTextFieldFirstResponder() {
		searchTextFieldView.textField.resignFirstResponder()
	}

}

// ! ARSearchTextFieldViewDelegate

extension ARTVShowSearchListView: ARSearchTextFieldViewDelegate {

	func didTapCloseButton(in searchTextFieldView: ARSearchTextFieldView) {
		delegate?.didTapCloseButton(in: searchTextFieldView)
	}

	func didTapClearButton(in searchTextFieldView: ARSearchTextFieldView) {
		delegate?.didTapClearButton(in: searchTextFieldView)
	}

}

// ! ARTVShowSearchListViewViewModelDelegate

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
