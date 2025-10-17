# Mining App (Flutter)

A minimalist, multi-platform Flutter application targeting Android, Web, and Windows. This README covers prerequisites, setup, run/build commands, testing, configuration, and troubleshooting.

## Overview

- Tech: Flutter + Dart
- Platforms: Android, Web (Chrome), Windows Desktop
- Entry point: `lib/main.dart`
- Assets: `assets/` (declare in `pubspec.yaml`)
- Tests: `test/` (example: `test/widget_test.dart`)

## Prerequisites

- Flutter SDK (stable). Verify with `flutter --version`.
- Git
- Android (for Android builds):
  - Android Studio + Android SDK
  - JDK 17 (recommended for recent Android Gradle Plugin)
  - A device/emulator
- Web (optional): Google Chrome
- Windows desktop (optional):
  - Visual Studio 2022 with the "Desktop development with C++" workload
  - CMake and MSVC (installed via the workload)
##  Working Prototype
<p align="center" style="display: flex; justify-content: center; gap: 40px;">
  <img src="https://github.com/user-attachments/assets/d735cab2-e96d-4813-a205-9e3c0be217d9" alt="Image 1" width="45%" style="border-radius:10px;"/>
  <img src="https://github.com/user-attachments/assets/04c7ff5f-21b6-4fc7-a30c-17640fe53373" alt="Image 2" width="45%" style="border-radius:10px;"/>
</p>

<p align="center" style="display: flex; justify-content: center; gap: 40px;">
  <img src="https://github.com/user-attachments/assets/80c29bf5-54a9-4005-a9fb-5abbab3dfd33" alt="Image 1" width="45%" style="border-radius:10px;"/>
  <img src="https://github.com/user-attachments/assets/97630d70-b8e7-4195-bf8e-99f20b26e4fc" alt="Image 2" width="45%" style="border-radius:10px;"/>
</p>



## Setup

1) Clone the repository

```powershell
# Replace the path or folder name as you prefer
git clone https://github.com/architgulhane/Mining-app-Dart.git
cd Mining-app-Dart
```

2) Install dependencies

```powershell
flutter pub get
```

3) (Optional) Configure API/settings

- Check `lib/config/api_config.dart` for any base URLs or keys your environment needs.
- Register assets (images/fonts) in `pubspec.yaml` under `flutter.assets` or `flutter.fonts` if you add files to `assets/`.

## Run

- Verify your environment

```powershell
flutter doctor
```

- Android

```powershell
# Start an emulator or connect a device first
flutter devices
flutter run -d <device-id>
```

- Web (Chrome)

```powershell
# Enable web support once per machine if needed
flutter config --enable-web
flutter run -d chrome
```

- Windows Desktop

```powershell
# Enable windows support once per machine if needed
flutter config --enable-windows-desktop
flutter run -d windows
```

## Build (Release)

- Android APK

```powershell
flutter build apk --release
```

- Android App Bundle (Play Store)

```powershell
flutter build appbundle
```

- Web (static site in `build/web`)

```powershell
flutter build web
```

- Windows (artifact in `build/windows`)

```powershell
flutter build windows
```

## Testing

Run all tests:

```powershell
flutter test
```

Example test: `test/widget_test.dart` (counter widget smoke test).

## Project Structure (high-level)

```
android/           # Android project (Gradle)
assets/            # Static assets (images, fonts, etc.)
lib/               # Dart/Flutter source (main entry: main.dart)
  config/          # App configuration (e.g., api_config.dart)
  components/      # UI components
  codeSarthi/      # App features/modules
  ...
web/               # Web support files (index.html, manifest.json)
windows/           # Windows desktop runner
test/              # Unit & widget tests
pubspec.yaml       # Flutter/Dart dependencies & assets declaration
```

## Troubleshooting

- Remote moved warning when pushing

```powershell
git remote -v
# If origin points to ...Mining-app-Dart-.git, update it:
git remote set-url origin https://github.com/architgulhane/Mining-app-Dart.git
```

- Android Gradle/JDK issues
  - Ensure JDK 17 is installed and used by Android Studio/Gradle
  - If needed, set `JAVA_HOME` to your JDK 17 path

- Build issues after dependency changes

```powershell
flutter clean
flutter pub get
```

- No devices found
  - For Android, create/start an emulator in Android Studio or connect a physical device with USB debugging
  - For Web, ensure Chrome is installed
  - For Windows, ensure desktop support is enabled and Visual Studio C++ workload is installed

## Contributing

- Create a feature branch
- Commit with clear messages (e.g., `feat: ...`, `fix: ...`)
- Open a Pull Request
