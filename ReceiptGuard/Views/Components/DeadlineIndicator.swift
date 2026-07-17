import SwiftUI

/// Colored dot + label showing deadline urgency.
struct DeadlineIndicator: View {
    let status: DeadlineStatus
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
