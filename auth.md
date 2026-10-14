# Frontend Authentication Integration Guide (ALUA Academy Management)

> **Document Version:** 2.0.0  
> **Backend Repository:** [Abdullah00001/alua-academy-management](https://github.com/Abdullah00001/alua-academy-management.git)  
> **Target Branch:** `development`  
> **Base URL:** `https://alua.localbox.online/api/v1`  
> **API Docs (Swagger UI):** `https://alua.localbox.online/api-docs`

---

## 1. Overview & Authentication Architecture

The ALUA Academy Management system uses a stateful, device-aware JWT authentication architecture backed by Redis (for token blacklisting & OTP caching) and PostgreSQL / Prisma (for user credentials and active device sessions).

### 1.1 Two-Token Architecture

Authentication lifecycle uses two distinct token types:

```
[ Signup Screen ]
       │
       ▼  POST /api/v1/auth/signup
(Creates user with status INACTIVE, sends OTP to email)
       │
       ▼ Returns temporary OTP Page Token: `data.token`
[ OTP Verification Screen ]
       │
       ├────────────────────────────────────────┐
       │ (User enters 6-digit OTP)              │ (User taps "Resend OTP")
       ▼ POST /api/v1/auth/verify               ▼ POST /api/v1/auth/resend
  Header: Authorization: Bearer <data.token>      Header: Authorization: Bearer <data.token>
  Body: { otp, deviceIdentifier, ... }            (Empty body)
       │                                        │
       ▼ Returns `data.accessToken`             ▼ Generates new OTP, resets 4-minute expiry
[ Token Storage & Route Guard ]
       │
       ├────────────────────────────────────────┐
       │ if (isProfileSetup == false)           │ if (isProfileSetup == true)
       ▼                                        ▼
[ Profile Setup Screen ]                [ Main Dashboard ]
(POST /api/v1/profile/setup/parent      (Store accessToken in Secure Storage)
 or /profile/setup/teacher)
```

```
[ Returning User / Login Screen ]
       │
       ▼  POST /api/v1/auth/login
(Validates credentials + role, revokes stale sessions on this device)
       │
       ▼ Returns `data.token` (Access Token) + `data.user` (SessionDTO)
[ Token Storage & Route Guard ]
       │
       ├────────────────────────────────────────┐
       │ if (isProfileSetup == false)           │ if (isProfileSetup == true)
       ▼                                        ▼
[ Profile Setup Screen ]                [ Main Dashboard ]
```

```
[ App Launch / Splash Screen ]
       │
       ▼ Read stored `accessToken`
(If none -> navigate to Login / Onboarding)
       │
       ▼  POST /api/v1/auth/check
  Header: Authorization: Bearer <accessToken>
  Body: { fcmToken: "<latest-fcm-token>" } (optional)
       │
       ├────────────────────────────────────────┐
       ▼ (200 OK: Valid Session)                ▼ (401 / 403: Expired / Revoked / Suspended)
  Refresh cached SessionDTO                     Clear tokens & local cache,
  Route according to `isProfileSetup`           Redirect to Login with specific error message
```

---

### 1.2 Core Mobile Integration Rules

1. **`token` from `/auth/signup` (Temporary OTP Page Token)**:
   - Valid for **1 day (`1d`)**.
   - Restricted **strictly** to authorizing `POST /auth/verify` and `POST /auth/resend`.
   - **Never** use this token for general authenticated APIs.
   - Automatically blacklisted on the backend in Redis once `/auth/verify` succeeds.

2. **`accessToken` from `/auth/verify` & `token` from `/auth/login` (User Session Token)**:
   - Standard user JWT Bearer token.
   - Attach as `Authorization: Bearer <token>` on all standard protected APIs.
   - **Session Lifetimes**:
     - On `/auth/verify`: Defaults to **30 days** (`30d`).
     - On `/auth/login`: **30 days** (`30d`) if `rememberMe == true`, or **7 days** (`7d`) if `rememberMe == false`.

3. **Device Binding & Session Superseding**:
   - Every active session is tied to a client-generated **`deviceIdentifier`** (UUIDv4).
   - Persist this `deviceIdentifier` permanently on the client device (e.g. in `FlutterSecureStorage` or `SharedPreferences`). **Do not regenerate it on logout**.
   - When a user logs in or verifies on a device, the backend automatically revokes (`REVOKED`) any existing session matching that `deviceIdentifier` (`NEW_LOGIN_SUPERSEDED`) or matching that `fcmToken` (`FCM_SUPERSEDED`).

4. **Profile Setup Onboarding Gate (`isProfileSetup`)**:
   - Both `/auth/verify` and `/auth/login` return boolean flag `isProfileSetup`.
   - If `isProfileSetup == false`, block navigation to the main application and route the user to their respective profile setup screen (`/profile/setup/parent` or `/profile/setup/teacher`).
   - Only route to the main home/dashboard when `isProfileSetup == true`.

5. **Token Rotation & Device Heartbeat (`/auth/check`)**:
   - Call `POST /auth/check` on app startup.
   - Pass the latest FCM push token in the body to seamlessly rotate push tokens when Firebase refreshes them.
   - The backend throttles `lastSeenAt` database writes to once per hour.

---

## 2. Base Configuration & Headers

| Environment | Base URL |
| :--- | :--- |
| **Development / Staging** | `https://alua.localbox.online/api/v1` |
| **Production** | *(Configure in `.env`)* |

### Default HTTP Headers
```http
Content-Type: application/json
Accept: application/json
```

For authenticated endpoints, include:
```http
Authorization: Bearer <JWT_TOKEN>
```

---

## 3. Standard Response Envelopes & Error Handling

All backend APIs return a predictable response envelope.

### 3.1 Success Envelope (HTTP 200 / 201)
```json
{
  "success": true,
  "message": "Human-readable success message",
  "data": { ... },
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

### 3.2 Business / Auth / System Error Envelope (HTTP 400, 401, 403, 404, 409, 500)
```json
{
  "success": false,
  "message": "Human-readable error description",
  "errorType": "ERROR_ENUM_CODE",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

### 3.3 Validation Error Envelope (HTTP 422)
When payload fails Zod schema validation:
```json
{
  "success": false,
  "message": "Request body validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address"
    },
    {
      "field": "password",
      "message": "Password must contain at least one special character"
    }
  ],
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

### 3.4 Error Types Dictionary & UI Strategies

| `errorType` | HTTP Status | Meaning | Recommended Frontend Action |
| :--- | :--- | :--- | :--- |
| `DUPLICATE_DATA` | 409 | Email is already registered in the system. | Prompt user: *"An account with this email already exists. Would you like to log in instead?"* with a direct link to Login screen. |
| `INVALID_CREDENTIALS` | 401 | Email, password, or role combination is incorrect. | Show inline error under credentials: *"Invalid email or password. Please try again."* |
| `ACCOUNT_INACTIVE` | 403 | User registered but has not completed OTP email verification. | Show alert: *"Your account is pending verification."* If OTP page token is available, direct to OTP screen; otherwise advise resending verification. |
| `USER_SUSPENDED` | 403 | Administrator has suspended this account. | Display modal dialog: *"Your account has been suspended. Please contact academy administration."* Clear tokens and logout. |
| `USER_NOT_FOUND` | 404 | User account record no longer exists. | Clear storage, navigate to Login. |
| `OTP_EXPIRED` | 401 | The 6-digit OTP code has expired (exceeded 4 minutes). | Highlight OTP inputs in red, enable the *"Resend Code"* button with an inline message: *"OTP has expired. Tap Resend to get a new code."* |
| `INVALID_OTP` | 401 | Entered OTP digits do not match Redis cache. | Shake OTP input fields, clear input digits, display *"Incorrect OTP code. Please verify and try again."* |
| `TOKEN_EXPIRED` | 401 | Token has expired (OTP page token after 1 day, or session token after 7/30 days). | For OTP screen: Inform user and redirect to Signup/Login. For Session: Redirect to Login with session expired prompt. |
| `TOKEN_INVALID` | 401 | Malformed, corrupted, or missing Bearer token. | Clear tokens, navigate to Login. |
| `TOKEN_BLACKLISTED` | 401 | Token was revoked or already consumed (e.g. OTP token used or session logged out). | Clear tokens, navigate to Login. |
| `SESSION_LOGGED_OUT` | 401 | Device session was marked as `LOGGED_OUT`. | Clear tokens, route to Login. |
| `SESSION_REVOKED` | 401 | Session revoked because the user logged in from another session or FCM was rotated. | Display notification: *"You have been signed in on another device."* Clear session and return to Login. |
| `SESSION_EXPIRED` | 401 | Device session record expired on database. | Clear session and return to Login. |
| `INVALID_DEVICE_CONTEXT`| 401 | Token payload is missing `deviceId` claim. | Clear session and re-authenticate. |
| `DEVICE_NOT_FOUND` | 401 | Device record ID in token was deleted from database. | Clear session and return to Login. |
| `DEVICE_NOT_OWNED` | 401 | Device record belongs to a different user ID. | Security breach mitigation: clear local storage immediately. |
| `INVALID_JSON` | 400 | Request body is not well-formed JSON. | Check serialization logic in HTTP client. |
| `SERVER_ERROR` | 500 | Unhandled backend exception. | Display generic toast: *"Server error. Please try again later."* |

---

## 4. Endpoints Specification

### 4.1 Signup User
Registers a new user account as either `PARENT` or `TEACHER`, creates corresponding profile records, sends a 6-digit OTP to the email, and returns a temporary OTP Page Token.

- **Method**: `POST`
- **URL**: `/api/v1/auth/signup`
- **Auth Required**: No (Public)

#### Request Body
```json
{
  "fullName": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "role": "PARENT",
  "password": "StrongPassword123!",
  "isLegalTermAccepted": true
}
```

#### Field Specifications & Validation Rules
| Field | Type | Required | Validation Rules |
| :--- | :--- | :--- | :--- |
| `fullName` | String | Yes | Minimum 1 character. Stripped/trimmed. |
| `email` | String | Yes | Valid email format. Normalized to lowercase. |
| `phone` | String | Yes | Regex: `^\+?[1-9]\d{1,14}$` (E.164 format, e.g. `+1234567890`). |
| `role` | String | Yes | Must be `"PARENT"` or `"TEACHER"`. |
| `password` | String | Yes | **6 to 16 characters**. Must contain:<br>• $\ge 1$ uppercase letter (`[A-Z]`)<br>• $\ge 1$ lowercase letter (`[a-z]`)<br>• $\ge 1$ numeric digit (`[0-9]`)<br>• $\ge 1$ special character (`[^A-Za-z0-9]`) |
| `isLegalTermAccepted` | Boolean | Yes | Must be strictly `true`. |

#### Response (HTTP 201 Created)
```json
{
  "success": true,
  "message": "Signup successful,Please check you email for otp to verify your account!",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjNlNDU2Ny1lODliLTEyZDMtYTQ1Ni00MjY2MTQxNzQwMDAiLCJyb2xlIjoiUEFSRU5UIiwiYWNjb3VudFN0YXR1cyI6IklOQUNUSVZFIiwiZGV2aWNlSWQiOiJwZW5kaW5nIn0..."
  },
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

### 4.2 Verify Signup User (Submit OTP)
Submits the 6-digit OTP code to verify the account. Marks the account `ACTIVE`, registers the active device session, blacklists the OTP page token, and returns the full user session token (`accessToken`).

- **Method**: `POST`
- **URL**: `/api/v1/auth/verify`
- **Auth Required**: **Yes** (Bearer Token: Use `token` from `/auth/signup`)
- **Headers**:
  ```http
  Authorization: Bearer <data.token>
  ```

#### Request Body
```json
{
  "otp": "123456",
  "deviceIdentifier": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "fcmToken": "fcm_token_sample_abc123",
  "platform": "ANDROID"
}
```

#### Field Specifications & Validation Rules
| Field | Type | Required | Validation Rules |
| :--- | :--- | :--- | :--- |
| `otp` | String | Yes | Exactly 6-digit string received via email. |
| `deviceIdentifier` | String | Yes | Unique client device UUID (persisted locally). |
| `fcmToken` | String | No | Firebase Cloud Messaging device push token (omit or pass null if notification permissions denied). |
| `platform` | String | Yes | Must be `"ANDROID"` or `"IOS"`. |

#### Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "User verification successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "isProfileSetup": false,
    "role": "PARENT",
    "accountStatus": "ACTIVE",
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "fullName": "John Doe",
    "avatarUrl": null
  },
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

### 4.3 Resend Verification OTP
Generates a fresh 6-digit OTP, deletes the previous OTP from Redis, restarts the 4-minute expiry timer, and dispatches an email.

- **Method**: `POST`
- **URL**: `/api/v1/auth/resend`
- **Auth Required**: **Yes** (Bearer Token: Use `token` from `/auth/signup`)
- **Headers**:
  ```http
  Authorization: Bearer <data.token>
  ```
- **Request Body**: None (Empty body `{}`)

#### Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "Signup verification otp resend successful!",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

### 4.4 User Login
Authenticates an existing user with email, password, and designated role. Supersedes any conflicting device sessions, registers the new device session, and issues a standard user access JWT.

- **Method**: `POST`
- **URL**: `/api/v1/auth/login`
- **Auth Required**: No (Public)

#### Request Body
```json
{
  "email": "john.doe@example.com",
  "password": "StrongPassword123!",
  "role": "PARENT",
  "deviceIdentifier": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "fcmToken": "fcm_token_sample_abc123",
  "platform": "ANDROID",
  "rememberMe": true
}
```

#### Field Specifications & Validation Rules
| Field | Type | Required | Validation Rules |
| :--- | :--- | :--- | :--- |
| `email` | String | Yes | Valid email string. Normalized to lowercase. |
| `password` | String | Yes | Non-empty password string. |
| `role` | String | Yes | Must be `"PARENT"` or `"TEACHER"`. Must match the account's registered role. |
| `deviceIdentifier` | String | Yes | Client device UUID. |
| `fcmToken` | String | No | Firebase push token. Optional. |
| `platform` | String | Yes | Must be `"ANDROID"` or `"IOS"`. |
| `rememberMe` | Boolean | No | Default: `false`. If `true`, token validity is **30 days**; if `false`, validity is **7 days**. |

#### Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "userId": "123e4567-e89b-12d3-a456-426614174000",
      "fullName": "John Doe",
      "email": "john.doe@example.com",
      "phone": "+1234567890",
      "avatarUrl": "https://alua-bucket.s3.amazonaws.com/attachments/avatar.jpg",
      "role": "PARENT",
      "status": "ACTIVE",
      "isProfileSetup": true,
      "profileCompletedAt": "2026-10-14T09:50:00.000Z",
      "language": "EN"
    }
  },
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

