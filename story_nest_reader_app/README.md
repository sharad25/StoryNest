# StoryNest Reader (minimal)

This is a minimal Flutter reader app scaffold intended to run on mobile and tablet platforms. It demonstrates loading simple `pack_manifest` and `story_manifest` JSON assets, parsing into typed models, and showing a tiny reader UI.

Prerequisites:
- Flutter SDK installed: https://flutter.dev/docs/get-started/install

Run in project root `story_nest_reader_app/`:

```bash
cd story_nest_reader_app
flutter pub get
flutter test
flutter run -d <android-device-id>
```

Supported platforms and current status:
- Target platforms: iPhone (iOS), iPad (iPadOS), Android phones, and Kindle Fire tablets (Android-based).
- Current build status: at the moment this app has been built and tested primarily for Android phones. Building, signing, and validation for iOS (iPhone/iPad) and Kindle Fire packaging are planned but not yet completed.

Notes:
- The app uses the example manifests stored in `assets/manifests/`.
- Tests run with `flutter test` and validate the simple manifests.
