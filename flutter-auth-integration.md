# Flutter Authentication Integration Guide

This guide documents the integration of the three authentication endpoints for the ALUA Academy Management mobile application (Flutter).

---

## 1. Authentication Lifecycle & Architecture

The registration and verification process uses a **Two-Token Architecture**:

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
       │ (User enters OTP)                      │ (User taps "Resend OTP")
       ▼ POST /api/v1/auth/verify               ▼ POST /api/v1/auth/resend
  Header: Authorization: Bearer <data.token>      Header: Authorization: Bearer <data.token>
  Body: { otp, deviceIdentifier, ... }            (No request body)
       │                                        │
       ▼ Returns `data.accessToken`             ▼ Generates new OTP, resets expiry timer
[ Authenticated Home / Dashboard ]
(Store accessToken securely in flutter_secure_storage)
```

### Key Rules for the Mobile App:
1. **`token` (from `/auth/signup`)**: This is a temporary, restricted token whose only purpose is authorizing the `/auth/verify` and `/auth/resend` endpoints. **Do not** use this token for general authenticated APIs.
2. **`accessToken` (from `/auth/verify`)**: This is the full user JWT session token. Store it securely (e.g. `flutter_secure_storage`) and attach it as `Authorization: Bearer <accessToken>` on all standard protected APIs.
3. **Session Invalidation**: When `/auth/verify` completes, the temporary OTP token is permanently blacklisted on the server.

---

## 2. Base Configuration

- **Base URL (Local/Dev)**: `https://alua.localbox.online/api/v1`
- **Default Headers**:
  ```http
  Content-Type: application/json
  Accept: application/json
  ```

---

## 3. Standard Response Envelopes

All backend endpoints respond using standard envelopes.

### Success Envelope
```json
{
  "success": true,
  "message": "Human-readable success message",
  "data": { ... },
  "traceId": "225d89f7-6fc1-4f0e-bfdd-5a67999390e1"
}
```

### Business / Auth / System Error Envelope
```json
{
  "success": false,
  "message": "Human-readable error description",
  "errorType": "ERROR_ENUM_CODE",
  "traceId": "225d89f7-6fc1-4f0e-bfdd-5a67999390e1"
}
```

### Validation Error Envelope (HTTP 422)
```json
{
  "success": false,
  "message": "Request body validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address"
    }
  ],
  "traceId": "225d89f7-6fc1-4f0e-bfdd-5a67999390e1"
}
```

---

## 4. Endpoints Reference

### 4.1 Signup User
Registers a new account as either a `PARENT` or `TEACHER`, sends a 6-digit OTP to their email, and returns a temporary token for the OTP screen.

- **URL**: `/auth/signup`
- **Method**: `POST`
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

| Field | Type | Required | Validation / Rules |
| :--- | :--- | :--- | :--- |
| `fullName` | String | Yes | Minimum 1 character. Trimmed. |
| `email` | String | Yes | Valid email format. Lowercased and trimmed. |
| `phone` | String | Yes | Regex: `^\+?[1-9]\d{1,14}$` (E.164 compliant phone number). |
| `role` | String | Yes | Must be `"PARENT"` or `"TEACHER"`. |
| `password` | String | Yes | 6 to 16 characters. Must contain: $\ge 1$ uppercase, $\ge 1$ lowercase, $\ge 1$ digit, $\ge 1$ special character. |
| `isLegalTermAccepted` | Boolean | Yes | Must be `true`. |

#### Response (HTTP 201 Created)
```json
{
  "success": true,
  "message": "Signup successful,Please check you email for otp to verify your account!",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "traceId": "b1b7ef89-8d8e-4a6f-9988-82e7834a34b2"
}
```

#### Possible Errors
| HTTP Status | `errorType` | Cause / Meaning |
| :--- | :--- | :--- |
| `400` | `INVALID_JSON` | Malformed JSON in request payload. |
| `409` | `DUPLICATE_DATA` | User with this email already exists in the system. |
| `422` | *(None, uses `errors` array)* | Validation failed on one or more payload fields. |
| `500` | `SERVER_ERROR` | Internal server error. |

---

### 4.2 Verify Signup User (Submit OTP)
Submits the 6-digit OTP code to verify the account. Upon success, marks the account `ACTIVE`, registers the mobile device session, invalidates the OTP, blacklists the temporary OTP token, and returns the full `accessToken`.

- **URL**: `/auth/verify`
- **Method**: `POST`
- **Auth Required**: **Yes** (Bearer Token from `/auth/signup`)
- **Headers**:
  ```http
  Authorization: Bearer <data.token>
  ```

#### Request Body
```json
{
  "otp": "123456",
  "deviceIdentifier": "unique-hardware-or-app-install-id",
  "fcmToken": "fcm_push_token_here",
  "platform": "ANDROID"
}
```

| Field | Type | Required | Validation / Rules |
| :--- | :--- | :--- | :--- |
| `otp` | String | Yes | 6-digit code received via email. |
| `deviceIdentifier` | String | Yes | Unique device UUID (persisted in app local storage). |
| `fcmToken` | String | Yes | Firebase Cloud Messaging device push token. |
| `platform` | String | Yes | Must be `"ANDROID"` or `"IOS"`. |

#### Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "User verification successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "isProfileSetup": true,
    "role": "PARENT",
    "accountStatus": "ACTIVE",
    "id": "e67b2d56-424a-4bbf-8549-ec78df903789",
    "fullName": "John Doe",
    "avatarUrl": null
  },
  "traceId": "c88b7722-12f4-42b1-91a5-83f5d5b7681c"
}
```

#### Possible Errors
| HTTP Status | `errorType` | Cause / Meaning |
| :--- | :--- | :--- |
| `400` | `INVALID_JSON` | Malformed JSON in request payload. |
| `401` | `TOKEN_INVALID` | Authorization token was not provided or is invalid. |
| `401` | `TOKEN_EXPIRED` | The temporary OTP page token has expired. User must sign in or register again. |
| `401` | `TOKEN_BLACKLISTED` | The temporary token has already been used or revoked. |
| `401` | `OTP_EXPIRED` | The 6-digit OTP has expired. Show button to call `/auth/resend`. |
| `401` | `INVALID_OTP` | The entered OTP does not match. Let the user re-enter. |
| `404` | `USER_NOT_FOUND` | User associated with the token does not exist in database. |
| `422` | *(None, uses `errors` array)* | Request body validation failed (e.g. invalid platform string). |
| `500` | `SERVER_ERROR` | Internal server error. |

---

### 4.3 Resend Verification OTP
Generates a fresh 6-digit OTP, invalidates any previous OTP, restarts the expiry countdown (typically 5 minutes), and sends an email to the user.

- **URL**: `/auth/resend`
- **Method**: `POST`
- **Auth Required**: **Yes** (Bearer Token from `/auth/signup`)
- **Headers**:
  ```http
  Authorization: Bearer <data.token>
  ```
- **Request Body**: None (Empty body)

#### Response (HTTP 200 OK)
```json
{
  "success": true,
  "message": "Signup verification otp resend successful!",
  "traceId": "d34b8c91-95c2-47ef-8cf2-99071db5583b"
}
```

#### Possible Errors
| HTTP Status | `errorType` | Cause / Meaning |
| :--- | :--- | :--- |
| `401` | `TOKEN_INVALID` | Authorization token was not provided or is invalid. |
| `401` | `TOKEN_EXPIRED` | The temporary OTP page token has expired. |
| `401` | `TOKEN_BLACKLISTED` | The temporary token was already used or revoked. |
| `404` | `USER_NOT_FOUND` | User account not found in database. |
| `500` | `SERVER_ERROR` | Internal server error. |

---

## 5. Dart / Flutter Integration Models & Services

Below are sample models and a service class using `dio`:

### 5.1 Models

```dart
// signup_request.dart
class SignupRequest {
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'PARENT' or 'TEACHER'
  final String password;
  final bool isLegalTermAccepted;

  SignupRequest({
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

// verify_request.dart
import 'dart:io';

class VerifyRequest {
  final String otp;
  final String deviceIdentifier;
  final String fcmToken;
  final String platform; // 'ANDROID' or 'IOS'

  VerifyRequest({
    required this.otp,
    required this.deviceIdentifier,
    required this.fcmToken,
    String? platform,
  }) : platform = platform ?? (Platform.isAndroid ? 'ANDROID' : 'IOS');

  Map<String, dynamic> toJson() => {
    'otp': otp.trim(),
    'deviceIdentifier': deviceIdentifier.trim(),
    'fcmToken': fcmToken.trim(),
    'platform': platform,
  };
}

// user_auth_session.dart
class UserAuthSession {
  final String accessToken;
  final bool isProfileSetup;
  final String role;
  final String accountStatus;
  final String id;
  final String fullName;
  final String? avatarUrl;

  UserAuthSession({
    required this.accessToken,
    required this.isProfileSetup,
    required this.role,
    required this.accountStatus,
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory UserAuthSession.fromJson(Map<String, dynamic> json) => UserAuthSession(
    accessToken: json['accessToken'] as String,
    isProfileSetup: json['isProfileSetup'] as bool? ?? false,
    role: json['role'] as String,
    accountStatus: json['accountStatus'] as String,
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );
}
```

### 5.2 Dio Auth Service Example

```dart
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ));

  /// Step 1: Signup -> Returns temporary OTP token
  Future<String> signup(SignupRequest request) async {
    final response = await _dio.post('/auth/signup', data: request.toJson());

    if (response.statusCode == 201) {
      return response.data['data']['token'] as String;
    } else {
      throw _parseError(response);
    }
  }

  /// Step 2: Verify OTP -> Returns full UserAuthSession
  Future<UserAuthSession> verify({
    required String otpToken,
    required VerifyRequest request,
  }) async {
    final response = await _dio.post(
      '/auth/verify',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $otpToken'}),
    );

    if (response.statusCode == 200) {
      return UserAuthSession.fromJson(response.data['data']);
    } else {
      throw _parseError(response);
    }
  }

  /// Step 3: Resend OTP
  Future<void> resendOtp({required String otpToken}) async {
    final response = await _dio.post(
      '/auth/resend',
      options: Options(headers: {'Authorization': 'Bearer $otpToken'}),
    );

    if (response.statusCode != 200) {
      throw _parseError(response);
    }
  }

  Exception _parseError(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? 'An error occurred';
      final errorType = data['errorType'];
      return ApiException(message: message, errorType: errorType, statusCode: response.statusCode);
    }
    return ApiException(message: 'Unknown error', statusCode: response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final String? errorType;
  final int? statusCode;

  ApiException({required this.message, this.errorType, this.statusCode});

  @override
  String toString() => 'ApiException [$statusCode | $errorType]: $message';
}
```