> **Note on DTO Property Names:** Notice that `/auth/login` returns the access token under `"token"`, whereas `/auth/verify` returns it under `"accessToken"`. Handle this in your response mapping or use the unified DTO shown in Section 5.

---

### 4.5 Check Access Token & Active Session
Validates the current user access token against Redis blacklists, database user status, and device session state. Used during app launch to verify session viability and rotate FCM push tokens.

- **Method**: `POST`
- **URL**: `/api/v1/auth/check`
- **Auth Required**: **Yes** (Bearer Token: Use `accessToken` / `token`)
- **Headers**:
  ```http
  Authorization: Bearer <accessToken>
  ```

#### Request Body (Optional)
```json
{
  "fcmToken": "fcm_token_sample_abc123"
}
```

#### Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "User is authenticated.",
  "data": {
    "userId": "123e4567-e89b-12d3-a456-426614174000",
    "fullName": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "avatarUrl": "https://alua-bucket.s3.amazonaws.com/attachments/avatar.jpg",
    "role": "PARENT",
    "status": "ACTIVE",
    "isProfileSetup": true,
    "profileCompletedAt": "2026-10-14T09:50:00.000Z",
    "language": "EN"
  },
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

### 4.6 User Logout
Terminates the active session on this device. Marks device status as `LOGGED_OUT`, clears its FCM token, and blacklists the current JWT in Redis for its remaining time-to-live.

