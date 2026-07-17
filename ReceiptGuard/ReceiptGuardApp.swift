import SwiftUI
import SwiftData

@main
struct ReceiptGuardApp: App {
    /// Shared notification service — requests permission on launch
    @State private var notificationService = NotificationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    notificationService.requestAuthorization()
                }
        }
        .modelContainer(for: Purchase.self)
    }
}
