# Aula 360 — Parent Mobile App API Integration Guide

This guide is the complete, canonical integration reference for the **Aula 360 Parent Mobile Application**. All endpoints adhere to the OpenAPI 3.0 specification, use HTTPS, and enforce the standard response envelope.

---

## Global API Standards

### Base URL
- **Production / Staging API Host:** `https://alua.localbox.online/api/v1`
- **Swagger Documentation:** `https://alua.localbox.online/api-docs/#/`
- **WebSocket Gateway:** `wss://alua.localbox.online`

### Request Headers
| Header | Value / Description | Required On |
| :--- | :--- | :--- |
| `Content-Type` | `application/json` | All `POST` / `PATCH` requests |
| `Authorization` | `Bearer <ACCESS_TOKEN>` | All authenticated endpoints |
| `Accept` | `application/json` | All requests |

### Standard Response Envelope
Every API response from Aula 360 is wrapped in a consistent top-level JSON envelope:

```json
{
  "success": true,
  "message": "Operation description or user-friendly confirmation",
  "data": { ... },
  "meta": {
    "total": 45,
    "totalPages": 3,
    "links": {
      "currentPage": "http://api/v1/parent/children/UUID/attendance?page=1&limit=20",
      "nextPage": "http://api/v1/parent/children/UUID/attendance?page=2&limit=20",
      "previousPage": null,
      "firstPage": "http://api/v1/parent/children/UUID/attendance?page=1&limit=20",
      "lastPage": "http://api/v1/parent/children/UUID/attendance?page=3&limit=20"
    }
  },
  "traceId": "7d9283f2-8e12-429b-9c31-15bce6841203"
}
```

> **Note on `meta`:** The `meta` object is included on paginated endpoints. Certain endpoints (such as Child Attendance) also include custom aggregates (e.g., `meta.percentage`) within this object.

### Error Envelope
```json
{
  "success": false,
  "message": "Human-readable error description",
  "errorType": "VALIDATION_ERROR | NOT_FOUND | FORBIDDEN | UNAUTHORIZED",
  "errors": [
    {
      "field": "dob",
      "message": "Date of birth must be a valid ISO datetime"
    }
  ],
  "traceId": "c301d2a4-7932-441f-82ba-82390218b765"
}
```

---

## 1. Authentication & Session Management

Aula 360 employs JWT-based bearer authentication bound to hardware device sessions. Single device sign-on is enforced per device type; logging into a new device with the same identifier or same FCM token supersedes older sessions.

```
App Boot ─── Has Token? ─── No ───> Login Screen ─── POST /auth/login ─── Store Token & User
                │                                                              │
               Yes                                                             │
                │                                                              │
                ▼                                                              ▼
        POST /auth/check ─── Invalid / 401 ───> Re-Login          Dashboard (Child List)
                │
              Valid
                │
                ▼
      Dashboard (Child List)
```

### 1.1 Parent Login
Authenticates the parent and establishes an active device session.

- **Endpoint:** `POST /api/v1/auth/login`
- **Auth Required:** No

#### Request Body
```json
{
  "email": "sarah.parent@example.com",
  "password": "SecurePassword123!",
  "role": "PARENT",
  "deviceIdentifier": "c765952d-83b6-4993-bb5a-a3093202e811",
  "fcmToken": "eKz7x...fcm_registration_token",
  "platform": "ANDROID",
  "rememberMe": true
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `string` | **Yes** | Valid registered email (case-insensitive) |
| `password` | `string` | **Yes** | Account password |
| `role` | `string` | **Yes** | Must be strictly `"PARENT"` |
| `deviceIdentifier` | `string` | **Yes** | Unique device hardware identifier (UUID v4 / Secure.ANDROID_ID / IdentifierForVendor) |
| `fcmToken` | `string` | No | Firebase Cloud Messaging push token for background notifications |
| `platform` | `string` | **Yes** | `"ANDROID"` or `"IOS"` |
| `rememberMe` | `boolean` | No | Extends session validity (defaults to `false` = 7 days, `true` = 30 days) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "111e4567-e89b-12d3-a456-426614174000",
      "email": "sarah.parent@example.com",
      "phone": "+1234567890",
      "fullName": "Sarah Jenkins",
      "avatarUrl": "https://cdn.alua.edu/avatars/parent1.jpg",
      "role": "PARENT",
      "status": "ACTIVE",
      "isProfileSetup": true,
      "language": "EN"
    }
  },
  "traceId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d"
}
```

