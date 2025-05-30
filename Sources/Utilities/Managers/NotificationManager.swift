import UserNotifications

/// Singleton to manage local notifications
final class NotificationManager {
	static let sharedInstance = NotificationManager()
	private init() {}

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}()
}

// ! Public

extension NotificationManager {
	/// Function to request authorization to send notifications
	func requestAuthorization() {
		Task {
			try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
		}
	}

	/// Async function to post a notification when there's a new episode available for the tracked show
	///
	/// - Parameter for: the `TVShow` object for the episode
	func postNewEpisodeNotification(for show: TVShow) async {
		guard show.nextEpisodeToAir != nil else { return }

		let content = UNMutableNotificationContent()
		content.title = "Areesha"
		content.body = "New episode of \(show.name) is now available on streaming services!"
		content.sound = .default

		guard var notificationDate = NotificationManager.dateFormatter.date(from: show.nextEpisodeToAir?.airDate ?? "") else {
			return
		}

		if notificationDate <= Date() {
			notificationDate = Date().addingTimeInterval(5 * 60)
		}

		let triggerDateComponents = Calendar.current.dateComponents(
			[.year, .month, .day, .hour, .minute, .second],
			from: notificationDate
		)

		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
		let request = UNNotificationRequest(identifier: "nextEpisodeNotification - \(show.name)", content: content, trigger: trigger)

		do {
			try await UNUserNotificationCenter.current().add(request)
		}
		catch {
			NSLog("AREESHA: ❌ something went wrong when trying to schedule the notification: \(error)")
		}
	}

	/// Function to remove any pending notification requests for a given show
	///
	/// - Parameter for: the `TVShow` object
	func removePendingNotificationRequests(for show: TVShow) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(
			withIdentifiers: ["nextEpisodeNotification - \(show.name)"]
		)
	}
}