- **Method**: `POST`
- **URL**: `/api/v1/auth/logout`
- **Auth Required**: **Yes** (Bearer Token: Use `accessToken` / `token`)
- **Headers**:
  ```http
  Authorization: Bearer <accessToken>
  ```
- **Request Body**: None (Empty body `{}`)

#### Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "Logout successful.",
  "traceId": "123e4567-e89b-12d3-a456-426614174000"
}
```

---

## 5. Post-Verification Profile Setup (Onboarding Flow)

When `isProfileSetup` is `false`, the client MUST navigate to the corresponding profile setup endpoint before opening the main dashboard.

### 5.1 Parent Profile Setup
- **Method**: `POST`
- **URL**: `/api/v1/profile/setup/parent`
- **Auth Required**: **Yes** (`Authorization: Bearer <accessToken>`)

#### Request Body
```json
{
  "avatarUrl": "https://alua-bucket.s3.amazonaws.com/attachments/parent-avatar.jpg",
  "address": "123 Main St, Springfield",
  "occupation": "Software Engineer",
  "relationWithChild": "Father"
}
```
*(All fields are optional, but completing setup marks `isProfileSetup = true`)*

#### Response (HTTP 200 OK)
Returns updated `SessionDTO` with `isProfileSetup: true` and populated `profileCompletedAt`.

---

### 5.2 Teacher Profile Setup
- **Method**: `POST`
- **URL**: `/api/v1/profile/setup/teacher`
- **Auth Required**: **Yes** (`Authorization: Bearer <accessToken>`)

#### Request Body
```json
{
  "avatarUrl": "https://alua-bucket.s3.amazonaws.com/attachments/teacher-avatar.jpg",
  "department": "Mathematics",
  "designation": "Senior Lecturer",
  "bio": "Experienced high school mathematics instructor with 8+ years experience."
}
```

#### Response (HTTP 200 OK)
Returns updated `SessionDTO` with `isProfileSetup: true` and populated `profileCompletedAt`.

---

## 6. Complete Flutter Implementation Blueprint

Below is the production-ready Dart / Flutter architecture tailored to the existing `aula_360_daniiru` codebase structure.

### 6.1 Recommended Directory Layout

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       <-- Update auth endpoints here
│   │   └── storage_keys.dart        <-- Storage keys for tokens & deviceId
│   ├── network/
│   │   ├── dio_client.dart          <-- Dio instance & base configs
│   │   ├── interceptors/
│   │   │   └── auth_interceptor.dart<-- Token injection & 401 handling
│   │   └── api_response.dart
│   └── storage/
│       └── secure_storage_service.dart
└── features/
    └── auth/
        ├── data/
        │   ├── models/
        │   │   ├── signup_request.dart
        │   │   ├── verify_request.dart
        │   │   ├── login_request.dart
        │   │   ├── check_session_request.dart
        │   │   └── session_dto.dart
        │   └── repositories/
        │       └── auth_repository.dart
        └── presentation/
            ├── controllers/
            └── screens/
```