> **Client Integration Rule:**
> Store `data.token` securely in `FlutterSecureStorage`, Android `EncryptedSharedPreferences`, or iOS `Keychain`. Cache the `user` object in state to populate profile drawer/header widgets.

---

### 1.2 Check Session / App Boot
Validates that the stored token is active, verifies the account status, and refreshes the FCM push token on app start.

- **Endpoint:** `POST /api/v1/auth/check`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Request Body
```json
{
  "fcmToken": "eKz7x...new_fcm_token_if_rotated"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "User is authenticated.",
  "data": {
    "id": "111e4567-e89b-12d3-a456-426614174000",
    "email": "sarah.parent@example.com",
    "phone": "+1234567890",
    "fullName": "Sarah Jenkins",
    "avatarUrl": "https://cdn.alua.edu/avatars/parent1.jpg",
    "role": "PARENT",
    "status": "ACTIVE",
    "isProfileSetup": true,
    "language": "EN"
  },
  "traceId": "50c8ec8e-8a9d-478a-aef2-bc32223a8bf7"
}
```

---

### 1.3 Logout
Invalidates the current session on the backend and blacklists the access token in Redis.

- **Endpoint:** `POST /api/v1/auth/logout`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "User logged out successfully.",
  "traceId": "9e5a1b32-6a7f-412f-bda5-139b4b08dcf2"
}
```

> **Client Integration Rule:**
> Upon calling logout, clear all local secure storage keys, reset state managers (Bloc/Riverpod/Zustand), disconnect active WebSockets, and navigate to the Login screen.

---

## 2. Dashboard & Child Management

Parents can link multiple children. The core navigation model of the Parent app uses a **Child Switcher** pattern. All child-specific modules (Schedule, Attendance, Reports, Homework, Progress, Teachers) require passing the child's `id` in the URL path.

```
                  ┌──────────────────────────────┐
                  │   GET /parent/children       │
                  │   Returns: [ChildA, ChildB]  │
                  └──────────────┬───────────────┘
                                 │
                     User selects Child A (ID: "aaa-111")
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
GET /children/aaa-111/schedule  GET /children/aaa-111/attendance  GET /children/aaa-111/progress
```

### 2.1 Fetch Children
Retrieves all children registered under the authenticated parent.

- **Endpoint:** `GET /api/v1/parent/children`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Children retrieved successfully",
  "data": [
    {
      "id": "222e4567-e89b-12d3-a456-426614174001",
      "fullName": "Leo Jenkins",
      "gradeLevel": "Grade 5",
      "enrollmentNumber": "ALUA-2026-0042",
      "avatarUrl": "https://cdn.alua.edu/avatars/student1.jpg"
    },
    {
      "id": "333e4567-e89b-12d3-a456-426614174002",
      "fullName": "Mia Jenkins",
      "gradeLevel": "Grade 2",
      "enrollmentNumber": "ALUA-2026-0089",
      "avatarUrl": null
    }
  ],
  "traceId": "48fe1db9-9c5f-40e9-b59c-851f8dc1c744"
}
```

> **Client Integration Rule:**
> Store the returned array in global state. Select `data[0]` by default on initial app load. When the user taps the child switcher dropdown/carousel in the top app bar, update `selectedChildId` across your state store to re-fetch the active views.

---

### 2.2 Add Child
Allows a parent to register and link a new child to their profile.

- **Endpoint:** `POST /api/v1/parent/children`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)

