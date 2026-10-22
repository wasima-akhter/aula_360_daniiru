# Aula 360 — Teacher Mobile App API Integration Guide

This guide is the complete, canonical integration reference for the **Aula 360 Teacher Mobile Application**. All endpoints adhere to the OpenAPI 3.0 specification, use HTTPS, enforce JWT authentication bound to hardware device sessions, and return responses wrapped in the standard API envelope.

---

## Global API Standards

### Base URL
- **Production / Staging API Host:** `https://alua.localbox.online/api/v1`
- **Swagger / OpenAPI Documentation:** `https://alua.localbox.online/api-docs/#/`
- **WebSocket Gateway:** `wss://alua.localbox.online`

### Request Headers
| Header | Value / Description | Required On |
| :--- | :--- | :--- |
| `Content-Type` | `application/json` | All `POST`, `PATCH`, `PUT` requests |
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
    "total": 35,
    "totalPages": 2,
    "links": {
      "currentPage": "http://api/v1/teacher/students?page=1&limit=20",
      "nextPage": "http://api/v1/teacher/students?page=2&limit=20",
      "previousPage": null,
      "firstPage": "http://api/v1/teacher/students?page=1&limit=20",
      "lastPage": "http://api/v1/teacher/students?page=2&limit=20"
    }
  },
  "traceId": "7d9283f2-8e12-429b-9c31-15bce6841203"
}
```

> **Note on `meta`:** The `meta` object is included on paginated endpoints. If the endpoint is unpaginated or returns a single entity, `meta` is omitted.

### Standard Error Envelope
When a request fails, the server returns an HTTP 4xx or 5xx code with a structured error envelope:

```json
{
  "success": false,
  "message": "Human-readable error description",
  "errorType": "VALIDATION_ERROR | NOT_FOUND | FORBIDDEN | BAD_REQUEST | UNAUTHORIZED",
  "errors": [
    {
      "field": "attendance.0.status",
      "message": "Attendance status must be one of: PRESENT, ABSENT, LATE, EXCUSED"
    }
  ],
  "traceId": "c301d2a4-7932-441f-82ba-82390218b765"
}
```

---

## 1. Authentication & Session Management

Aula 360 enforces JWT-based bearer authentication bound to hardware device identifiers. Single device sign-on is enforced per platform; logging into a new device with the same identifier or rotating FCM tokens refreshes the active device session and supersedes older sessions.

### Application Boot & Authentication Lifecycle
```
App Boot ─── Has Token? ─── No ───> Login Screen ─── POST /auth/login ─── Store Token & User
                │                                                              │
               Yes                                                             │
                │                                                              │
                ▼                                                              ▼
        POST /auth/check ─── Invalid / 401 ───> Re-Login            Dashboard (Today's Sessions)
                │
              Valid
                │
                ▼
      Dashboard (Today's Sessions)
```

---

### 1.1 Teacher Login
Authenticates the teacher and establishes an active device session.

- **Endpoint:** `POST /api/v1/auth/login`
- **Auth Required:** No

#### Request Body
```json
{
  "email": "sarah.jenkins@aula360.edu",
  "password": "TeacherPassword123!",
  "role": "TEACHER",
  "deviceIdentifier": "d820f12a-45c1-4b77-802c-7338012bb491",
  "fcmToken": "eKz7x...fcm_registration_token",
  "platform": "ANDROID",
  "rememberMe": true
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `string` | **Yes** | Valid registered email address (case-insensitive) |
| `password` | `string` | **Yes** | Account password |
| `role` | `string` | **Yes** | Must be strictly `"TEACHER"` |
| `deviceIdentifier` | `string` | **Yes** | Unique hardware device UUID (`Secure.ANDROID_ID` / `IdentifierForVendor`) |
| `fcmToken` | `string` | No | Firebase Cloud Messaging push token for background alerts |
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
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "sarah.jenkins@aula360.edu",
      "phone": "+15552045",
      "fullName": "Dr. Sarah Jenkins",
      "avatarUrl": "https://cdn.alua.edu/avatars/teacher1.jpg",
      "role": "TEACHER",
      "status": "ACTIVE",
      "isProfileSetup": true,
      "language": "EN"
    }
  },
  "traceId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d"
}
```

> **Client Integration Rule:**
> Store `data.token` securely in `FlutterSecureStorage` (Flutter), Android `EncryptedSharedPreferences`, or iOS `Keychain`. Cache the `user` object in app memory to populate navigation headers and profile avatars.

---

### 1.2 Check Session / App Boot
Validates that the stored token is active, checks account standing, and refreshes the FCM push token upon app boot or resume.

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
  "message": "Session is valid.",
  "data": {
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "sarah.jenkins@aula360.edu",
      "phone": "+15552045",
      "fullName": "Dr. Sarah Jenkins",
      "avatarUrl": "https://cdn.alua.edu/avatars/teacher1.jpg",
      "role": "TEACHER",
      "status": "ACTIVE",
      "isProfileSetup": true,
      "language": "EN"
    }
  },
  "traceId": "a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d"
}
```

