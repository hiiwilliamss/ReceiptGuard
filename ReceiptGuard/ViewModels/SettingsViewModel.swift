import Foundation

/// Manages settings: API key, AI toggle, and data export.
@Observable
final class SettingsViewModel {
    var apiKey: String = ""
    var aiEnabled: Bool {
        didSet { UserDefaults.standard.set(aiEnabled, forKey: "aiFeaturesEnabled") }
    }
    var saveMessage: String?
    var exportURL: URL?
    var isExporting = false

    init() {
        aiEnabled = UserDefaults.standard.bool(forKey: "aiFeaturesEnabled")
        // Load masked hint if key exists
        if KeychainService.shared.loadAPIKey() != nil {
            apiKey = "" // Don't display the actual key for security
        }
    }

    var hasStoredAPIKey: Bool {
        KeychainService.shared.loadAPIKey() != nil
    }

    func saveAPIKey() {
        let trimmed = apiKey.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            saveMessage = "Please enter an API key."
            return
        }
        do {
            try KeychainService.shared.saveAPIKey(trimmed)
            apiKey = "" // Clear field after saving
            saveMessage = "API key saved securely."
        } catch {
            saveMessage = error.localizedDescription
        }
    }

    func removeAPIKey() {
        do {
            try KeychainService.shared.deleteAPIKey()
            apiKey = ""
            saveMessage = "API key removed."
        } catch {
            saveMessage = error.localizedDescription
        }
    }

    func exportData(purchases: [Purchase]) {
        isExporting = true
        defer { isExporting = false }
        do {
            exportURL = try ExportService.exportFileURL(purchases: purchases)
        } catch {
            saveMessage = "Export failed: \(error.localizedDescription)"
        }
    }
}