#### Request Body
```json
{
  "fullName": "Noah Jenkins",
  "dob": "2018-05-14T00:00:00.000Z",
  "gender": "Male",
  "gradeLevel": "Grade 1",
  "enrollmentNumber": "ALUA-2026-0120",
  "avatarUrl": "https://cdn.alua.edu/avatars/noah.jpg"
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `fullName` | `string` | **Yes** | Child's full name |
| `dob` | `string` | No | Date of birth formatted as ISO 8601 (`YYYY-MM-DDTHH:mm:ss.sssZ`) |
| `gender` | `string` | No | Gender identifier (e.g. `"Male"`, `"Female"`) |
| `gradeLevel` | `string` | No | Current grade or educational level |
| `enrollmentNumber` | `string` | No | Unique student code (auto-generated if omitted) |
| `avatarUrl` | `string` | No | Valid image URL |

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Child added successfully",
  "data": {
    "id": "444e4567-e89b-12d3-a456-426614174003",
    "fullName": "Noah Jenkins",
    "gradeLevel": "Grade 1",
    "enrollmentNumber": "ALUA-2026-0120",
    "avatarUrl": "https://cdn.alua.edu/avatars/noah.jpg"
  },
  "traceId": "2bf2d098-b80c-43fe-a8c6-30230f898c6b"
}
```

---

## 3. Schedule & Attendance

### 3.1 Child Schedule
Fetches all scheduled class sessions for the child across their active cohorts, including subject, room, teacher, and entry/exit timestamps.

- **Endpoint:** `GET /api/v1/parent/children/:id/schedule`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)
- **URL Parameter:** `id` — Child Student UUID

#### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `fromDate` | `string` | No | Filter sessions starting on/after ISO timestamp (e.g., `2026-10-20T00:00:00.000Z`) |
| `toDate` | `string` | No | Filter sessions ending on/before ISO timestamp (e.g., `2026-10-27T23:59:59.999Z`) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Child schedule retrieved successfully",
  "data": [
    {
      "id": "555e4567-e89b-12d3-a456-426614174004",
      "scheduleId": "666e4567-e89b-12d3-a456-426614174005",
      "sessionDate": "2026-10-22T00:00:00.000Z",
      "startTime": "09:00",
      "endTime": "10:30",
      "status": "COMPLETED",
      "entryTime": "2026-10-22T08:55:00.000Z",
      "exitTime": "2026-10-22T10:32:00.000Z",
      "subjectName": "Mathematics",
      "cohortName": "5th Grade Alpha",
      "teacherName": "David Miller",
      "classroomRoomNumber": "Room 204"
    }
  ],
  "traceId": "91ae25c3-3051-409c-9c71-3315ec2ce64a"
}
```

---

### 3.2 Child Attendance (Paginated + Aggregate Percentage)
Retrieves historical attendance logs for a child. The attendance rate calculation (`PRESENT` + `LATE` / `total`) is returned directly in `meta.percentage`.

- **Endpoint:** `GET /api/v1/parent/children/:id/attendance`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)
- **URL Parameter:** `id` — Child Student UUID

#### Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `integer` | `1` | Page number |
| `limit` | `integer` | `20` | Items per page (max 100) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Child attendance retrieved successfully",
  "meta": {
    "total": 60,
    "totalPages": 3,
    "percentage": 95,
    "links": {
      "currentPage": "http://api/v1/parent/children/UUID/attendance?page=1&limit=20",
      "nextPage": "http://api/v1/parent/children/UUID/attendance?page=2&limit=20",
      "previousPage": null,
      "firstPage": "http://api/v1/parent/children/UUID/attendance?page=1&limit=20",
      "lastPage": "http://api/v1/parent/children/UUID/attendance?page=3&limit=20"
    }
  },
  "data": [
    {
      "id": "777e4567-e89b-12d3-a456-426614174006",
      "sessionDate": "2026-10-22T00:00:00.000Z",
      "subjectName": "Mathematics",
      "status": "PRESENT",
      "note": null
    },
    {
      "id": "778e4567-e89b-12d3-a456-426614174007",
      "sessionDate": "2026-10-21T00:00:00.000Z",
      "subjectName": "Science",
      "status": "LATE",
      "note": "Arrived 10 mins late with bus pass"
    }
  ],
  "traceId": "ef1e7bc8-a42e-48a5-ae15-9c8699e1ef6b"
}
```

> **Client Integration Note:**
> Read `meta.percentage` to display the circular progress indicator or attendance metric banner on the child overview screen without needing client-side arithmetic. Possible values for `status` are: `PRESENT`, `LATE`, `ABSENT`, `EXCUSED`.

---

## 4. Reports (Read-Only)

Teachers submit class session reports, which are reviewed and published by school administrators. Parents can **only view reports in `REVIEWED` status**. Draft or pending teacher reports are automatically excluded by the backend.