> **Client Handling for 401 Unauthorized:**
> If `POST /auth/check` returns `401 Unauthorized` (`TOKEN_EXPIRED`, `TOKEN_INVALID`, or `SESSION_REVOKED`), immediately clear local storage and navigate the user to the Login screen.

---

### 1.3 Logout
Invalidates the current hardware session and revokes the device's FCM push subscription.

- **Endpoint:** `POST /api/v1/auth/logout`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Request Body
```json
{
  "deviceIdentifier": "d820f12a-45c1-4b77-802c-7338012bb491",
  "fcmToken": "eKz7x...fcm_registration_token"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Logged out successfully.",
  "data": null,
  "traceId": "b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e"
}
```

---

## 2. Dashboard & Today's Sessions

The Teacher Dashboard focuses on the teacher's daily timetable. The mobile app loads sessions for the current day and uses the `status` field to drive dynamic action buttons, timers, and badges.

### 2.1 Fetch Today's Sessions
Retrieves all class sessions scheduled for the authenticated teacher on the specified calendar date.

- **Endpoint:** `GET /api/v1/teacher/sessions`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)

#### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `date` | `string (ISO datetime)` | No | Target date (e.g. `2026-10-22T00:00:00.000Z`). If omitted, defaults to the current day in UTC. |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Teacher sessions retrieved successfully",
  "data": [
    {
      "id": "222e4567-e89b-12d3-a456-426614174001",
      "scheduleId": "333e4567-e89b-12d3-a456-426614174002",
      "sessionDate": "2026-10-22T00:00:00.000Z",
      "startTime": "09:00",
      "endTime": "10:30",
      "status": "SCHEDULED",
      "entryTime": null,
      "exitTime": null,
      "subjectName": "Advanced Mathematics",
      "cohortName": "Cohort 10-A",
      "teacherName": "Dr. Sarah Jenkins",
      "classroomRoomNumber": "Room 204"
    },
    {
      "id": "222e4567-e89b-12d3-a456-426614174002",
      "scheduleId": "333e4567-e89b-12d3-a456-426614174003",
      "sessionDate": "2026-10-22T00:00:00.000Z",
      "startTime": "11:00",
      "endTime": "12:30",
      "status": "ONGOING",
      "entryTime": "2026-10-22T11:02:14.000Z",
      "exitTime": null,
      "subjectName": "Physics & Mechanics",
      "cohortName": "Cohort 11-B",
      "teacherName": "Dr. Sarah Jenkins",
      "classroomRoomNumber": "Lab 3"
    },
    {
      "id": "222e4567-e89b-12d3-a456-426614174003",
      "scheduleId": "333e4567-e89b-12d3-a456-426614174004",
      "sessionDate": "2026-10-22T00:00:00.000Z",
      "startTime": "14:00",
      "endTime": "15:30",
      "status": "COMPLETED",
      "entryTime": "2026-10-22T14:00:10.000Z",
      "exitTime": "2026-10-22T15:28:45.000Z",
      "subjectName": "AP Calculus BC",
      "cohortName": "Cohort 12-A",
      "teacherName": "Dr. Sarah Jenkins",
      "classroomRoomNumber": "Room 101"
    }
  ],
  "traceId": "c4d5e6f7-a8b9-0c1d-2e3f-4a5b6c7d8e9f"
}
```

---

### 2.2 How the `status` Field Drives Mobile UI State

The `status` attribute on each `SessionDTO` dictates the mobile card styling and primary Call-To-Action (CTA):

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           Session State Machine                           │
└───────────────────────────────────────────────────────────────────────────┘
       SCHEDULED ────────> ONGOING ────────> COMPLETED
           │
           └─────────────> CANCELLED
```

| Status | Badge Color / Icon | Action Button(s) Enabled | Behavior & Screen Transitions |
| :--- | :--- | :--- | :--- |
| `SCHEDULED` | Blue / Calendar | **"Start Class"** | Clicking calls `POST /teacher/sessions/:id/start`. Attendance and Report buttons remain locked. |
| `ONGOING` | Pulsing Green / Clock | **"Take Attendance"**<br>**"End Class & Report"** | Clicking "Take Attendance" opens the Student Roster sheet. Clicking "End Class" opens the Report submission modal. Live class duration counter displays `now - entryTime`. |
| `COMPLETED` | Gray / Checkmark | **"View Summary"** (Read-Only) | Class has concluded and report was submitted. Cards display total attendance count. Inputs are disabled. |
| `CANCELLED` | Red / Slotted Cross | *None (Disabled)* | Greyed-out card indicating class was rescheduled or cancelled by administration. |

---

## 3. Session Execution Flow (The Core Loop)

The core classroom loop enables teachers to start a scheduled session, take and modify student attendance, and finalize the class by submitting an end-of-class report.

```
Step 1: Fetch Session Details & Roster
        GET /teacher/sessions/:id
                 │
                 ▼
Step 2: Start Class Session
        POST /teacher/sessions/:id/start  ─── Sets status: "ONGOING"
                 │
                 ▼
Step 3: Take & Upsert Attendance (Can be submitted multiple times)
        POST /teacher/sessions/:id/attendance
                 │
                 ▼
Step 4: End Class & Submit Class Report
        POST /teacher/sessions/:id/end    ─── Sets status: "COMPLETED" & creates ClassReport
```

