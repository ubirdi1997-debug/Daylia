# Checkly Lists

A simple, offline-first checklist app focused on reusable lists, daily routines, and clarity.

## Features

- ✅ Fully offline - no internet required
- ✅ No ads, analytics, or data sharing
- ✅ Reusable checklists with one-tap reset
- ✅ Drag & drop reordering
- ✅ Swipe to delete with undo
- ✅ Search and sort functionality
- ✅ Pin/unpin checklists
- ✅ Light and dark mode support
- ✅ Material 3 design

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android SDK (API 21 or higher)

### Installation

1. Clone or download this repository

2. Install dependencies:
```bash
flutter pub get
```

3. Generate app icons from `assets/icon.png`:
```bash
flutter pub run flutter_launcher_icons
```

4. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
flutter run
```

### Building for Release

The app is configured with signing keys. To build a signed release APK:

```bash
flutter build apk --release
```

The signing configuration is in `android/key.properties` and uses the keystore at `assets/key.jks`.

## Architecture

- **State Management**: Riverpod
- **Local Storage**: Hive
- **UI Framework**: Flutter with Material 3
- **Architecture Pattern**: Feature-based structure

## Permissions

This app requires **minimal permissions** - only POST_NOTIFICATIONS for checklist reminders. It's completely offline and stores all data locally.

## License

Copyright © MAST EYES SEEDS PRIVATE LIMITED

## Publishing to Play Store

For publishing to Google Play Store, see the following documents:

- **README_PUBLISHING.md** - Complete publishing guide
- **PLAY_STORE_CHECKLIST.md** - Submission checklist
- **PLAY_STORE_LISTING.md** - Store listing content
- **PRIVACY_POLICY.md** - Privacy policy (must be hosted online)
- **PRIVACY_POLICY.html** - HTML version for easy hosting
- **TERMS_OF_SERVICE.md** - Terms of service

### Quick Build for Play Store

Build App Bundle (recommended):
```bash
flutter build appbundle --release
```

Build APK (alternative):
```bash
flutter build apk --release
```

## Support

For support, email: masteyesseeds@gmail.com
