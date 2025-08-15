import UIKit

/// Class to represent the tracked tv show details description cell
final class TrackedTVShowDetailsDescriptionCell: MediaDetailsDescriptionCell {
	override
	class var identifier: String {
		return String(describing: self)
	}
}