---

### 3.1 Fetch Session Details & Student Roster
Loads full session metadata and the complete roster of active students enrolled in the cohort.

- **Endpoint:** `GET /api/v1/teacher/sessions/:id`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)
- **URL Parameter:** `id` — Session UUID

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Class session retrieved successfully",
  "data": {
    "id": "222e4567-e89b-12d3-a456-426614174001",
    "scheduleId": "333e4567-e89b-12d3-a456-426614174002",
    "sessionDate": "2026-10-22T00:00:00.000Z",
    "startTime": "09:00",
    "endTime": "10:30",
    "status": "SCHEDULED",
    "entryTime": null,
    "exitTime": null,
    "subjectName": "Advanced Mathematics",
    "cohortName": "Cohort 10-A",
    "teacherName": "Dr. Sarah Jenkins",
    "classroomRoomNumber": "Room 204",
    "students": [
      {
        "id": "555e4567-e89b-12d3-a456-426614174005",
        "fullName": "Leo Jenkins",
        "avatarUrl": "https://cdn.alua.edu/avatars/leo.jpg",
        "enrollmentNumber": "STU-2026-0042"
      },
      {
        "id": "555e4567-e89b-12d3-a456-426614174006",
        "fullName": "Maya Lin",
        "avatarUrl": "https://cdn.alua.edu/avatars/maya.jpg",
        "enrollmentNumber": "STU-2026-0089"
      },
      {
        "id": "555e4567-e89b-12d3-a456-426614174007",
        "fullName": "Liam Smith",
        "avatarUrl": null,
        "enrollmentNumber": "STU-2026-0112"
      }
    ]
  },
  "traceId": "d5e6f7a8-b90c-1d2e-3f4a-5b6c7d8e9f0a"
}
```

---

### 3.2 Start Class
Transitions a session from `SCHEDULED` to `ONGOING` and stamps the teacher's actual entry timestamp.

- **Endpoint:** `POST /api/v1/teacher/sessions/:id/start`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)
- **URL Parameter:** `id` — Session UUID

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Class session started successfully",
  "data": {
    "id": "222e4567-e89b-12d3-a456-426614174001",
    "scheduleId": "333e4567-e89b-12d3-a456-426614174002",
    "sessionDate": "2026-10-22T00:00:00.000Z",
    "startTime": "09:00",
    "endTime": "10:30",
    "status": "ONGOING",
    "entryTime": "2026-10-22T09:01:42.120Z",
    "exitTime": null,
    "subjectName": "Advanced Mathematics",
    "cohortName": "Cohort 10-A",
    "teacherName": "Dr. Sarah Jenkins",
    "classroomRoomNumber": "Room 204"
  },
  "traceId": "e6f7a8b9-0c1d-2e3f-4a5b-6c7d8e9f0a1b"
}
```

> **Business Rule:**
> Calling `/start` on a session that is already `ONGOING` or `COMPLETED` returns `400 Bad Request` with message: `"Cannot start session with current status: ONGOING"`.

---

### 3.3 Take & Upsert Attendance
Records attendance for all or a subset of enrolled students. 

**Upsert Behavior:**
This endpoint utilizes database upsert logic (`sessionId_studentId`). The teacher can submit attendance at the beginning of class and re-submit it later if a student arrives late or an absence needs to be corrected. Each submission overwrites the previous status and updates `markedAt` and `markedById`.

- **Endpoint:** `POST /api/v1/teacher/sessions/:id/attendance`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)
- **URL Parameter:** `id` — Session UUID

#### Request Body
```json
{
  "attendance": [
    {
      "studentId": "555e4567-e89b-12d3-a456-426614174005",
      "status": "PRESENT",
      "note": "Participated actively"
    },
    {
      "studentId": "555e4567-e89b-12d3-a456-426614174006",
      "status": "LATE",
      "note": "Arrived 10 minutes late due to traffic"
    },
    {
      "studentId": "555e4567-e89b-12d3-a456-426614174007",
      "status": "ABSENT",
      "note": "Unexcused absence"
    }
  ]
}
```

