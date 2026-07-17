# ReceiptGuard

A simple AI-powered iOS app for tracking purchase return deadlines and warranty expiration dates. Never miss a return window again.

## Features

- **Home dashboard** — Upcoming returns, upcoming warranties, and expired items in separate sections
- **Add purchases** — Product name, store, dates, notes, and receipt photo (stored locally)
- **Deadline indicators** — Green / yellow / orange / red status based on days remaining
- **Local notifications** — Reminders 7, 3, and 1 day(s) before return and warranty deadlines
- **AI helper** — Optional GPT-4o mini summaries of what action to take next (metadata only, no receipt images sent)
- **Settings** — Secure API key storage (Keychain), AI toggle, JSON export

## Requirements

- macOS with **Xcode 15+**
- iOS **17.0+** (SwiftData, `@Observable`)
- iPhone or iPad Simulator (or physical device)
- OpenAI API key (optional, for AI features)

## Project Structure

```
ReceiptGuard/
├── ReceiptGuardApp.swift       # App entry point + SwiftData container
├── Models/
│   └── Purchase.swift          # SwiftData model
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── AddPurchaseViewModel.swift
│   ├── PurchaseDetailViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── ContentView.swift       # Tab navigation
│   ├── HomeView.swift
│   ├── AddPurchaseView.swift
│   ├── PurchaseDetailView.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── PurchaseCardView.swift
│       └── DeadlineIndicator.swift
├── Services/
│   ├── LLMService.swift        # OpenAI GPT-4o mini integration
│   ├── NotificationService.swift
│   ├── KeychainService.swift
│   └── ExportService.swift
└── Helpers/
    ├── DeadlineStatus.swift
    └── DateHelpers.swift
```

Architecture: **MVVM** with SwiftUI and SwiftData.

## Setup Instructions

### 1. Open the project

1. Copy or clone this folder to your Mac.
2. Open `ReceiptGuard.xcodeproj` in Xcode.
3. Select the **ReceiptGuard** scheme and an iPhone simulator (e.g. iPhone 15).
4. Press **⌘R** to build and run.

> **Note:** This project was created on Windows. You need a Mac with Xcode to build and run it. All source files and the Xcode project are included and ready to open.

### 2. Configure signing (if needed)

1. Select the **ReceiptGuard** target in Xcode.
2. Go to **Signing & Capabilities**.
3. Choose your **Team** (Apple ID is fine for Simulator).
4. Xcode will manage signing automatically.

### 3. Run in Simulator

The app works fully in the Simulator except:

- **Notifications** — Allow notifications when prompted; they will appear in the Simulator.
- **Photo picker** — Works in Simulator with sample photos from the simulated library.

## Adding Your OpenAI API Key

AI features are **optional**. The app works without an API key for tracking and notifications.

1. Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys).
2. Open the app → **Settings** tab.
3. Toggle **Enable AI features** on.
4. Paste your key in **OpenAI API Key** (starts with `sk-`).
5. Tap **Save API Key**.

The key is stored in the **iOS Keychain**, not in UserDefaults or the app bundle.

### Using AI summaries

1. Open any purchase from the **Home** tab.
2. Tap **Summarize my options**.
3. A short 2–3 sentence summary appears based on product name, store, dates, and notes only.

**Privacy:** Receipt images are never sent to OpenAI. Only typed metadata is included in the prompt.

### Estimated cost

The app uses **GPT-4o mini** with `max_tokens: 120` and short prompts. Typical summaries cost a fraction of a cent per request.

## Local Notifications

When you save a purchase with return or warranty dates, the app schedules local notifications at:

- **7 days** before the deadline
- **3 days** before
- **1 day** before

Notifications fire at **9:00 AM** local time. Allow notifications when the app first launches.

## Export Data

**Settings → Export as JSON** creates a file with all purchase metadata (receipt images are not included). Use the share sheet to save to Files, AirDrop, etc.

## Deadline Colors

| Color  | Meaning              |
|--------|----------------------|
| Green  | 8+ days remaining    |
| Yellow | 4–7 days remaining   |
| Orange | 1–3 days remaining   |
| Red    | Expired              |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Build fails on open | Ensure Xcode 15+ and iOS 17 deployment target |
| AI says "No API key" | Add key in Settings and enable AI features |
| Notifications not showing | Settings → ReceiptGuard → Notifications → Allow |
| Photo picker empty | Add photos to Simulator via drag-and-drop into Photos app |

## License

MIT — use freely for learning and personal projects.
