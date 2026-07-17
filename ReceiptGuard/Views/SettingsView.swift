import SwiftUI
import SwiftData

/// Settings: API key, AI toggle, and JSON export.
struct SettingsView: View {
    @Query(sort: \Purchase.createdAt) private var purchases: [Purchase]
    @State private var viewModel = SettingsViewModel()
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable AI features", isOn: $viewModel.aiEnabled)
                } footer: {
                    Text("When enabled, you can get short AI summaries on purchase detail screens. Only product metadata is sent — never receipt photos.")
                }

                Section("OpenAI API Key") {
                    SecureField("sk-...", text: $viewModel.apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()

                    if viewModel.hasStoredAPIKey {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("API key saved in Keychain")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Save API Key") {
                        viewModel.saveAPIKey()
                    }

                    if viewModel.hasStoredAPIKey {
                        Button("Remove API Key", role: .destructive) {
                            viewModel.removeAPIKey()
                        }
                    }
                }

                Section("Data") {
                    Button {
                        viewModel.exportData(purchases: purchases)
                        if viewModel.exportURL != nil {
                            showShareSheet = true
                        }
                    } label: {
                        HStack {
                            Label("Export as JSON", systemImage: "square.and.arrow.up")
                            if viewModel.isExporting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(purchases.isEmpty)
                } footer: {
                    Text("Exports purchase metadata as a JSON file. Receipt images are not included in the export.")
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Model", value: "GPT-4o mini")
                }
            }
            .navigationTitle("Settings")
            .alert("Settings", isPresented: Binding(
                get: { viewModel.saveMessage != nil },
                set: { if !$0 { viewModel.saveMessage = nil } }
            )) {
                Button("OK") { viewModel.saveMessage = nil }
            } message: {
                Text(viewModel.saveMessage ?? "")
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
}

/// UIKit share sheet wrapper for exporting JSON files.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .modelContainer(for: Purchase.self, inMemory: true)
}
