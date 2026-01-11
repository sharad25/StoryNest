# StoryNest Reader (minimal)

This is a minimal Flutter reader app scaffold for Android phones. It demonstrates loading simple `pack_manifest` and `story_manifest` JSON assets, parsing into typed models, and showing a tiny reader UI.

Prerequisites:
- Flutter SDK installed: https://flutter.dev/docs/get-started/install

Run in project root `reader_app/`:

```bash
cd reader_app
flutter pub get
flutter test
flutter run -d <android-device-id>
```

Notes:
- The app uses the example manifests stored in `assets/manifests/`.
- Tests run with `flutter test` and validate the simple manifests.
