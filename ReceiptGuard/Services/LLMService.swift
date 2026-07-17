import Foundation

/// Sends purchase metadata to OpenAI GPT-4o mini for a short action summary.
/// Receipt images are never included — only typed fields.
final class LLMService {
    static let shared = LLMService()

    private let model = "gpt-4o-mini"
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    private init() {}

    /// Generate a brief, practical summary of return/warranty options.
    func summarizeOptions(for purchase: Purchase) async throws -> String {
        guard let apiKey = KeychainService.shared.loadAPIKey(), !apiKey.isEmpty else {
            throw LLMError.noAPIKey
        }

        let prompt = buildPrompt(for: purchase)
        let body: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant for tracking purchase returns and warranties. Give a short, practical summary in 2-3 sentences. Be direct and actionable. Do not use bullet points."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 120,
            "temperature": 0.3
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.apiError(statusCode: httpResponse.statusCode, message: message)
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty else {
            throw LLMError.emptyResponse
        }
        return content
    }

    /// Build a compact prompt using only metadata — no images.
    private func buildPrompt(for purchase: Purchase) -> String {
        var lines = [
            "Product: \(purchase.productName)",
            "Store: \(purchase.store)",
            "Purchase date: \(DateHelpers.formatted(purchase.purchaseDate))"
        ]

        if let returnDate = purchase.returnDeadline {
            lines.append("Return deadline: \(DateHelpers.formatted(returnDate)) (\(DateHelpers.daysRemaining(until: returnDate)))")
        } else {
            lines.append("Return deadline: not set")
        }

        if let warrantyDate = purchase.warrantyEndDate {
            lines.append("Warranty end: \(DateHelpers.formatted(warrantyDate)) (\(DateHelpers.daysRemaining(until: warrantyDate)))")
        } else {
            lines.append("Warranty end: not set")
        }

        if !purchase.notes.isEmpty {
            lines.append("Notes: \(purchase.notes)")
        }

        lines.append("Summarize what the user should do next regarding returns and warranty.")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Response Models

private struct OpenAIResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String?
    }
}

enum LLMError: LocalizedError {
    case noAPIKey
    case invalidResponse
    case emptyResponse
    case apiError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No OpenAI API key found. Add one in Settings to use AI features."
        case .invalidResponse:
            return "Received an invalid response from OpenAI."
        case .emptyResponse:
            return "OpenAI returned an empty summary."
        case .apiError(let code, let message):
            return "OpenAI error (\(code)): \(message)"
        }
    }
}
