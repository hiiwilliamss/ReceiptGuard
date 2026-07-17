import SwiftUI
import SwiftData

/// Detail screen for a single purchase with AI summary and delete option.
struct PurchaseDetailView: View {
    @Bindable var purchase: Purchase
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PurchaseDetailViewModel()
    @State private var notificationService = NotificationService()
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(purchase.productName)
                        .font(.title2.bold())
                    Text(purchase.store)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Dates
                GroupBox("Dates") {
                    VStack(alignment: .leading, spacing: 12) {
                        dateRow(label: "Purchased", date: purchase.purchaseDate, status: .safe)

                        if let returnDate = purchase.returnDeadline {
                            dateRow(
                                label: "Return deadline",
                                date: returnDate,
                                status: DeadlineStatus.from(date: returnDate)
                            )
                        }

                        if let warrantyDate = purchase.warrantyEndDate {
                            dateRow(
                                label: "Warranty ends",
                                date: warrantyDate,
                                status: DeadlineStatus.from(date: warrantyDate)
                            )
                        }
                    }
                }

                // Notes
                if !purchase.notes.isEmpty {
                    GroupBox("Notes") {
                        Text(purchase.notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Receipt image (stored locally only)
                if let data = purchase.receiptImageData,
                   let uiImage = UIImage(data: data) {
                    GroupBox("Receipt") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // AI helper
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Helper")
                            .font(.headline)

                        if let summary = viewModel.aiSummary {
                            Text(summary)
                                .font(.body)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        if let error = viewModel.aiError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        Button {
                            Task { await viewModel.summarizeOptions(for: purchase) }
                        } label: {
                            HStack {
                                if viewModel.isLoadingAI {
                                    ProgressView()
                                        .controlSize(.small)
                                }
                                Text(viewModel.isLoadingAI ? "Summarizing…" : "Summarize my options")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoadingAI)
                    }
                }

                // Delete
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Purchase", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete this purchase?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deletePurchase() }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            viewModel.aiEnabled = UserDefaults.standard.bool(forKey: "aiFeaturesEnabled")
        }
    }

    // MARK: - Helpers

    private func dateRow(label: String, date: Date, status: DeadlineStatus) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(DateHelpers.formatted(date))
                    .font(.body)
            }
            Spacer()
            DeadlineIndicator(status: status, label: DateHelpers.daysRemaining(until: date))
        }
    }

    private func deletePurchase() {
        notificationService.cancelNotifications(for: purchase)
        modelContext.delete(purchase)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        PurchaseDetailView(
            purchase: Purchase(
                productName: "Coffee Maker",
                store: "Target",
                purchaseDate: .now,
                returnDeadline: Calendar.current.date(byAdding: .day, value: 10, to: .now),
                notes: "Gift receipt included"
            )
        )
    }
    .modelContainer(for: Purchase.self, inMemory: true)
}