### 4.1 Fetch Child Reports
- **Endpoint:** `GET /api/v1/parent/children/:id/reports`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)
- **URL Parameter:** `id` — Child Student UUID

#### Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `integer` | `1` | Page number |
| `limit` | `integer` | `20` | Items per page (max 100) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Child reports retrieved successfully",
  "meta": {
    "total": 12,
    "totalPages": 1,
    "links": {
      "currentPage": "http://api/v1/parent/children/UUID/reports?page=1&limit=20",
      "nextPage": null,
      "previousPage": null,
      "firstPage": "http://api/v1/parent/children/UUID/reports?page=1&limit=20",
      "lastPage": "http://api/v1/parent/children/UUID/reports?page=1&limit=20"
    }
  },
  "data": [
    {
      "id": "888e4567-e89b-12d3-a456-426614174008",
      "date": "2026-10-22T00:00:00.000Z",
      "subjectName": "Science",
      "teacherName": "Elena Rostova",
      "contentCovered": "Photosynthesis laboratory experiment and leaf chlorophyll analysis.",
      "observations": "Leo collaborated exceptionally well during the group experiment.",
      "attitudeRating": "EXCELLENT",
      "workEffortRating": "HIGH_EFFORT"
    }
  ],
  "traceId": "c929a751-c0cf-468a-b9c1-1fb0db46d2cb"
}
```

| Field | Enum Values |
| :--- | :--- |
| `attitudeRating` | `NEEDS_ATTENTION`, `SATISFACTORY`, `EXCELLENT` |
| `workEffortRating` | `MODERATE`, `ON_TRACK`, `HIGH_EFFORT` |

---

## 5. Homework

### 5.1 Fetch Child Homework
Fetches homework assignments for cohorts where the child is enrolled, including the child's individual submission status.

- **Endpoint:** `GET /api/v1/parent/children/:id/homework`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)
- **URL Parameter:** `id` — Child Student UUID

#### Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `integer` | `1` | Page number |
| `limit` | `integer` | `20` | Items per page (max 100) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Child homework retrieved successfully",
  "meta": {
    "total": 4,
    "totalPages": 1,
    "links": {
      "currentPage": "http://api/v1/parent/children/UUID/homework?page=1&limit=20",
      "nextPage": null,
      "previousPage": null,
      "firstPage": "http://api/v1/parent/children/UUID/homework?page=1&limit=20",
      "lastPage": "http://api/v1/parent/children/UUID/homework?page=1&limit=20"
    }
  },
  "data": [
    {
      "id": "999e4567-e89b-12d3-a456-426614174009",
      "title": "Algebra Worksheet 4B",
      "description": "Complete problems 1 through 25 on page 112.",
      "subjectName": "Mathematics",
      "dueDate": "2026-10-25T23:59:59.000Z",
      "status": "PENDING"
    },
    {
      "id": "999e4567-e89b-12d3-a456-426614174010",
      "title": "Plant Cell Diagram",
      "description": "Draw and label organelle components.",
      "subjectName": "Science",
      "dueDate": "2026-10-20T23:59:59.000Z",
      "status": "COMPLETED"
    }
  ],
  "traceId": "b182cb08-a53d-4235-86f2-bf8984959db1"
}
```

> **Client Integration Note:**
> Use the `status` field (`"PENDING"` or `"COMPLETED"`) to filter assignments into "To Do" and "Completed" tab views.

---

## 6. Academic Progress & Teachers

### 6.1 Fetch Academic Progress
Provides a summary of overall progress for a child.

- **Endpoint:** `GET /api/v1/parent/children/:id/progress`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)
- **URL Parameter:** `id` — Child Student UUID

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Child progress retrieved successfully",
  "data": {
    "attendancePercentage": 96,
    "homeworkCompletionPercentage": 88,
    "subjects": [
      "Mathematics",
      "Science",
      "English Literature",
      "History"
    ]
  },
  "traceId": "fa912c98-1029-4556-9a29-0129bc81726a"
}
```

> **CRITICAL ARCHITECTURAL CONSTRAINT:**
> Aula 360 intentionally **does not compute or return GPA or letter grades** on this endpoint. The mobile client must only display `attendancePercentage` and `homeworkCompletionPercentage` as metric rings/bars, along with the list of enrolled `subjects`.

---

### 6.2 Fetch Child Teachers
Retrieves the list of active instructors teaching the child.

- **Endpoint:** `GET /api/v1/parent/children/:id/teachers`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)
- **URL Parameter:** `id` — Child Student UUID

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Child teachers retrieved successfully",
  "data": [
    {
      "id": "aaa4567-e89b-12d3-a456-426614174011",
      "fullName": "Elena Rostova",
      "email": "elena.rostova@alua.edu",
      "designation": "Head of Science Department",
      "bio": "M.Sc. in Cellular Biology with 10 years of secondary education experience.",
      "avatarUrl": "https://cdn.alua.edu/avatars/teacher1.jpg"
    }
  ],
  "traceId": "1a8b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"
}
```