| Field | Type | Required | Constraints |
| :--- | :--- | :--- | :--- |
| `attendance` | `array` | **Yes** | Array of attendance records (minimum 1 item) |
| `attendance[].studentId` | `string` | **Yes** | Valid student UUID actively enrolled in the cohort |
| `attendance[].status` | `string` | **Yes** | Must be one of: `"PRESENT"`, `"ABSENT"`, `"LATE"`, `"EXCUSED"` |
| `attendance[].note` | `string` | No | Optional observation on the student's attendance |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Attendance recorded successfully",
  "data": {
    "updatedCount": 3
  },
  "traceId": "f7a8b90c-1d2e-3f4a-5b6c-7d8e9f0a1b2c"
}
```

> **Error Handling Note:**
> If any `studentId` does not belong to the session's active cohort, the entire request fails atomically with `400 Bad Request`: `"One or more students are not actively enrolled in this cohort"`.

---

### 3.4 End Class & Submit Report
Finalizes the class session by marking its status as `COMPLETED`, capturing `exitTime`, and atomically creating a `ClassReport` with status `SUBMITTED`.

- **Endpoint:** `POST /api/v1/teacher/sessions/:id/end`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)
- **URL Parameter:** `id` — Session UUID

#### Request Body
```json
{
  "contentCovered": "Completed Chapter 4: Quadratic Equations. Solved polynomial factoring exercises 4.1 to 4.5.",
  "homeworkAssigned": "Workbook page 52, questions 1 through 10. Due next Tuesday.",
  "attitudeRating": "EXCELLENT",
  "workEffortRating": "GOOD",
  "observations": "Students demonstrated strong comprehension during group work. Leo solved the bonus problem on the board."
}
```

| Field | Type | Required | Constraints |
| :--- | :--- | :--- | :--- |
| `contentCovered` | `string` | **Yes** | Non-empty text describing curriculum covered |
| `homeworkAssigned` | `string` | No | Homework tasks announced in class |
| `attitudeRating` | `string` | No | Rating enum: `"POOR"`, `"FAIR"`, `"GOOD"`, `"VERY_GOOD"`, `"EXCELLENT"` |
| `workEffortRating` | `string` | No | Rating enum: `"POOR"`, `"FAIR"`, `"GOOD"`, `"VERY_GOOD"`, `"EXCELLENT"` |
| `observations` | `string` | No | General notes or behavioral observations |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Class session ended and report submitted successfully",
  "data": {
    "id": "222e4567-e89b-12d3-a456-426614174001",
    "scheduleId": "333e4567-e89b-12d3-a456-426614174002",
    "sessionDate": "2026-10-22T00:00:00.000Z",
    "startTime": "09:00",
    "endTime": "10:30",
    "status": "COMPLETED",
    "entryTime": "2026-10-22T09:01:42.120Z",
    "exitTime": "2026-10-22T10:29:15.890Z",
    "subjectName": "Advanced Mathematics",
    "cohortName": "Cohort 10-A",
    "teacherName": "Dr. Sarah Jenkins",
    "classroomRoomNumber": "Room 204"
  },
  "traceId": "0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d"
}
```

> **Review Workflow Note:**
> Upon calling `/end`, the report is saved with status `SUBMITTED`. An Academy Administrator reviews and approves the report before it is published to parents.

---

## 4. Homework Management

Teachers can assign homework to an entire cohort, view their assignments with submission counts, and grade/mark student submissions.

### 4.1 Create Homework
Creates a new homework assignment. The backend **automatically creates pending `HomeworkSubmission` records** for all active students enrolled in the designated cohort.

- **Endpoint:** `POST /api/v1/teacher/homework`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)

#### Request Body
```json
{
  "cohortId": "444e4567-e89b-12d3-a456-426614174003",
  "subjectId": "777e4567-e89b-12d3-a456-426614174004",
  "sessionId": "222e4567-e89b-12d3-a456-426614174001",
  "title": "Quadratic Equations Problem Set",
  "description": "Complete problem set 4B on page 112 of the textbook. Show all intermediate factoring steps.",
  "startDate": "2026-10-22T10:30:00.000Z",
  "dueDate": "2026-10-29T23:59:59.000Z"
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `cohortId` | `string (UUID)` | **Yes** | Cohort being assigned the homework |
| `subjectId` | `string (UUID)` | **Yes** | Subject UUID |
| `sessionId` | `string (UUID)` | No | Optional link to the specific class session |
| `title` | `string` | **Yes** | Assignment title |
| `description` | `string` | No | Instructions, page numbers, or guidelines |
| `startDate` | `string (ISO)` | **Yes** | When the assignment opens for students |
| `dueDate` | `string (ISO)` | **Yes** | Due date and time |

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Homework created successfully",
  "data": {
    "id": "888e4567-e89b-12d3-a456-426614174008",
    "cohortId": "444e4567-e89b-12d3-a456-426614174003",
    "subjectId": "777e4567-e89b-12d3-a456-426614174004",
    "sessionId": "222e4567-e89b-12d3-a456-426614174001",
    "teacherId": "999e4567-e89b-12d3-a456-426614174009",
    "title": "Quadratic Equations Problem Set",
    "description": "Complete problem set 4B on page 112 of the textbook. Show all intermediate factoring steps.",
    "startDate": "2026-10-22T10:30:00.000Z",
    "dueDate": "2026-10-29T23:59:59.000Z",
    "subjectName": "Advanced Mathematics",
    "submissionsCount": 24,
    "createdAt": "2026-10-22T10:32:00.000Z",
    "updatedAt": "2026-10-22T10:32:00.000Z"
  },
  "traceId": "1b2c3d4e-5f6a-7b8c-9d0e-1f2a3b4c5d6e"
}
```

---

### 4.2 View My Homework
Retrieves a paginated list of homework assignments created by the authenticated teacher, with an optional cohort filter.

- **Endpoint:** `GET /api/v1/teacher/homework`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)

#### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `cohortId` | `string (UUID)` | No | Filter by cohort UUID |
| `page` | `integer` | No | Page number (default: `1`) |
| `limit` | `integer` | No | Items per page (default: `20`, max: `100`) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Teacher homework retrieved successfully",
  "data": [
    {
      "id": "888e4567-e89b-12d3-a456-426614174008",
      "cohortId": "444e4567-e89b-12d3-a456-426614174003",
      "subjectId": "777e4567-e89b-12d3-a456-426614174004",
      "sessionId": "222e4567-e89b-12d3-a456-426614174001",
      "teacherId": "999e4567-e89b-12d3-a456-426614174009",
      "title": "Quadratic Equations Problem Set",
      "description": "Complete problem set 4B on page 112 of the textbook.",
      "startDate": "2026-10-22T10:30:00.000Z",
      "dueDate": "2026-10-29T23:59:59.000Z",
      "subjectName": "Advanced Mathematics",
      "submissionsCount": 24,
      "createdAt": "2026-10-22T10:32:00.000Z",
      "updatedAt": "2026-10-22T10:32:00.000Z"
    }
  ],
  "meta": {
    "total": 1,
    "totalPages": 1,
    "links": { ... }
  },
  "traceId": "2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f"
}
```

---

### 4.3 Homework Submissions Architecture & Roster Integration

> **Implementation Architecture Note:**
> In the Aula 360 backend architecture:
> 1. An explicit standalone endpoint `GET /teacher/homework/:id/submissions` is **not** mounted because submissions are automatically generated directly against the cohort's active student roster.
> 2. `TeacherHomeworkDTO` provides the aggregate count of initialized student submissions (`submissionsCount`).
> 3. To render a grading checklist for an assignment in the mobile app, developers obtain the cohort student roster via `GET /api/v1/teacher/sessions/:id` (if tied to a session) or `GET /api/v1/teacher/students`.
> 4. Marking each individual student's status is performed via `PATCH /api/v1/teacher/homework/:id/submissions/:studentId` (documented below).

---

### 4.4 Mark Student Submission
Marks or updates a student's homework submission status.

- **Endpoint:** `PATCH /api/v1/teacher/homework/:id/submissions/:studentId`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)
- **URL Parameters:**
  - `id` — Homework UUID
  - `studentId` — Student UUID

#### Request Body
```json
{
  "status": "COMPLETED",
  "note": "All exercises checked. Full marks awarded for clear workings."
}
```

| Field | Type | Required | Constraints |
| :--- | :--- | :--- | :--- |
| `status` | `string` | **Yes** | Must be either `"PENDING"` or `"COMPLETED"` |
| `note` | `string` | No | Optional teacher feedback or grade comment |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Homework submission marked successfully",
  "data": {
    "id": "aaa4567-e89b-12d3-a456-426614174010",
    "homeworkId": "888e4567-e89b-12d3-a456-426614174008",
    "studentId": "555e4567-e89b-12d3-a456-426614174005",
    "status": "COMPLETED",
    "markedCompleteAt": "2026-10-23T14:15:30.000Z",
    "markedById": "123e4567-e89b-12d3-a456-426614174000",
    "note": "All exercises checked. Full marks awarded for clear workings.",
    "createdAt": "2026-10-22T10:32:00.000Z",
    "updatedAt": "2026-10-23T14:15:30.000Z"
  },
  "traceId": "3d4e5f6a-7b8c-9d0e-1f2a-3b4c5d6e7f8a"
}
```

---

## 5. Students & Notes

Teachers have visibility over the students enrolled across all cohorts they teach. They can inspect academic attendance metrics and add private internal notes.

### 5.1 Fetch My Students Roster
Retrieves a paginated list of students across all cohorts taught by the teacher. Includes pre-computed `attendancePercentage` for each student.

- **Endpoint:** `GET /api/v1/teacher/students`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)

#### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `page` | `integer` | No | Page number (default: `1`) |
| `limit` | `integer` | No | Items per page (default: `20`, max: `100`) |
| `search` | `string` | No | Case-insensitive search on student's `fullName` |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Students retrieved successfully",
  "data": [
    {
      "id": "555e4567-e89b-12d3-a456-426614174005",
      "fullName": "Leo Jenkins",
      "enrollmentNumber": "STU-2026-0042",
      "gradeLevel": "Grade 10",
      "avatarUrl": "https://cdn.alua.edu/avatars/leo.jpg",
      "attendancePercentage": 96
    },
    {
      "id": "555e4567-e89b-12d3-a456-426614174006",
      "fullName": "Maya Lin",
      "enrollmentNumber": "STU-2026-0089",
      "gradeLevel": "Grade 10",
      "avatarUrl": "https://cdn.alua.edu/avatars/maya.jpg",
      "attendancePercentage": 88
    }
  ],
  "meta": {
    "total": 2,
    "totalPages": 1,
    "links": { ... }
  },
  "traceId": "4e5f6a7b-8c9d-0e1f-2a3b-4c5d6e7f8a9b"
}
```

---

### 5.2 Fetch Student Details
Returns full demographic data, internal teacher notes, attendance percentage, and the most recent submitted class report involving this student.

- **Endpoint:** `GET /api/v1/teacher/students/:id`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)
- **URL Parameter:** `id` — Student UUID

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Student details retrieved successfully",
  "data": {
    "id": "555e4567-e89b-12d3-a456-426614174005",
    "fullName": "Leo Jenkins",
    "dob": "2010-05-14T00:00:00.000Z",
    "gender": "MALE",
    "gradeLevel": "Grade 10",
    "enrollmentNumber": "STU-2026-0042",
    "avatarUrl": "https://cdn.alua.edu/avatars/leo.jpg",
    "status": "ACTIVE",
    "attendancePercentage": 96,
    "notes": [
      {
        "id": "bbb4567-e89b-12d3-a456-426614174011",
        "teacherId": "999e4567-e89b-12d3-a456-426614174009",
        "studentId": "555e4567-e89b-12d3-a456-426614174005",
        "content": "Student showed significant mastery of factoring polynomials in today's session.",
        "createdAt": "2026-10-22T10:45:00.000Z",
        "updatedAt": "2026-10-22T10:45:00.000Z"
      }
    ],
    "latestReport": {
      "id": "ccc4567-e89b-12d3-a456-426614174012",
      "sessionId": "222e4567-e89b-12d3-a456-426614174001",
      "contentCovered": "Completed Chapter 4: Quadratic Equations.",
      "homeworkAssigned": "Workbook page 52, questions 1 through 10.",
      "attitudeRating": "EXCELLENT",
      "workEffortRating": "GOOD",
      "observations": "Leo solved the bonus problem on the board.",
      "submittedAt": "2026-10-22T10:30:00.000Z",
      "subjectName": "Advanced Mathematics"
    }
  },
  "traceId": "5f6a7b8c-9d0e-1f2a-3b4c-5d6e7f8a9b0c"
}
```

