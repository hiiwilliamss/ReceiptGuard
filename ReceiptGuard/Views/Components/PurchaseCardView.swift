import SwiftUI

/// Reusable card showing a purchase with deadline indicators.
struct PurchaseCardView: View {
    let purchase: Purchase
    var showReturnDeadline = true
    var showWarrantyDeadline = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(purchase.productName)
                        .font(.headline)
                    Text(purchase.store)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if showReturnDeadline, let returnDate = purchase.returnDeadline {
                let status = DeadlineStatus.from(date: returnDate)
                HStack {
                    DeadlineIndicator(
                        status: status,
                        label: "Return: \(DateHelpers.daysRemaining(until: returnDate))"
                    )
                    Spacer()
                    Text(DateHelpers.formatted(returnDate))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            if showWarrantyDeadline, let warrantyDate = purchase.warrantyEndDate {
                let status = DeadlineStatus.from(date: warrantyDate)
                HStack {
                    DeadlineIndicator(
                        status: status,
                        label: "Warranty: \(DateHelpers.daysRemaining(until: warrantyDate))"
                    )
                    Spacer()
                    Text(DateHelpers.formatted(warrantyDate))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PurchaseCardView(
        purchase: Purchase(
            productName: "Wireless Headphones",
            store: "Best Buy",
            purchaseDate: .now,
            returnDeadline: Calendar.current.date(byAdding: .day, value: 5, to: .now),
            warrantyEndDate: Calendar.current.date(byAdding: .year, value: 1, to: .now)
        ),
        showReturnDeadline: true,
        showWarrantyDeadline: true
    )
    .padding()
}
