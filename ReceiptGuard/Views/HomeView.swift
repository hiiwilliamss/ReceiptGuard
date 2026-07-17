import SwiftUI
import SwiftData

/// Home screen with upcoming returns, warranties, and expired items.
struct HomeView: View {
    @Query(sort: \Purchase.createdAt, order: .reverse) private var purchases: [Purchase]
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if purchases.isEmpty {
                    ContentUnavailableView(
                        "No Purchases Yet",
                        systemImage: "doc.text",
                        description: Text("Tap Add to save your first purchase and track return deadlines.")
                    )
                } else {
                    List {
                        if !viewModel.upcomingReturns.isEmpty {
                            Section {
                                ForEach(viewModel.upcomingReturns, id: \.id) { purchase in
                                    NavigationLink(value: purchase.id) {
                                        PurchaseCardView(
                                            purchase: purchase,
                                            showReturnDeadline: true,
                                            showWarrantyDeadline: false
                                        )
                                    }
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                Label("Upcoming Returns", systemImage: "arrow.uturn.backward.circle")
                            }
                        }

                        if !viewModel.upcomingWarranties.isEmpty {
                            Section {
                                ForEach(viewModel.upcomingWarranties, id: \.id) { purchase in
                                    NavigationLink(value: purchase.id) {
                                        PurchaseCardView(
                                            purchase: purchase,
                                            showReturnDeadline: false,
                                            showWarrantyDeadline: true
                                        )
                                    }
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                Label("Upcoming Warranties", systemImage: "shield.checkered")
                            }
                        }

                        if !viewModel.expiredItems.isEmpty {
                            Section {
                                ForEach(viewModel.expiredItems, id: \.id) { purchase in
                                    NavigationLink(value: purchase.id) {
                                        PurchaseCardView(
                                            purchase: purchase,
                                            showReturnDeadline: purchase.returnDeadline != nil,
                                            showWarrantyDeadline: purchase.warrantyEndDate != nil
                                        )
                                    }
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                Label("Expired", systemImage: "clock.badge.exclamationmark")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("ReceiptGuard")
            .navigationDestination(for: UUID.self) { purchaseID in
                if let purchase = purchases.first(where: { $0.id == purchaseID }) {
                    PurchaseDetailView(purchase: purchase)
                }
            }
            .onChange(of: purchases) { _, newPurchases in
                viewModel.update(from: newPurchases)
            }
            .onAppear {
                viewModel.update(from: purchases)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Purchase.self, inMemory: true)
}
