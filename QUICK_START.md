# Quick Start Guide - Flutter Meeting Tracker

## Prerequisites

1. **Install Flutter SDK**
   - Download from https://flutter.dev/docs/get-started/install
   - Ensure Flutter is in your PATH
   - Run `flutter doctor` to check setup

2. **Platform-Specific Requirements**

   **Windows:**
   - Visual Studio 2022 with "Desktop development with C++" workload
   - Windows 10 SDK

   **macOS:**
   - Xcode (from App Store)
   - CocoaPods: `sudo gem install cocoapods`

   **Linux:**
   - GTK development libraries
   - `sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev`

## Setup

1. **Navigate to project:**
```bash
cd meeting-tracker-flutter
```

2. **Get dependencies:**
```bash
flutter pub get
```

3. **Run the app:**
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Configuration

### Google Calendar

1. Create OAuth credentials (see web version SETUP.md)
2. Add Client ID to `lib/config/google_config.dart`:
```dart
class GoogleConfig {
  static const String clientId = 'YOUR_CLIENT_ID_HERE';
}
```

### Microsoft Outlook/OneDrive

1. Create Azure App Registration (see OUTLOOK_SETUP.md)
2. Add Client ID to `lib/config/ms_config.dart`:
```dart
class MSConfig {
  static const String clientId = 'YOUR_CLIENT_ID_HERE';
  static const String tenantId = 'common'; // or your tenant ID
}
```

## Building for Release

### Windows
```bash
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### macOS
```bash
flutter build macos --release
```
Output: `build/macos/Build/Products/Release/`

### Linux
```bash
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

## Features

- ✅ Cross-platform (Windows, macOS, Linux, iOS, Android)
- ✅ Meeting timer with start/stop/reset
- ✅ Calendar sync (Google, Outlook, OneDrive)
- ✅ Daily inspirational quotes
- ✅ Moon phase display
- ✅ Docking system
- ✅ Resizable and draggable
- ✅ Meeting scheduler
- ⚠️ Passkey support (to be implemented)
- ⚠️ Window management (requires platform-specific setup)

## Troubleshooting

### "window_manager not found"
- The window_manager package is optional
- The app will work without it, just without advanced window controls
- For full window management, ensure the package is properly configured

### "OAuth not working"
- Check that Client IDs are correctly set in config files
- Ensure redirect URIs match in OAuth provider settings
- Check network connectivity

### Build errors
- Run `flutter clean` then `flutter pub get`
- Ensure all platform-specific dependencies are installed
- Check `flutter doctor` for missing components
