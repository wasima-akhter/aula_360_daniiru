Searched for "firebase"
Searched for "fcmToken"
Viewed auth_controller.dart:110-145
Viewed auth_controller.dart:145-160
Viewed pubspec.yaml:30-110
Listed directory app
Listed directory Runner
Viewed build.gradle.kts:1-25
Viewed build.gradle.kts:1-46
Searched for "PRODUCT_BUNDLE_IDENTIFIER"
Viewed AndroidManifest.xml:1-52
Viewed Info.plist:1-77
Viewed AppDelegate.swift:1-17
Ran command: `flutter pub add firebase_core firebase_messaging`
Viewed settings.gradle.kts:1-27
Viewed bootstrap.dart:1-46
Searched for "fcm"
Viewed storage_keys.dart:1-26
Viewed storage_service.dart:80-120
Edited storage_keys.dart
Viewed storage_service.dart:65-85
Edited storage_service.dart
Created push_notification_service.dart
Viewed auth_controller.dart:55-80
Viewed auth_controller.dart:120-165
Viewed auth_controller.dart:360-385
Viewed auth_controller.dart:1-20
Edited auth_controller.dart
Viewed auth_controller.dart:70-160
Edited auth_controller.dart
Viewed auth_controller.dart:135-165
Edited auth_controller.dart
Viewed auth_controller.dart:370-395
Edited auth_controller.dart
Viewed bootstrap.dart:1-46
Edited bootstrap.dart
Viewed bootstrap.dart:1-10
Edited bootstrap.dart
Viewed AndroidManifest.xml:1-10
Edited AndroidManifest.xml
Viewed settings.gradle.kts:18-27
Edited settings.gradle.kts
Viewed build.gradle.kts:1-10
Viewed build.gradle.kts:35-46
Edited build.gradle.kts
Viewed Info.plist:45-76
Edited Info.plist
Ran command: `flutter test test/unit/auth/`
Created push_notification_service_test.dart
Ran command: `flutter test test/unit/services/push_notification_service_test.dart`
Ran command: `flutter test test/unit/services/push_notification_service_test.dart test/unit/auth/`
Ran command: `git status -s`
Searched for "PRODUCT_BUNDLE_IDENTIFIER"
Searched for "bundleidentifier"
Searched for "PRODUCT_BUNDLE_IDENTIFIER"

### 1. Verification: Was the App Taking FCM Tokens?