---

### 6.2 Storage Keys & Device Identifier Helper

```dart
// lib/core/constants/storage_keys.dart
abstract final class StorageKeys {
  static const String accessToken = 'auth_access_token';
  static const String otpPageToken = 'auth_otp_page_token';
  static const String deviceIdentifier = 'app_device_identifier';
  static const String userRole = 'auth_user_role';
  static const String rememberMe = 'auth_remember_me';
  static const String cachedUser = 'auth_cached_user';
}
```

```dart
// lib/core/storage/device_id_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../constants/storage_keys.dart';

class DeviceIdHelper {
  final FlutterSecureStorage _storage;

  DeviceIdHelper(this._storage);

  /// Retrieves the existing device UUID or creates and saves a permanent one.
  Future<String> getOrCreateDeviceIdentifier() async {
    String? deviceId = await _storage.read(key: StorageKeys.deviceIdentifier);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      await _storage.write(key: StorageKeys.deviceIdentifier, value: deviceId);
    }
    return deviceId;
  }
}
```

---

### 6.3 Data Models

#### `SignupRequest`
```dart
// lib/features/auth/data/models/signup_request.dart
class SignupRequest {
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'PARENT' | 'TEACHER'
  final String password;
  final bool isLegalTermAccepted;

  const SignupRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
    this.isLegalTermAccepted = true,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName.trim(),
    'email': email.trim().toLowerCase(),
    'phone': phone.trim(),
    'role': role,
    'password': password.trim(),
    'isLegalTermAccepted': isLegalTermAccepted,
  };
}
```

