import Foundation
import SwiftData

/// Groups purchases for the home screen sections.
@Observable
final class HomeViewModel {
    var upcomingReturns: [Purchase] = []
    var upcomingWarranties: [Purchase] = []
    var expiredItems: [Purchase] = []

    /// Recompute all sections from the current purchase list.
    func update(from purchases: [Purchase]) {
        let today = Calendar.current.startOfDay(for: .now)

        upcomingReturns = purchases
            .filter { purchase in
                guard let deadline = purchase.returnDeadline else { return false }
                return deadline >= today
            }
            .sorted { ($0.returnDeadline ?? .distantFuture) < ($1.returnDeadline ?? .distantFuture) }

        upcomingWarranties = purchases
            .filter { purchase in
                guard let warranty = purchase.warrantyEndDate else { return false }
                return warranty >= today
            }
            .sorted { ($0.warrantyEndDate ?? .distantFuture) < ($1.warrantyEndDate ?? .distantFuture) }

        expiredItems = purchases
            .filter { purchase in
                let returnExpired = purchase.returnDeadline.map { $0 < today } ?? false
                let warrantyExpired = purchase.warrantyEndDate.map { $0 < today } ?? false
                return returnExpired || warrantyExpired
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
}