**No.** Prior to this update:
- Neither `firebase_core` nor `package:firebase_messaging` was installed in [pubspec.yaml](file:///d:/WASIMA/aula_360_daniiru/pubspec.yaml).
- No notification permissions were being requested or handled.
- While `LoginRequestDto` contained an `fcmToken` property, `null` was always passed into the login request, and no device token was captured or stored.

---

### 2. What Was Implemented

1. **Installed Dependencies**:
   - Added `firebase_core: ^5.0.0` and `firebase_messaging: ^17.0.0` in [pubspec.yaml](file:///d:/WASIMA/aula_360_daniiru/pubspec.yaml).

2. **Created Centralized Push Notification Service**:
   - Created [push_notification_service.dart](file:///d:/WASIMA/aula_360_daniiru/lib/core/services/notification/push_notification_service.dart) with the Riverpod provider `pushNotificationServiceProvider`.
   - **Permission Handling**:
     - **Android 13+ (API 33+)**: Prompts the user for runtime notification permissions (`android.permission.POST_NOTIFICATIONS`).
     - **iOS**: Prompts for native push notification authorization with `alert: true`, `badge: true`, and `sound: true`.
   - **Token Management**:
     - Safely queries `FirebaseMessaging.instance.getToken()`. On iOS, it ensures the native APNs token is ready first.
     - Persists the FCM token securely in [storage_service.dart](file:///d:/WASIMA/aula_360_daniiru/lib/core/storage/storage_service.dart) under [storage_keys.dart](file:///d:/WASIMA/aula_360_daniiru/lib/core/constants/storage_keys.dart) (`fcm_token`).
     - Automatically listens to token rotations via `onTokenRefresh` and keeps local storage updated.
   - **Non-blocking Resilience**:
     - If permissions are denied by the user, if the device lacks Google Play Services, or if Firebase credentials are not yet configured, the service logs a clean warning and returns `null`—**it will never crash the app or block user login**.

3. **Integrated into Authentication**:
   - In [auth_controller.dart](file:///d:/WASIMA/aula_360_daniiru/lib/features/auth/presentation/controllers/auth_controller.dart):
     - `login()`: Asks for permissions, retrieves the FCM token, saves it, and forwards it to the backend via `loginUseCase(..., fcmToken: fcmToken)`.
     - `checkSession()` & `verifyOtp()`: Also forward the active FCM token to keep backend push sessions synchronized.
   - In [bootstrap.dart](file:///d:/WASIMA/aula_360_daniiru/lib/core/app/bootstrap.dart): Initiates background Firebase setup during app launch.

4. **Native Android & iOS Base Configurations**:
   - Added `POST_NOTIFICATIONS` and `INTERNET` permissions to [AndroidManifest.xml](file:///d:/WASIMA/aula_360_daniiru/android/app/src/main/AndroidManifest.xml).
   - Configured [settings.gradle.kts](file:///d:/WASIMA/aula_360_daniiru/android/settings.gradle.kts) and [build.gradle.kts](file:///d:/WASIMA/aula_360_daniiru/android/app/build.gradle.kts) with the Google Services Gradle plugin (conditionally applied so local builds continue compiling even before `google-services.json` is added).
   - Added `UIBackgroundModes` (`fetch` and `remote-notification`) to [Info.plist](file:///d:/WASIMA/aula_360_daniiru/ios/Runner/Info.plist).

---

### 3. What is Needed from You in Terms of Firebase Setup

Your application identifier for both platforms is:
- **Android Package Name**: `com.app.aula360`
- **iOS Bundle Identifier**: `com.app.aula360`

Here is what you need to set up in the [Firebase Console](https://console.firebase.google.com/):

---

#### A. Android Setup

1. In your Firebase project, click **Add app** and select **Android**.
2. **Android package name**: Enter `com.app.aula360`.
3. *(Optional but recommended)*: Generate and register your SHA-1 and SHA-256 fingerprints by running `./gradlew signingReport` inside the `android` folder.
4. **Download configuration file**: Download **`google-services.json`**.
5. **Place file in the project**:
   Save it directly to:
   ```
   android/app/google-services.json
   ```
   *(The Gradle build configuration is already pre-wired and will immediately recognize this file).*

---

#### B. iOS Setup

1. In the same Firebase project, click **Add app** and select **iOS**.
2. **Apple bundle ID**: Enter `com.app.aula360`.
3. **Download configuration file**: Download **`GoogleService-Info.plist`**.
4. **Place file in the project**:
   Save it to:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
   *(Open `ios/Runner.xcworkspace` in Xcode, right-click the `Runner` group, select "Add Files to Runner...", and ensure "Copy items if needed" and the "Runner" target checkbox are checked).*
5. **APNs Authentication Key (Apple Developer Account)**:
   - Go to [Apple Developer Portal](https://developer.apple.com/) -> **Certificates, Identifiers & Profiles** -> **Keys**.
   - Create an **APNs Key** (Apple Push Notifications service) and download the `.p8` file. Note your **Key ID** and your **Team ID**.
   - In Firebase Console, go to **Project Settings** -> **Cloud Messaging** tab -> scroll to **Apple app configuration** -> upload your `.p8` key with its Key ID and Team ID.
6. **Xcode Capabilities**:
   - In Xcode, select the `Runner` target -> **Signing & Capabilities** -> click `+ Capability`:
     - Add **Push Notifications**.
     - Add **Background Modes** -> ensure **Background fetch** and **Remote notifications** are checked.

---

### Summary Checklist

| Item | Location | Status in Code |
| :--- | :--- | :--- |
| FCM Token on Login / Session | [auth_controller.dart](file:///d:/WASIMA/aula_360_daniiru/lib/features/auth/presentation/controllers/auth_controller.dart) | ✅ Implemented & Tested |
| Notification Permissions (Android 13+ & iOS) | [push_notification_service.dart](file:///d:/WASIMA/aula_360_daniiru/lib/core/services/notification/push_notification_service.dart) | ✅ Implemented & Tested |
| Android Manifest & Gradle Config | `android/app/src/main/AndroidManifest.xml` | ✅ Configured |
| iOS Background Modes & Permissions | `ios/Runner/Info.plist` | ✅ Configured |
| `google-services.json` | `android/app/google-services.json` | ⏳ *Awaiting file from Firebase Console* |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` | ⏳ *Awaiting file from Firebase Console* |
| APNs `.p8` Key Upload | Firebase Console -> Cloud Messaging | ⏳ *Awaiting Apple Developer portal upload* |