#### `VerifyRequest`
```dart
// lib/features/auth/data/models/verify_request.dart
import 'dart:io';

class VerifyRequest {
  final String otp;
  final String deviceIdentifier;
  final String? fcmToken;
  final String platform; // 'ANDROID' | 'IOS'

  VerifyRequest({
    required this.otp,
    required this.deviceIdentifier,
    this.fcmToken,
    String? platform,
  }) : platform = platform ?? (Platform.isAndroid ? 'ANDROID' : 'IOS');

  Map<String, dynamic> toJson() => {
    'otp': otp.trim(),
    'deviceIdentifier': deviceIdentifier.trim(),
    if (fcmToken != null && fcmToken!.isNotEmpty) 'fcmToken': fcmToken!.trim(),
    'platform': platform,
  };
}
```

#### `LoginRequest`
```dart
// lib/features/auth/data/models/login_request.dart
import 'dart:io';

class LoginRequest {
  final String email;
  final String password;
  final String role; // 'PARENT' | 'TEACHER'
  final String deviceIdentifier;
  final String? fcmToken;
  final String platform; // 'ANDROID' | 'IOS'
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    required this.role,
    required this.deviceIdentifier,
    this.fcmToken,
    String? platform,
    this.rememberMe = false,
  }) : platform = platform ?? (Platform.isAndroid ? 'ANDROID' : 'IOS');

  Map<String, dynamic> toJson() => {
    'email': email.trim().toLowerCase(),
    'password': password.trim(),
    'role': role,
    'deviceIdentifier': deviceIdentifier.trim(),
    if (fcmToken != null && fcmToken!.isNotEmpty) 'fcmToken': fcmToken!.trim(),
    'platform': platform,
    'rememberMe': rememberMe,
  };
}
```

