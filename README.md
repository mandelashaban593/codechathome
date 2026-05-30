# CodeChatHome (Flutter App)

A Flutter-based learning and mentorship platform where students can connect with professional software development trainers.

---

## 🚀 Getting Started

This project is a starting point for a Flutter application.

If this is your first Flutter project, here are useful resources:

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

---

## 📦 Build APK (Release)

To generate release APK:

```bash
flutter build apk --release --split-per-abi
📱 Output APKs:

After build completes:

build/app/outputs/flutter-apk/

Generated files:

app-armeabi-v7a-release.apk (32-bit)
app-arm64-v8a-release.apk (Recommended for Google Play)
app-x86_64-release.apk
📦 Recommended (Google Play)

Google Play prefers Android App Bundle (.aab) instead of APK.

Build command:
flutter build appbundle --release
Output:
build/app/outputs/bundle/release/app-release.aab
⚙️ Project Structure

Project location:

D:\sites\flutter_projects\LearnTechApp\codechathome
Key folders:
android/        → Android native project
ios/            → iOS project
lib/            → Flutter application code
assets/         → Images & resources
build/          → Build outputs
test/           → Unit tests
web/            → Web version (if enabled)
windows/        → Windows desktop build
macos/          → MacOS build
linux/          → Linux build
⚠️ Gradle Issue (Cache Warning)

If you see this error:

Could not read workspace metadata from C:\Users\user\.gradle\caches
Fix it using:
flutter clean
flutter pub get

Or delete Gradle cache:

C:\Users\user\.gradle\

Then rebuild:

flutter build appbundle --release
📱 Recommended Google Play Setup
Use .aab (App Bundle) instead of APK
Enable Play App Signing
Ensure:
Privacy Policy added
Data Safety form completed
Test accounts provided (if login required)
🎯 APK vs AAB Summary
Format	Use Case	Recommendation
APK	Manual install/testing	OK
AAB	Google Play Store	⭐ Recommended
📌 Build Summary
APK command:
flutter build apk --release --split-per-abi

en, reducing it from 1645184 to 3000 bytes (99.8% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Running Gradle task 'assembleRelease'...                          278.2s
√ Built build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk (21.0MB)
√ Built build\app\outputs\flutter-apk\app-arm64-v8a-release.apk (23.3MB)
√ Built build\app\outputs\flutter-apk\app-x86_64-release.apk (24.6MB)


AAB command:
flutter build appbundle --release

Running Gradle task 'bundleRelease'...                           3642.7s
√ Built build\app\outputs\bundle\release\app-release.aab (46.0MB)"# codechathome" 