---

## 7. Finance & Payments (Stripe)

Tuition and school fees are tracked via Invoices. The payment workflow leverages the **Stripe Payment Sheet SDK** via a server-generated `clientSecret`.

```
Parent taps "Pay Now" ───> POST /parent/invoices/:id/pay ───> Returns { clientSecret }
                                                                     │
Stripe Webhook (Cloud) <─── Process Card / Apple / Google Pay <───────┘
          │
Updates Invoice to "PAID"
Dispatches Push Notification
```

### 7.1 Fetch Invoices
- **Endpoint:** `GET /api/v1/parent/invoices`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)

#### Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `status` | `string` | Optional | Filter by: `PENDING`, `PAID`, `OVERDUE`, `CANCELLED` |
| `page` | `integer` | `1` | Page number |
| `limit` | `integer` | `20` | Items per page (max 100) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Parent invoices retrieved successfully",
  "meta": {
    "total": 3,
    "totalPages": 1,
    "links": {
      "currentPage": "http://api/v1/parent/invoices?page=1&limit=20",
      "nextPage": null,
      "previousPage": null,
      "firstPage": "http://api/v1/parent/invoices?page=1&limit=20",
      "lastPage": "http://api/v1/parent/invoices?page=1&limit=20"
    }
  },
  "data": [
    {
      "id": "bbb4567-e89b-12d3-a456-426614174012",
      "feeId": "ccc4567-e89b-12d3-a456-426614174013",
      "feeTitle": "Term 1 Tuition Fee",
      "studentId": "222e4567-e89b-12d3-a456-426614174001",
      "studentName": "Leo Jenkins",
      "amount": 450,
      "currency": "USD",
      "dueDate": "2026-11-01T00:00:00.000Z",
      "status": "PENDING",
      "paidAt": null
    }
  ],
  "traceId": "7f8a9b0c-1d2e-3f4a-5b6c-7d8e9f0a1b2c"
}
```

---

### 7.2 Initialize Payment (Stripe Payment Intent)
Generates a Stripe `clientSecret` for an invoice that is in `PENDING` status.

- **Endpoint:** `POST /api/v1/parent/invoices/:id/pay`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)
- **URL Parameter:** `id` — Invoice UUID

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Payment intent initialized successfully",
  "data": {
    "clientSecret": "pi_3MtwxAEhygioSLnk1McueAMV_secret_m1uytxPqQSvOvgQI"
  },
  "traceId": "3d4e5f6a-7b8c-9d0e-1f2a-3b4c5d6e7f8a"
}
```

#### Mobile Stripe Integration Code (Flutter / React Native Example)
```dart
// 1. Request clientSecret from backend
final response = await dio.post('/api/v1/parent/invoices/$invoiceId/pay');
final clientSecret = response.data['data']['clientSecret'];

// 2. Initialize Stripe Payment Sheet
await Stripe.instance.initPaymentSheet(
  paymentSheetParameters: SetupPaymentSheetParameters(
    paymentIntentClientSecret: clientSecret,
    merchantDisplayName: 'Aula 360 Academy',
    style: ThemeMode.system,
  ),
);

// 3. Present Payment Sheet to parent
try {
  await Stripe.instance.presentPaymentSheet();
  // 4. Payment succeeded on device:
  // Re-fetch invoices to display the updated "PAID" state (confirmed via webhook).
  fetchInvoices();
} on StripeException catch (e) {
  // Handle cancellation or payment decline
}
```

---

## 8. Real-Time Communication (WebSockets)

