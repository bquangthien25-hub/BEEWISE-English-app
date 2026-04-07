Firebase setup steps

1) Install FlutterFire CLI (optional but recommended):
   - Run: `dart pub global activate flutterfire_cli`

2) Configure your Firebase project and platforms using FlutterFire CLI (recommended):
   - From the project root run: `flutterfire configure`
   - This will generate `lib/firebase_options.dart` with correct values and place platform files.

3) Android manual steps (if not using `flutterfire configure`):
   - Download `google-services.json` from Firebase console (Project settings > Your apps > Android).
   - Place the file at `android/app/google-services.json`.
   - Add the Google services Gradle plugin:
     - In `android/build.gradle` (project-level) add to `dependencies`:
       `classpath 'com.google.gms:google-services:4.3.15'`
     - In `android/app/build.gradle` (app-level) apply the plugin at the bottom:
       `apply plugin: 'com.google.gms.google-services'`

4) iOS manual steps (if not using `flutterfire configure`):
   - Download `GoogleService-Info.plist` from Firebase console for your iOS app.
   - In Xcode, right-click Runner > Add Files to "Runner" and add the plist.
   - Ensure `platform :ios, '11.0'` or newer is set in `ios/Podfile`.

5) After adding platform files, update dependencies and run:
   - `flutter pub get`
   - `flutter run` (or build for release)

6) Notes about Gradle Kotlin DSL (build.gradle.kts):
   - If your project uses Kotlin DSL (`build.gradle.kts`), add the Google services plugin classpath to `build.gradle.kts` project-level buildscript or use the Gradle settings recommended by Firebase docs.
   - If unsure, run `flutterfire configure` which updates files for you.

7) Troubleshooting:
   - If you see `DefaultFirebaseOptions` not found, run `flutterfire configure` to regenerate `lib/firebase_options.dart`.
   - For Android errors about the plugin, ensure `google()` is in repositories and the classpath plugin is present.

If you want, I can:
- Run `flutterfire configure` steps for you (I cannot access Firebase console or credentials), or
- Edit Android Gradle files directly to add the classpath and plugin application (I can do that if you confirm and accept helper changes).
