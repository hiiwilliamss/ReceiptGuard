import Foundation
import UserNotifications

/// Schedules local reminders 7, 3, and 1 day(s) before return/warranty deadlines.
@Observable
final class NotificationService {
    private let center = UNUserNotificationCenter.current()

    /// Days before a deadline to fire reminders
    private let reminderOffsets = [7, 3, 1]

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Schedule all reminders for a purchase's return and warranty dates.
    func scheduleNotifications(for purchase: Purchase) {
        cancelNotifications(for: purchase)

        if let returnDate = purchase.returnDeadline {
            scheduleReminders(
                for: purchase,
                date: returnDate,
                type: "return",
                title: "Return deadline approaching",
                bodyPrefix: "Return window for \(purchase.productName) at \(purchase.store)"
            )
        }

        if let warrantyDate = purchase.warrantyEndDate {
            scheduleReminders(
                for: purchase,
                date: warrantyDate,
                type: "warranty",
                title: "Warranty expiring soon",
                bodyPrefix: "Warranty for \(purchase.productName) at \(purchase.store)"
            )
        }
    }

    func cancelNotifications(for purchase: Purchase) {
        let identifiers = reminderOffsets.flatMap { offset in
            [
                notificationID(purchaseID: purchase.id, type: "return", offset: offset),
                notificationID(purchaseID: purchase.id, type: "warranty", offset: offset)
            ]
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Private

    private func scheduleReminders(
        for purchase: Purchase,
        date: Date,
        type: String,
        title: String,
        bodyPrefix: String
    ) {
        let calendar = Calendar.current

        for offset in reminderOffsets {
            guard let triggerDate = calendar.date(byAdding: .day, value: -offset, to: date),
                  triggerDate > .now else { continue }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = "\(bodyPrefix) ends in \(offset) day\(offset == 1 ? "" : "s")."
            content.sound = .default

            var components = calendar.dateComponents([.year, .month, .day], from: triggerDate)
            components.hour = 9 // 9 AM local time

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationID(purchaseID: purchase.id, type: type, offset: offset),
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    private func notificationID(purchaseID: UUID, type: String, offset: Int) -> String {
        "\(purchaseID.uuidString)-\(type)-\(offset)"
    }
}
