# gal

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



## APK WOKING GENERATING COMMAND IS 
flutter build apk --release --split-per-


## APK WOKING GENERATING COMMAND IS 
flutter build apk --release --split-per-abi

## GENERATED APK PATH
D:\sites\flutter_projects\gal>flutter build apk --release --split-per-abi
Running Gradle task 'assembleRelease'...                          571.0s
√ Built build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk (11.6MB)
√ Built build\app\outputs\flutter-apk\app-arm64-v8a-release.apk (14.2MB) => This is meant for Google play
√ Built build\app\outputs\flutter-apk\app-x86_64-release.apk (15.4MB)

2️⃣ Recommended Practice: Use App Bundle (.aab)

Google Play now prefers .aab (Android App Bundle) over APK.

.aab allows Google Play to generate APKs automatically for different device architectures (32-bit & 64-bit).

## Command to generate an app bundle:

flutter build appbundle --release

## Output will be:

D:\sites\flutter_projects\gal>flutter build appbundle --release
Running Gradle task 'bundleRelease'...                            748.8s
√ Built build\app\outputs\bundle\release\app-release.aab (36.6MB)
