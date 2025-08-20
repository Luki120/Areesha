import Combine
import UIKit.NSParagraphStyle
import UIKit.UIColor

extension Array {
	func insertionIndex(of element: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
		var low = 0
		var high = self.count - 1

		while low <= high {
			let mid = (low + high) / 2

			if isOrderedBefore(self[mid], element) {
				low = mid + 1
			}
			else if isOrderedBefore(element, self[mid]) {
				high = mid - 1
			}
			else {
				return mid
			}
		}
		return low
	}
}

extension Double {
	func round(to places: Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return Darwin.round(self * divisor) / divisor
	}
}

extension NSMutableAttributedString {
	convenience init(fullString: String, fullStringColor: UIColor, subString: String, subStringColor: UIColor) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.paragraphSpacing = -1.5

		attributedString.addAttribute(.foregroundColor, value: fullStringColor, range: rangeOfFullString)
		attributedString.addAttribute(.foregroundColor, value: subStringColor, range: rangeOfSubString)
		attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: rangeOfFullString)

		self.init(attributedString: attributedString)
	}

	convenience init(fullString: String, subString: String) {
		let rangeOfSubString = (fullString as NSString).range(of: subString)
		let rangeOfFullString = NSRange(location: 0, length: fullString.count)
		let attributedString = NSMutableAttributedString(string: fullString)

		attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: rangeOfFullString)
		attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray, range: rangeOfSubString)
		attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .callout), range: rangeOfFullString)
		attributedString.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .caption2, size: 10), range: rangeOfSubString)

		self.init(attributedString: attributedString)
	}
}

extension Publisher {
	func async() async throws -> Output where Output: Sendable {
		try await withCheckedThrowingContinuation { continuation in
			var cancellable: AnyCancellable?
			cancellable = first()
				.sink(receiveCompletion: { completion in
					switch completion {
						case .finished: break
						case .failure(let error): continuation.resume(throwing: error)
					}
					cancellable?.cancel()
				}) { value in
					continuation.resume(returning: value)
					cancellable?.cancel()
				}
		}
	}
}

extension Task where Success == Never, Failure == Never {
	static func sleep(seconds: Double) async throws {
		let nanoseconds = UInt64(seconds * 1_000_000_000)
		try await Task.sleep(nanoseconds: nanoseconds)
	}
}
