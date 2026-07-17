import Foundation
import SwiftData

/// A saved purchase with return and warranty tracking metadata.
@Model
final class Purchase {
    var id: UUID
    var productName: String
    var store: String
    var purchaseDate: Date
    var returnDeadline: Date?
    var warrantyEndDate: Date?
    var notes: String
    /// Receipt photo stored locally — never sent to the LLM
    var receiptImageData: Data?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        productName: String,
        store: String,
        purchaseDate: Date,
        returnDeadline: Date? = nil,
        warrantyEndDate: Date? = nil,
        notes: String = "",
        receiptImageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.productName = productName
        self.store = store
        self.purchaseDate = purchaseDate
        self.returnDeadline = returnDeadline
        self.warrantyEndDate = warrantyEndDate
        self.notes = notes
        self.receiptImageData = receiptImageData
        self.createdAt = createdAt
    }
}
