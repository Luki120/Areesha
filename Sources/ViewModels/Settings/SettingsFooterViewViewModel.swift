import Foundation
import UIKit.UIImage

/// View model struct for `SettingsFooterView`
@MainActor
struct SettingsFooterViewViewModel {
	let image: UIImage!
	let fullString, subString, urlString: String
}
