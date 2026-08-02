# Warrantify

Offline-first warranty tracking app built with Flutter.

Warrantify helps you keep product warranty dates, documents, service records, and reminder status in one place. The app works locally first, supports Turkish and English, and keeps the selected theme after restart.

## Features

- Add, edit, delete, search, and filter warranty records
- Track active and expired warranties
- Swipe between dashboard filters: All, Active, Expired
- Store product photos, receipts, documents, notes, and service history
- Extended warranty support by duration or exact end date
- Local reminder scheduling for warranty deadlines
- Local backup/export serialization support
- Light, dark, and system theme modes with persistence
- Turkish and English localization
- Localized launcher name:
  - English/default: Warrantify
  - Turkish: Garantile

## Tech Stack

- Flutter / Dart
- Riverpod
- GoRouter
- Hive CE
- flutter_local_notifications
- flutter_launcher_icons

## Getting Started

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build APK

For local sharing/testing:

```bash
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

If Android still shows an old app icon or app name, uninstall the existing app from the phone and install the APK again.

## Publish to Google Play

1. Generate a release keystore (keep it secret, never commit it):

   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Copy `android/app/key.properties.example` to `android/app/key.properties` and fill in your keystore values. The real `key.properties` file and keystore are gitignored.

3. Build a signed app bundle and upload it to Play Console (Internal testing -> Production):

   ```bash
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab`

4. In Play Console, complete the app listing, content rating, and the **Data safety** form (this app is offline-first and collects no personal data), then submit for review.

## Publish to the App Store

iOS builds require macOS with Xcode.

1. Open `ios/Runner.xcworkspace` in Xcode (or run `open ios/Runner.xcworkspace`).
2. Select the `Runner` target and set your signing team (Personal Team only works for local testing).
3. The app uses Swift Package Manager for plugins, so no `pod install` is needed.
4. Create the archive:

   ```bash
   flutter build ipa --release
   ```

5. Upload the archive with Xcode Organizer or `xcrun altool`/Transporter, then submit to App Review.

## Verification

Before publishing changes, run:

```bash
flutter analyze
flutter test
flutter build apk --release
```

## Project Structure

```text
lib/
  core/          shared constants, theme, utilities
  data/          Hive models, local data source, repository implementation
  domain/        entities and repository contracts
  l10n/          localization classes
  presentation/  screens, widgets, routing, providers
  services/      backup, notifications
test/            unit and widget tests
assets/images/   app logo and launcher icon source assets
```

## Verification

Before publishing changes, run:

```bash
flutter analyze
flutter test
flutter build apk --release
```
