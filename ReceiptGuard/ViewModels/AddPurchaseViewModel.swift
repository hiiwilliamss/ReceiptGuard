import Foundation
import SwiftUI
import PhotosUI

/// Handles form state and saving a new purchase.
@Observable
final class AddPurchaseViewModel {
    var productName = ""
    var store = ""
    var purchaseDate = Date()
    var returnDeadline: Date?
    var warrantyEndDate: Date?
    var notes = ""
    var receiptImageData: Data?
    var selectedPhotoItem: PhotosPickerItem?

    var hasReturnDeadline = false
    var hasWarrantyEndDate = false

    var isValid: Bool {
        !productName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !store.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Load receipt image data from the photo picker selection.
    func loadPhoto() async {
        guard let item = selectedPhotoItem else {
            receiptImageData = nil
            return
        }
        if let data = try? await item.loadTransferable(type: Data.self) {
            receiptImageData = data
        }
    }

    /// Build a Purchase model from current form values.
    func makePurchase() -> Purchase {
        Purchase(
            productName: productName.trimmingCharacters(in: .whitespaces),
            store: store.trimmingCharacters(in: .whitespaces),
            purchaseDate: purchaseDate,
            returnDeadline: hasReturnDeadline ? returnDeadline : nil,
            warrantyEndDate: hasWarrantyEndDate ? warrantyEndDate : nil,
            notes: notes.trimmingCharacters(in: .whitespaces),
            receiptImageData: receiptImageData
        )
    }

    func reset() {
        productName = ""
        store = ""
        purchaseDate = Date()
        returnDeadline = nil
        warrantyEndDate = nil
        notes = ""
        receiptImageData = nil
        selectedPhotoItem = nil
        hasReturnDeadline = false
        hasWarrantyEndDate = false
    }
}
