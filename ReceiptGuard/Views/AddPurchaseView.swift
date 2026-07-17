import SwiftUI
import SwiftData
import PhotosUI

/// Form for adding a new purchase with optional receipt photo.
struct AddPurchaseView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AddPurchaseViewModel()
    @State private var notificationService = NotificationService()
    @State private var showSavedAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Product Details") {
                    TextField("Product name", text: $viewModel.productName)
                    TextField("Store", text: $viewModel.store)
                    DatePicker("Purchase date", selection: $viewModel.purchaseDate, displayedComponents: .date)
                }

                Section("Return Deadline") {
                    Toggle("Track return window", isOn: $viewModel.hasReturnDeadline)
                        .onChange(of: viewModel.hasReturnDeadline) { _, enabled in
                            if enabled, viewModel.returnDeadline == nil {
                                viewModel.returnDeadline = Calendar.current.date(byAdding: .day, value: 30, to: viewModel.purchaseDate)
                            }
                        }
                    if viewModel.hasReturnDeadline {
                        DatePicker(
                            "Return by",
                            selection: Binding(
                                get: { viewModel.returnDeadline ?? Calendar.current.date(byAdding: .day, value: 30, to: viewModel.purchaseDate)! },
                                set: { viewModel.returnDeadline = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }

                Section("Warranty") {
                    Toggle("Track warranty", isOn: $viewModel.hasWarrantyEndDate)
                        .onChange(of: viewModel.hasWarrantyEndDate) { _, enabled in
                            if enabled, viewModel.warrantyEndDate == nil {
                                viewModel.warrantyEndDate = Calendar.current.date(byAdding: .year, value: 1, to: viewModel.purchaseDate)
                            }
                        }
                    if viewModel.hasWarrantyEndDate {
                        DatePicker(
                            "Warranty ends",
                            selection: Binding(
                                get: { viewModel.warrantyEndDate ?? Calendar.current.date(byAdding: .year, value: 1, to: viewModel.purchaseDate)! },
                                set: { viewModel.warrantyEndDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Receipt Photo") {
                    PhotosPicker(
                        selection: $viewModel.selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(
                            viewModel.receiptImageData == nil ? "Add receipt photo" : "Change receipt photo",
                            systemImage: "camera.fill"
                        )
                    }
                    .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                        Task { await viewModel.loadPhoto() }
                    }

                    if let data = viewModel.receiptImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .navigationTitle("Add Purchase")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { savePurchase() }
                        .disabled(!viewModel.isValid)
                }
            }
            .alert("Saved!", isPresented: $showSavedAlert) {
                Button("OK") { viewModel.reset() }
            } message: {
                Text("Your purchase has been saved. Reminders will be scheduled if deadlines are set.")
            }
        }
    }

    private func savePurchase() {
        let purchase = viewModel.makePurchase()
        modelContext.insert(purchase)
        notificationService.scheduleNotifications(for: purchase)
        showSavedAlert = true
    }
}

#Preview {
    AddPurchaseView()
        .modelContainer(for: Purchase.self, inMemory: true)
}
