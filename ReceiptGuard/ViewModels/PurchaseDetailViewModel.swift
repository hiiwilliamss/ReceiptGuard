import Foundation

/// Manages AI summary state for a single purchase detail screen.
@Observable
final class PurchaseDetailViewModel {
    var aiSummary: String?
    var isLoadingAI = false
    var aiError: String?
    var aiEnabled = UserDefaults.standard.bool(forKey: "aiFeaturesEnabled")

    /// Request a short AI summary — only sends metadata, never receipt images.
    func summarizeOptions(for purchase: Purchase) async {
        guard aiEnabled else {
            aiError = "AI features are disabled. Enable them in Settings."
            return
        }

        isLoadingAI = true
        aiError = nil
        defer { isLoadingAI = false }

        do {
            aiSummary = try await LLMService.shared.summarizeOptions(for: purchase)
        } catch {
            aiSummary = nil
            aiError = error.localizedDescription
        }
    }

    func clearSummary() {
        aiSummary = nil
        aiError = nil
    }
}
