import SwiftUI

/// Visual urgency level for a deadline date.
enum DeadlineStatus {
    case expired
    case urgent      // 1–3 days
    case warning     // 4–7 days
    case safe        // 8+ days
    case none        // no deadline set

    /// Derive status from a target date relative to today.
    static func from(date: Date?) -> DeadlineStatus {
        guard let date else { return .none }
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        if days < 0 { return .expired }
        if days <= 3 { return .urgent }
        if days <= 7 { return .warning }
        return .safe
    }

    var color: Color {
        switch self {
        case .expired: return .red
        case .urgent:  return .orange
        case .warning: return .yellow
        case .safe:    return .green
        case .none:    return .secondary
        }
    }

    var label: String {
        switch self {
        case .expired: return "Expired"
        case .urgent:  return "Urgent"
        case .warning: return "Soon"
        case .safe:    return "OK"
        case .none:    return "—"
        }
    }
}