#### `SessionDTO`
```dart
// lib/features/auth/data/models/session_dto.dart
class SessionDTO {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String role;
  final String status;
  final bool isProfileSetup;
  final DateTime? profileCompletedAt;
  final String language;

  const SessionDTO({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.isProfileSetup,
    this.profileCompletedAt,
    required this.language,
  });

  factory SessionDTO.fromJson(Map<String, dynamic> json) {
    return SessionDTO(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString() ?? 'PARENT',
      status: json['status'] ?? json['accountStatus'] ?? 'ACTIVE',
      isProfileSetup: json['isProfileSetup'] == true,
      profileCompletedAt: json['profileCompletedAt'] != null
          ? DateTime.tryParse(json['profileCompletedAt'].toString())
          : null,
      language: json['language']?.toString() ?? 'EN',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'role': role,
    'status': status,
    'isProfileSetup': isProfileSetup,
    'profileCompletedAt': profileCompletedAt?.toIso8601String(),
    'language': language,
  };
}
```

---

### 6.4 API Constants Update

```dart
// lib/core/constants/api_constants.dart
abstract final class ApiConstants {
  static const String baseUrl = 'https://alua.localbox.online/api/v1';

  // Authentication
  static const String signup = '/auth/signup';
  static const String verify = '/auth/verify';
  static const String resend = '/auth/resend';
  static const String login = '/auth/login';
  static const String check = '/auth/check';
  static const String logout = '/auth/logout';

  // Profile Setup
  static const String setupParent = '/profile/setup/parent';
  static const String setupTeacher = '/profile/setup/teacher';
}
```

---

### 6.5 Auth Repository Implementation

