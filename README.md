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
flutter build apk --release --split-per-abi


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



PROJECT STRUCTURE.> Could not read workspace metadata from C:\Users\user\.gradle\caches\8.14\transforms\34e9e240dc85f40ff3529429a7b2b86d\metadata.bin

gal/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── bluetooth_screen.dart
│   │   └── remote_screen.dart
│   ├── services/
│   │   ├── bluetooth_service.dart
│   │   ├── bluetooth_service_android.dart
│   │   └── bluetooth_service_stub.dart
│   └── models/
│       └── device_info.dart
├── pubspec.yaml

HOW THE APPLICATION WORKS

Your Flutter remote controller app (phone/web) sends keyboard commands to the Windows PC through the small server. The Windows server then uses a library like PyAutoGUI to simulate keyboard presses on the computer. You just need to enter the ip address of the  device on the app to controll the game on that device

So the controller does not control games directly — it pretends to be a keyboard.
Any Windows game that supports keyboard input can be controlled.