---

### 5.3 Add Internal Student Note
Appends a private pedagogical or behavioral note to a student's file.

> **Privacy Notice:**
> Notes created here are stored in `TeacherNote`. They are internal to the teaching staff and school administration and are **never directly displayed in the Parent app**.

- **Endpoint:** `POST /api/v1/teacher/students/:id/notes`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)
- **URL Parameter:** `id` — Student UUID

#### Request Body
```json
{
  "content": "Student has completed all makeup assignments from last week's absence with exceptional accuracy."
}
```

| Field | Type | Required | Constraints |
| :--- | :--- | :--- | :--- |
| `content` | `string` | **Yes** | Non-empty text string |

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Student note added successfully",
  "data": {
    "id": "bbb4567-e89b-12d3-a456-426614174013",
    "teacherId": "999e4567-e89b-12d3-a456-426614174009",
    "studentId": "555e4567-e89b-12d3-a456-426614174005",
    "content": "Student has completed all makeup assignments from last week's absence with exceptional accuracy.",
    "createdAt": "2026-10-22T11:00:00.000Z",
    "updatedAt": "2026-10-22T11:00:00.000Z"
  },
  "traceId": "6a7b8c9d-0e1f-2a3b-4c5d-6e7f8a9b0c1d"
}
```

---

## 6. Real-Time Communication (WebSockets)

Aula 360 features a modular Socket.IO real-time architecture partitioned into dedicated namespaces.

### 6.1 Role Communication Matrix
> **CRITICAL ARCHITECTURAL CONSTRAINT:**
> **Teachers can only message Administrators.**
> In accordance with school safeguarding policies, teachers cannot initiate direct chat threads with Parents or Students. Attempting to start a conversation with a Parent or Student returns `403 Forbidden` (`"Teachers can only initiate conversations with Administrators"`).

### 6.2 Socket Namespaces & Authentication
The WebSocket server runs on the same host as the REST API using two namespaces:

| Namespace | Responsibility |
| :--- | :--- |
| `/api/v1/chat` | Real-time messaging, typing indicators, read receipts |
| `/api/v1/notification` | Unread notifications badge counter sync |

#### Connection Setup
Clients connect to both namespaces using standard Socket.IO client libraries (`socket.io-client`). The JWT access token is passed in `auth.token`:

```dart
// Flutter (socket_io_client)
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket chatSocket = IO.io(
  'https://alua.localbox.online/api/v1/chat',
  IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': storedAccessToken})
      .enableAutoConnect()
      .build(),
);

chatSocket.onConnect((_) => print('Connected to Chat Namespace'));
```

```typescript
// React Native / TypeScript (socket.io-client)
import { io } from 'socket.io-client';

