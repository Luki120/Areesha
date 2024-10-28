import UIKit

// https://stackoverflow.com/questions/37102504/proper-naming-convention-for-a-delegate-method-with-no-arguments-except-the-dele
protocol TVShowSearchListViewDelegate: AnyObject {
	func didTapCloseButton(in searchTextFieldView: SearchTextFieldView)
	func didTapClearButton(in searchTextFieldView: SearchTextFieldView)
	func tvShowSearchListView(_ tvShowSearchListView: TVShowSearchListView, didSelect tvShow: TVShow)
}

/// Class that'll show the searched tv shows in a collection view
final class TVShowSearchListView: UIView {

	private lazy var viewModel = TVShowSearchListViewViewModel(collectionView: listCollectionView)

	@UsesAutoLayout
	private var searchTextFieldView: SearchTextFieldView = {
		let view = SearchTextFieldView()
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

	private var noResultsLabel: UILabel = .createContentUnavailableLabel(withMessage: "No results were found for this query.")

	weak var delegate: TVShowSearchListViewDelegate?

	// ! Lifecycle

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupDelegates()
		addSubviews(searchTextFieldView, listCollectionView, noResultsLabel)
		layoutUI()
	}

	// ! Private

	private func setupDelegates() {
		searchTextFieldView.delegate = self
		searchTextFieldView.textField.delegate = self
		searchTextFieldView.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		viewModel.delegate = self
		listCollectionView.delegate = viewModel
	}

	private func layoutUI() {
		searchTextFieldView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
		searchTextFieldView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
		searchTextFieldView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true

		listCollectionView.topAnchor.constraint(equalTo: searchTextFieldView.bottomAnchor, constant: 15).isActive = true
		listCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
		listCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		listCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

		centerViewOnBothAxes(noResultsLabel)
		setupHorizontalConstraints(forView: noResultsLabel, leadingConstant: 10, trailingConstant: -10)
	}

	// ! Selectors

	@objc
	private func textFieldDidChange(_ textField: UITextField) {
		let textToSearch = textField.text!.trimmingCharacters(in: .newlines)
		UIView.transition(with: searchTextFieldView.clearButton, duration: 0.35, options: .transitionCrossDissolve) {
			self.searchTextFieldView.clearButton.alpha = textField.text?.count ?? 0 > 0 ? 1 : 0	
		}
		guard !textToSearch.isEmpty else { return }
		viewModel.sendQuerySubject(textToSearch)
	}

}

extension TVShowSearchListView {

	// Public

	/// Function to become the text field's first responder when needed
	func becomeTextFieldFirstResponder() {
		searchTextFieldView.textField.becomeFirstResponder()
	}

	/// Function to resign the text field's first responder when needed
	func resignTextFieldFirstResponder() {
		searchTextFieldView.textField.resignFirstResponder()
	}

	/// Function to fade in the text field when the view appears
	func fadeInTextField() {
		Task {
			try await Task.sleep(seconds: 0.20)
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
				self.searchTextFieldView.alpha = 1
				self.searchTextFieldView.transform = .init(translationX: 0, y: 0)
			}
		}
	}

	/// Function to fade out the text field when the view disappears
	func fadeOutTextField() {
		Task {
			try await Task.sleep(seconds: 0.05)
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1) {
				self.searchTextFieldView.alpha = 0
				self.searchTextFieldView.transform = .init(translationX: 0, y: -50)
			}
		}
	}

}

// ! SearchTextFieldViewDelegate

extension TVShowSearchListView: SearchTextFieldViewDelegate {

	func didTapCloseButton(in searchTextFieldView: SearchTextFieldView) {
		delegate?.didTapCloseButton(in: searchTextFieldView)
	}

	func didTapClearButton(in searchTextFieldView: SearchTextFieldView) {
		delegate?.didTapClearButton(in: searchTextFieldView)
	}

}

// ! TVShowSearchListViewViewModelDelegate

extension TVShowSearchListView: TVShowSearchListViewViewModelDelegate {

	func didSelect(tvShow: TVShow) {
		delegate?.tvShowSearchListView(self, didSelect: tvShow)
	}

	func shouldAnimateNoResultsLabel(isDataSourceEmpty: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {	
			if isDataSourceEmpty {
				self.noResultsLabel.alpha = 1
				self.listCollectionView.alpha = 0
			}
			else {
				self.noResultsLabel.alpha = 0
				self.listCollectionView.alpha = 1
			}
		}
	}

}

// ! UITextFieldDelegate

extension TVShowSearchListView: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchTextFieldView.textField.resignFirstResponder()
		return true
	}

}