```dart
// lib/features/auth/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/signup_request.dart';
import '../models/verify_request.dart';
import '../models/login_request.dart';
import '../models/session_dto.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository({required Dio dio, required FlutterSecureStorage storage})
      : _dio = dio,
        _storage = storage;

  /// 1. Signup - Returns temporary OTP page token and persists it
  Future<String> signup(SignupRequest request) async {
    final response = await _dio.post(
      ApiConstants.signup,
      data: request.toJson(),
    );

    final token = response.data['data']['token'] as String;
    await _storage.write(key: StorageKeys.otpPageToken, value: token);
    return token;
  }

  /// 2. Verify Signup OTP - Returns SessionDTO and saves permanent accessToken
  Future<SessionDTO> verifyOtp(VerifyRequest request) async {
    final otpToken = await _storage.read(key: StorageKeys.otpPageToken);

    final response = await _dio.post(
      ApiConstants.verify,
      data: request.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $otpToken',
        },
      ),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;

    // Save session access token and clear temporary OTP token
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.delete(key: StorageKeys.otpPageToken);

    return SessionDTO.fromJson(data);
  }

  /// 3. Resend OTP - Uses stored temporary OTP page token
  Future<void> resendOtp() async {
    final otpToken = await _storage.read(key: StorageKeys.otpPageToken);

    await _dio.post(
      ApiConstants.resend,
      options: Options(
        headers: {
          'Authorization': 'Bearer $otpToken',
        },
      ),
    );
  }

  /// 4. Login - Authenticates user, saves accessToken, and returns SessionDTO
  Future<SessionDTO> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    await _storage.write(key: StorageKeys.accessToken, value: token);
    await _storage.write(key: StorageKeys.rememberMe, value: request.rememberMe.toString());

    return SessionDTO.fromJson(userJson);
  }

  /// 5. Check Session - Validates existing token and optionally rotates FCM token
  Future<SessionDTO> checkSession({String? fcmToken}) async {
    final accessToken = await _storage.read(key: StorageKeys.accessToken);

    final response = await _dio.post(
      ApiConstants.check,
      data: {
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    final userJson = response.data['data'] as Map<String, dynamic>;
    return SessionDTO.fromJson(userJson);
  }

  /// 6. Logout - Blacklists token on backend and purges local credentials
  Future<void> logout() async {
    final accessToken = await _storage.read(key: StorageKeys.accessToken);

    try {
      if (accessToken != null) {
        await _dio.post(
          ApiConstants.logout,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
      }
    } catch (_) {
      // Continue with local cleanup even if network fails
    } finally {
      await _storage.delete(key: StorageKeys.accessToken);
      await _storage.delete(key: StorageKeys.otpPageToken);
      await _storage.delete(key: StorageKeys.cachedUser);
    }
  }
}
```

---

## 7. QA & Testing Checklist

- [ ] **Password Constraint UI**: Enforce client-side check matching backend regex: 6–16 chars, $\ge 1$ upper, $\ge 1$ lower, $\ge 1$ digit, $\ge 1$ special character before submitting `/auth/signup`.
- [ ] **E.164 Phone Format**: Prepend country code (`+`) on phone input.
- [ ] **OTP Timer (4 Minutes)**: Start a 240-second countdown upon landing on OTP screen. Disable Resend button until countdown expires.
- [ ] **Token Expiration on OTP Screen**: If user waits $>24\text{ hours}$ on OTP screen, catch `TOKEN_EXPIRED` and route back to Signup.
- [ ] **Duplicate Email Detection**: Handle HTTP 409 `DUPLICATE_DATA` by showing dialog redirecting to Login.
- [ ] **Multi-Device Login Override**: Verify that logging in on Device B marks Device A session as `REVOKED` (`NEW_LOGIN_SUPERSEDED`). Device A should be logged out gracefully on its next API call.
- [ ] **Profile Setup Routing Guard**: Confirm that when `isProfileSetup == false`, user cannot bypass to Dashboard and must complete parent/teacher profile setup first.
- [ ] **Logout Invalidation**: Confirm that after calling `/auth/logout`, re-using the old `accessToken` immediately returns `401 TOKEN_BLACKLISTED`.
