# mopile_app

A new Flutter project.

🌟 Empower your safety and productivity with an AI‑assisted Flutter app — featuring an AI assistant, emergency utilities, quick notes, multilingual support, and local notifications. Built to be fast, simple, and helpful on the go. 🤝🛟🧠

## ✨ Features

- 🧠 AI Assistant: Get helpful responses and suggestions right inside the app (`lib/screens/ai_assistant_screen.dart`, `lib/services/ai_services.dart`).
- 🛟 Emergency Utilities: Access emergency contacts and actions quickly (`lib/screens/emergency_screen.dart`).
- 📝 Notes: Add and manage quick notes via a simple dialog (`lib/screens/add_notes_dialog.dart`).
- 🔔 Local Notifications: Schedule and receive reminders (`lib/services/notification_services.dart`).
- 🌍 Localization (EN/AR): Fully localized UI using Flutter gen‑l10n (`lib/l10n/`, `l10n.yaml`).
- 🎨 Cross‑platform: Runs on Android, iOS, web, Windows, macOS, and Linux.

## 🚀 Quick start

1. Prerequisites
   - Flutter SDK installed: https://docs.flutter.dev/get-started/install
   - A device or emulator/simulator

2. Install dependencies
   - `flutter pub get`

3. Run the app
   - `flutter run`

## 🌍 Localization

- Strings live in `lib/l10n/` using ARB files:
  - English: `lib/l10n/app_en.arb`
  - Arabic: `lib/l10n/app_ar.arb`
- Configuration: `l10n.yaml`
- Localizations class: `lib/l10n/app_localizations.dart`

To add a new language:

1. Create a new `app_xx.arb` file in `lib/l10n/` (e.g., `app_es.arb`).
2. Add translated key‑values matching the existing keys.
3. Run `flutter gen-l10n` (or just `flutter run` to generate automatically).

## 🔔 Notifications

- Notification setup and logic live in `lib/services/notification_services.dart`.
- Ensure you have the necessary platform permissions configured (Android/iOS) if you add new notification features.

## 🗂️ Notable paths

- App entry: `lib/main.dart`, `lib/app.dart`
- Screens: `lib/screens/`
- Models: `lib/models/`
- Services: `lib/services/`
- Assets: `assets/`

## 🧪 Running tests

- Example widget test: `test/widget_test.dart`
- Run: `flutter test`

## 🏗️ Build

- Android: `flutter build apk` or `flutter build appbundle`
- iOS: `flutter build ios` (requires Xcode on macOS)
- Web: `flutter build web`
- Windows: `flutter build windows`
- macOS: `flutter build macos`
- Linux: `flutter build linux`

## 🙌 Contributing

Issues and PRs are welcome! If you’d like, start by opening an issue describing your idea.

---

Made with ❤️ using Flutter.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 👥 Authors

- Abdelhalim
- Zyed