const chatSocket = io('https://alua.localbox.online/api/v1/chat', {
  transports: ['websocket'],
  auth: { token: storedAccessToken },
});
```

---

### 6.3 Supported Socket Events

#### `/api/v1/chat` Events
| Direction | Event Name | Payload | Description |
| :--- | :--- | :--- | :--- |
| **Client → Server** | `conversation:join` | `{ "conversationId": "UUID" }` | Joins the active conversation room |
| **Client → Server** | `conversation:leave`| `{ "conversationId": "UUID" }` | Leaves conversation room upon navigating away |
| **Client → Server** | `typing:start` | `{ "conversationId": "UUID" }` | Emits typing indicator to Admin |
| **Client → Server** | `typing:stop` | `{ "conversationId": "UUID" }` | Clears typing indicator |
| **Client → Server** | `message:read` | `{ "conversationId": "UUID" }` | Marks all unread messages as read |
| **Server → Client** | `new_message` | `MessageDTO` | Real-time inbound message from Admin |
| **Server → Client** | `new_conversation` | `ConversationDTO` | Emitted when an Admin starts a new thread |
| **Server → Client** | `typing:start-response` | `{ "userId": "UUID", "name": "Admin Name" }` | Displays "Admin is typing..." indicator |
| **Server → Client** | `typing:stop-response` | `{ "userId": "UUID" }` | Clears "Admin is typing..." indicator |

#### `/api/v1/notification` Events
| Direction | Event Name | Payload | Description |
| :--- | :--- | :--- | :--- |
| **Server → Client** | `notification:count-response` | `{ "count": number }` | Emitted on connection and whenever a new notification arrives |

---

### 6.4 REST Messaging Fallback & Endpoints

Mobile clients use the REST API as the persistent source of truth for loading message history and creating new conversation threads.

#### 1. Fetch Conversations
- **Endpoint:** `GET /api/v1/conversations`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Conversations retrieved successfully",
  "data": [
    {
      "id": "eee4567-e89b-12d3-a456-426614174015",
      "unreadCount": 0,
      "lastMessageAt": "2026-10-22T08:15:00.000Z",
      "otherParticipant": {
        "id": "000e4567-e89b-12d3-a456-426614174000",
        "fullName": "Academy Academic Office",
        "avatarUrl": "https://cdn.alua.edu/avatars/admin.jpg",
        "role": "ADMIN"
      },
      "lastMessage": {
        "id": "ddd4567-e89b-12d3-a456-426614174014",
        "body": "Your substitute request for Friday has been approved.",
        "sentAt": "2026-10-22T08:15:00.000Z"
      }
    }
  ],
  "traceId": "7b8c9d0e-1f2a-3b4c-5d6e-7f8a9b0c1d2e"
}
```

---

#### 2. Start Conversation with Admin
- **Endpoint:** `POST /api/v1/conversations`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

```json
{
  "targetUserId": "000e4567-e89b-12d3-a456-426614174000"
}
```

---

#### 3. Fetch Messages in Conversation
- **Endpoint:** `GET /api/v1/conversations/:id/messages`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`
- **Query Parameters:** `page=1&limit=20`

---

#### 4. Send Message (REST Send)
- **Endpoint:** `POST /api/v1/conversations/:id/messages`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`
- **URL Parameter:** `id` — Conversation UUID

```json
{
  "body": "Good morning. I have submitted the class report and attendance for Advanced Mathematics Cohort 10-A."
}
```

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "id": "ddd4567-e89b-12d3-a456-426614174099",
    "conversationId": "eee4567-e89b-12d3-a456-426614174015",
    "senderId": "123e4567-e89b-12d3-a456-426614174000",
    "body": "Good morning. I have submitted the class report and attendance for Advanced Mathematics Cohort 10-A.",
    "attachmentUrl": null,
    "sentAt": "2026-10-22T10:35:00.000Z",
    "sender": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "fullName": "Dr. Sarah Jenkins",
      "avatarUrl": "https://cdn.alua.edu/avatars/teacher1.jpg"
    }
  },
  "traceId": "8c9d0e1f-2a3b-4c5d-6e7f-8a9b0c1d2e3f"
}
```

---

## 7. Notifications & Settings

### 7.1 Fetch Unread Notifications Count
Drives the notification bell badge counter in the mobile top app bar.

- **Endpoint:** `GET /api/v1/notifications/unread-count`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Unread notification count retrieved successfully",
  "data": {
    "count": 2
  },
  "traceId": "9d0e1f2a-3b4c-5d6e-7f8a-9b0c1d2e3f4a"
}
```

---

### 7.2 List Notifications
- **Endpoint:** `GET /api/v1/notifications`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Query Parameters
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `page` | `integer` | `1` | Page number |
| `limit` | `integer` | `20` | Items per page (max: `100`) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "data": [
    {
      "id": "fff4567-e89b-12d3-a456-426614174016",
      "notificationType": "SESSION_REMINDER",
      "notificationTitle": "Upcoming Class in 15 Minutes",
      "notificationDescription": "Your Advanced Mathematics session for Cohort 10-A begins at 09:00 in Room 204.",
      "isRead": false,
      "createdAt": "2026-10-22T08:45:00.000Z"
    }
  ],
  "meta": {
    "total": 1,
    "totalPages": 1,
    "links": { ... }
  },
  "traceId": "0e1f2a3b-4c5d-6e7f-8a9b-0c1d2e3f4a5b"
}
```

---

### 7.3 Mark Single Notification Read
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
  "traceId": "1f2a3b4c-5d6e-7f8a-9b0c-1d2e3f4a5b6c"
}
```

---