Aula 360 uses **Socket.IO** for live bi-directional updates. To guarantee atomic database delivery, **messages are sent via REST (`POST`), and received in real-time via WebSockets**.

### 8.1 Gateway & Namespaces
Connect using the Socket.IO client library (v4):

- **Chat Gateway URL:** `wss://alua.localbox.online/api/v1/chat`
- **Notification Gateway URL:** `wss://alua.localbox.online/api/v1/notification`

#### Connection Options
```javascript
import { io } from "socket.io-client";

const chatSocket = io("https://alua.localbox.online/api/v1/chat", {
  auth: {
    token: "<ACCESS_TOKEN>" // raw JWT string
  },
  transports: ["websocket"]
});
```

### 8.2 Room Joining
When you connect, the server automatically joins your socket to your private channel:
- `user:<YOUR_USER_ID>`

To listen for messages inside a specific conversation view, emit:
```javascript
// Join a conversation room
chatSocket.emit("conversation:join", { conversationId: "UUID" });

// Leave when navigating away
chatSocket.emit("conversation:leave", { conversationId: "UUID" });
```

### 8.3 Supported Socket Events

| Direction | Event Name | Payload | Description |
| :--- | :--- | :--- | :--- |
| **Server → Client** | `new_message` | `MessageDTO` | Broadcast when a new message is posted in the conversation |
| **Server → Client** | `new_conversation` | `ConversationDTO` | Emitted when an Admin starts a chat with the Parent |
| **Client → Server** | `typing:start` | `{ conversationId: "UUID" }` | Emits typing indicator to recipient |
| **Client → Server** | `typing:stop` | `{ conversationId: "UUID" }` | Clears typing indicator |
| **Server → Client** | `typing:start-response`| `{ userId, name, avatar }` | Displays "Admin is typing..." |
| **Client → Server** | `message:read` | `{ conversationId: "UUID" }` | Marks messages read in chat |
| **Server → Client** | `notification:count-response`| `{ count: number }` | Emitted on `/api/v1/notification` connection |

---

### 8.4 REST Messaging Fallback / Send Endpoints

#### Fetch Conversations
- **Endpoint:** `GET /api/v1/conversations`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Send Message
- **Endpoint:** `POST /api/v1/conversations/:id/messages`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`
- **URL Parameter:** `id` — Conversation UUID

```json
{
  "body": "Good morning. Leo will be absent tomorrow due to a dental appointment."
}
```

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "id": "ddd4567-e89b-12d3-a456-426614174014",
    "conversationId": "eee4567-e89b-12d3-a456-426614174015",
    "senderId": "111e4567-e89b-12d3-a456-426614174000",
    "body": "Good morning. Leo will be absent tomorrow due to a dental appointment.",
    "attachmentUrl": null,
    "sentAt": "2026-10-22T10:15:00.000Z",
    "sender": {
      "id": "111e4567-e89b-12d3-a456-426614174000",
      "fullName": "Sarah Jenkins",
      "avatarUrl": "https://cdn.alua.edu/avatars/parent1.jpg"
    }
  },
  "traceId": "5f6a7b8c-9d0e-1f2a-3b4c-5d6e7f8a9b0c"
}
```

---

## 9. Notifications

### 9.1 Fetch Unread Count
Powers the notification bell counter badge in the mobile top navigation.

- **Endpoint:** `GET /api/v1/notifications/unread-count`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Unread notification count retrieved successfully",
  "data": {
    "count": 3
  },
  "traceId": "7c8d9e0f-1a2b-3c4d-5e6f-7a8b9c0d1e2f"
}
```

---

### 9.2 List Notifications
- **Endpoint:** `GET /api/v1/notifications`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `integer` | `1` | Page number |
| `limit` | `integer` | `20` | Items per page |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "meta": {
    "total": 1,
    "totalPages": 1,
    "links": { ... }
  },
  "data": [
    {
      "id": "fff4567-e89b-12d3-a456-426614174016",
      "notificationType": "REPORT_REVIEWED",
      "notificationTitle": "New Class Report Published",
      "notificationDescription": "A new reviewed report for Science has been published for Leo.",
      "isRead": false,
      "createdAt": "2026-10-22T08:30:00.000Z"
    }
  ],
  "traceId": "8d9e0f1a-2b3c-4d5e-6f7a-8b9c0d1e2f3a"
}
```

