# Insight Banking iOS Prototype (SwiftUI)

This prototype includes:

- Login screen with dummy credentials.
- Account list (savings / debit / credit).
- Account detail screen with date-grouped transactions and category labels.
- Monthly category expense chart.
- JSON-backed dummy data source.
- LLM-ready AI insights service for unusual spend detection, next-month projection, savings tips, and investment tips.

## Demo Credentials

- `demo.user` / `Pass@123`

## Project Structure

- `Sources/InsightBankingPrototype/Views` – SwiftUI views
- `Sources/InsightBankingPrototype/ViewModels` – session + state orchestration
- `Sources/InsightBankingPrototype/Services` – data loading + AI insight module
- `Sources/InsightBankingPrototype/Models` – app domain models
- `Sources/InsightBankingPrototype/Data/banking_data.json` – diverse mock data

## AI Module Integration Notes

`AIInsightsService` is built around the `LLMClient` protocol.
To integrate a real LLM provider, implement:

```swift
struct RealLLMClient: LLMClient {
    func complete(prompt: String) -> String {
        // 1) call provider SDK/API
        // 2) return parsed text output
    }
}
```

Then inject into `SessionViewModel`:

```swift
SessionViewModel(aiService: AIInsightsService(llmClient: RealLLMClient()))
```

This keeps the view layer unchanged and makes the AI module portable.