### 7.4 Mark All Notifications Read
- **Endpoint:** `PATCH /api/v1/notifications/read-all`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "All notifications marked as read successfully",
  "data": {
    "count": 2
  },
  "traceId": "2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d"
}
```

---

### 7.5 Teacher Profile & Account Settings

> **Architecture & Path Notice:**
> The Teacher profile is mounted under `/api/v1/profile/teacher` (with `GET` to fetch and `POST` to update) in accordance with the backend module routing and OpenAPI specification.

#### 1. Fetch Teacher Profile
- **Endpoint:** `GET /api/v1/profile/teacher`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Teacher profile fetched successfully.",
  "data": {
    "userId": "123e4567-e89b-12d3-a456-426614174000",
    "fullName": "Dr. Sarah Jenkins",
    "email": "sarah.jenkins@aula360.edu",
    "phone": "+15552045",
    "avatarUrl": "https://cdn.alua.edu/avatars/teacher1.jpg",
    "language": "EN",
    "createdAt": "2026-08-15T09:00:00.000Z",
    "department": "Mathematics & STEM",
    "designation": "Head of Mathematics Faculty",
    "bio": "Over 15 years of experience teaching AP Calculus and Advanced Algebra."
  },
  "traceId": "3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d"
}
```

---

#### 2. Update Teacher Profile
- **Endpoint:** `POST /api/v1/profile/teacher`
- **Auth Required:** `Bearer <ACCESS_TOKEN>` (Role: `TEACHER`)

#### Request Body
```json
{
  "fullName": "Dr. Sarah Jenkins, Ph.D.",
  "phone": "+15552099",
  "avatarUrl": "https://cdn.alua.edu/avatars/teacher1_new.jpg",
  "department": "Mathematics & STEM",
  "designation": "Senior Faculty Lead",
  "bio": "Passionate about interactive mathematics and STEM curriculum development."
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `fullName` | `string` | No | Updated full name |
| `phone` | `string` | No | Contact phone number |
| `avatarUrl` | `string (URL)` | No | Hosted avatar image URL |
| `department` | `string` | No | Academic department |
| `designation` | `string` | No | Title / academic rank |
| `bio` | `string` | No | Biography / teaching summary |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Teacher profile updated successfully.",
  "data": {
    "userId": "123e4567-e89b-12d3-a456-426614174000",
    "fullName": "Dr. Sarah Jenkins, Ph.D.",
    "email": "sarah.jenkins@aula360.edu",
    "phone": "+15552099",
    "avatarUrl": "https://cdn.alua.edu/avatars/teacher1_new.jpg",
    "language": "EN",
    "createdAt": "2026-08-15T09:00:00.000Z",
    "department": "Mathematics & STEM",
    "designation": "Senior Faculty Lead",
    "bio": "Passionate about interactive mathematics and STEM curriculum development."
  },
  "traceId": "4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d"
}
```

---

#### 3. General User Settings
- **Endpoint:** `GET /api/v1/settings`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

```json
{
  "success": true,
  "message": "Settings retrieved successfully",
  "data": {
    "language": "EN"
  },
  "traceId": "5a6b7c8d-9e0f-1a2b-3c4d-5e6f7a8b9c0d"
}
```

---

#### 4. Change App Language
- **Endpoint:** `POST /api/v1/settings/language`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

```json
{
  "language": "ES"
}
```
*(Accepts `"EN"` or `"ES"`)*

---

#### 5. Change Password
- **Endpoint:** `POST /api/v1/settings/password`
- **Auth Required:** `Bearer <ACCESS_TOKEN>`

```json
{
  "currentPassword": "TeacherPassword123!",
  "newPassword": "NewTeacherPassword2026!"
}
```

| Field | Constraints |
| :--- | :--- |
| `currentPassword` | Validated against existing password hash |
| `newPassword` | 8–32 characters, 1 uppercase, 1 lowercase, 1 number, 1 special symbol |

---

## 8. Complete Integration Checklist for Mobile Developers

- [ ] **Secure Storage:** Store `data.token` securely via `FlutterSecureStorage` or `Keychain`.
- [ ] **Auth Interceptor:** Implement an HTTP interceptor that injects `Authorization: Bearer <TOKEN>` and routes to login on `401 Unauthorized`.
- [ ] **Device Binding:** Provide unique hardware `deviceIdentifier` and `platform` on every `POST /auth/login`.
- [ ] **App Boot Verification:** Call `POST /auth/check` on launch with rotated `fcmToken` to refresh notification delivery.
- [ ] **Timetable State Machine:** In the Sessions screen, handle `SCHEDULED`, `ONGOING`, `COMPLETED`, and `CANCELLED` states.
- [ ] **Live Elapsed Timer:** When session status is `ONGOING`, calculate elapsed time locally against `entryTime`.
- [ ] **Attendance Upsert:** Submit attendance via `POST /teacher/sessions/:id/attendance`; allow the teacher to edit statuses prior to class ending.
- [ ] **End Class Flow:** Ensure `contentCovered` is provided when calling `POST /teacher/sessions/:id/end`.
- [ ] **Homework Workflow:** Create assignments with `POST /teacher/homework`; grade students using `PATCH /teacher/homework/:id/submissions/:studentId`.
- [ ] **Student Notes Privacy:** Inform teachers in the UI that student notes added via `POST /teacher/students/:id/notes` are strictly internal.
- [ ] **Role Protection in Chat:** Ensure the UI only allows teachers to start chats with `ADMIN` accounts (`Role.ADMIN`).
- [ ] **Real-Time WebSockets:** Connect to `wss://alua.localbox.online/api/v1/chat` and `/api/v1/notification` using the JWT in `handshake.auth.token`.
