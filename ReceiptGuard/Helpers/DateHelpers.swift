import Foundation

enum DateHelpers {
    /// Human-readable relative description, e.g. "4 days left" or "Expired 2 days ago"
    static func daysRemaining(until date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        if days < 0 {
            let ago = abs(days)
            return ago == 1 ? "Expired 1 day ago" : "Expired \(ago) days ago"
        }
        if days == 0 { return "Due today" }
        if days == 1 { return "1 day left" }
        return "\(days) days left"
    }

    /// Short formatted date for cards and lists
    static func formatted(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
