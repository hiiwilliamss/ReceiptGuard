import Foundation

/// Exports purchase data as JSON for backup or transfer.
struct ExportService {
    /// Codable snapshot of a purchase (without binary receipt data for portability)
    struct PurchaseExport: Codable {
        let id: UUID
        let productName: String
        let store: String
        let purchaseDate: Date
        let returnDeadline: Date?
        let warrantyEndDate: Date?
        let notes: String
        let hasReceiptImage: Bool
        let createdAt: Date
    }

    static func exportJSON(purchases: [Purchase]) throws -> Data {
        let exports = purchases.map { purchase in
            PurchaseExport(
                id: purchase.id,
                productName: purchase.productName,
                store: purchase.store,
                purchaseDate: purchase.purchaseDate,
                returnDeadline: purchase.returnDeadline,
                warrantyEndDate: purchase.warrantyEndDate,
                notes: purchase.notes,
                hasReceiptImage: purchase.receiptImageData != nil,
                createdAt: purchase.createdAt
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(exports)
    }

    static func exportFileURL(purchases: [Purchase]) throws -> URL {
        let data = try exportJSON(purchases: purchases)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ReceiptGuard-Export-\(ISO8601DateFormatter().string(from: .now)).json")
        try data.write(to: url)
        return url
    }
}