---

### 9.3 Mark Single Notification Read
- **Endpoint:** `PATCH /api/v1/notifications/:id/read`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Notification marked as read successfully",
  "data": {
    "id": "fff4567-e89b-12d3-a456-426614174016",
    "isRead": true
  },
  "traceId": "9e0f1a2b-3c4d-5e6f-7a8b-9c0d1e2f3a4b"
}
```

---

### 9.4 Mark All Notifications Read
- **Endpoint:** `PATCH /api/v1/notifications/read-all`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "All notifications marked as read successfully",
  "data": {
    "count": 3
  },
  "traceId": "0f1a2b3c-4d5e-6f7a-8b9c-0d1e2f3a4b5c"
}
```

---

## 10. Settings & Profile

### 10.1 Get User Settings
- **Endpoint:** `GET /api/v1/settings`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Settings retrieved successfully",
  "data": {
    "language": "EN"
  },
  "traceId": "1b2c3d4e-5f6a-7b8c-9d0e-1f2a3b4c5d6e"
}
```

---

### 10.2 Change Language Preference
- **Endpoint:** `POST /api/v1/settings/language`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Request Body
```json
{
  "language": "ES"
}
```
*(Accepts `"EN"` or `"ES"`)*

---

### 10.3 Change Password
- **Endpoint:** `POST /api/v1/settings/password`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Request Body
```json
{
  "currentPassword": "SecurePassword123!",
  "newPassword": "BrandNewPassword2026!"
}
```

| Field | Constraints |
| :--- | :--- |
| `newPassword` | 8–32 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character |

---

### 10.4 View & Edit Parent Profile

#### Fetch Profile
- **Endpoint:** `GET /api/v1/profile/parent`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)

```json
{
  "success": true,
  "message": "Parent profile retrieved successfully.",
  "data": {
    "id": "111e4567-e89b-12d3-a456-426614174000",
    "fullName": "Sarah Jenkins",
    "email": "sarah.parent@example.com",
    "phone": "+1234567890",
    "avatarUrl": "https://cdn.alua.edu/avatars/parent1.jpg",
    "role": "PARENT",
    "status": "ACTIVE",
    "occupation": "Pediatrician",
    "address": "742 Evergreen Terrace",
    "relationWithChild": "Mother"
  },
  "traceId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f"
}
```

#### Update Profile
- **Endpoint:** `POST /api/v1/profile/parent`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `PARENT`)

#### Request Body
```json
{
  "fullName": "Sarah Jenkins, M.D.",
  "phone": "+1234567899",
  "avatarUrl": "https://cdn.alua.edu/avatars/parent1_new.jpg",
  "occupation": "Chief of Pediatrics",
  "address": "742 Evergreen Terrace, Springfield",
  "relationWithChild": "Mother"
}
```
*(All fields are optional in the update payload).*

---

## 11. Complete Integration Checklist for Mobile Devs

- [ ] **Token Storage:** Implement secure local storage for the JWT access token.
- [ ] **Auth Interceptor:** Configure an HTTP interceptor that attaches `Authorization: Bearer <TOKEN>` and gracefully redirects to `/login` upon receiving `401 Unauthorized`.
- [ ] **FCM Background Notification:** Pass `fcmToken` and `deviceIdentifier` in `POST /auth/login` and `POST /auth/check`.
- [ ] **Child Switcher State:** Call `GET /parent/children` on app boot; set `selectedChildId` to drive tabs.
- [ ] **Attendance Percentage:** Read `meta.percentage` directly from `GET /parent/children/:id/attendance`.
- [ ] **Progress Display:** Display `attendancePercentage` and `homeworkCompletionPercentage` as metric rings; do not show letter grades/GPA.
- [ ] **Stripe PaymentSheet:** Use `POST /parent/invoices/:id/pay` to retrieve `clientSecret` and mount native Apple Pay/Google Pay via Stripe SDK.
- [ ] **Socket Setup:** Establish connections to both `/api/v1/chat` and `/api/v1/notification` using the access token in `handshake.auth.token`.
- [ ] **Message Fallback:** Emit real-time messages via `POST /conversations/:id/messages` and listen on socket event `new_message`.
