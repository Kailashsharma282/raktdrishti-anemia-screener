# RaktDrishti Backend REST API Specification

FastAPI automatically serves interactive OpenAPI documentation at `/docs` (Swagger UI) and `/redoc`.

Base URL: `http://localhost:8000/api/v1`

---

## 1. Authentication Endpoints

### `POST /auth/login`
Authenticates a health worker or administrator and returns a JWT bearer token.
- **Request Body**:
```json
{
  "username": "asha_anita",
  "password": "SecurePassword123!"
}
```
- **Response `200 OK`**:
```json
{
  "access_token": "eyJhbGciOi...",
  "token_type": "bearer",
  "expires_in": 86400,
  "user": {
    "id": "u-8d91f2c4-8390-4a8f-91bd-e1293a90ab12",
    "username": "asha_anita",
    "name": "Anita Devi",
    "role": "health_worker",
    "worker_id": "ASHA-UP-VNS-042",
    "location": "Varanasi Block A"
  }
}
```

### `POST /auth/verify`
Validates an existing token or external Firebase ID token.
- **Header**: `Authorization: Bearer <token>`
- **Response `200 OK`**: `{ "valid": true, "user_id": "...", "role": "health_worker" }`

### `GET /auth/me`
Fetches current authenticated worker profile and offline sync status.

---

## 2. Patient Management Endpoints

### `GET /patients`
Retrieves a paginated list of registered patients. Supports search by name, patient code, or village.
- **Query Params**: `page=1`, `limit=20`, `search=Ananya`, `village=Demo Village`
- **Response `200 OK`**:
```json
{
  "total": 1,
  "page": 1,
  "limit": 20,
  "items": [
    {
      "id": "p-12903-abcd-4902-8821",
      "patient_code": "RD-2026-0042",
      "name": "Ananya Rao",
      "age": 24,
      "gender": "female",
      "pregnancy_status": "pregnant",
      "phone": "+91-9876543210",
      "village": "Demo Village",
      "created_by": "u-8d91f2c4",
      "created_at": "2026-08-27T10:00:00Z",
      "screenings_count": 2,
      "latest_risk_category": "MODERATE"
    }
  ]
}
```

### `POST /patients`
Registers a new patient.
- **Request Body**:
```json
{
  "id": "p-12903-abcd-4902-8821",
  "patient_code": "RD-2026-0042",
  "name": "Ananya Rao",
  "age": 24,
  "gender": "female",
  "pregnancy_status": "pregnant",
  "phone": "+91-9876543210",
  "village": "Demo Village",
  "notes": "Second trimester routine checkup."
}
```
- **Response `201 Created`**

### `GET /patients/{patient_id}`
Returns patient profile, longitudinal screening timeline, and active referrals.

---

## 3. Screening & Triage Endpoints

### `POST /screenings`
Submits a multi-site anemia screening record.
- **Request Body**:
```json
{
  "id": "sc-99120-fbc1-4412-990a",
  "patient_id": "p-12903-abcd-4902-8821",
  "screening_date": "2026-08-27T10:15:00Z",
  "device_id": "Samsung-SM-A146B",
  "conjunctiva_quality": 88.5,
  "nail_quality": 91.0,
  "palm_quality": 85.0,
  "final_risk_category": "MODERATE",
  "risk_score": 0.72,
  "confidence": 0.81,
  "model_version": "v1.0.0-mvp-demo",
  "site_results": {
    "conjunctiva": { "score": 0.75, "quality": 88.5, "weight": 0.45 },
    "nail": { "score": 0.71, "quality": 91.0, "weight": 0.30 },
    "palm": { "score": 0.68, "quality": 85.0, "weight": 0.25 }
  },
  "calibration_detected": true
}
```
- **Response `201 Created`**

### `GET /screenings/{screening_id}`
Returns full screening telemetry, calibration metadata, and referral linkage.

---

## 4. Referral Management Endpoints

### `POST /screenings/{screening_id}/referral`
Generates a laboratory confirmation referral for high/moderate risk patients.
- **Request Body**:
```json
{
  "referral_facility": "Community Health Centre (CHC) Shivpur",
  "urgency": "high",
  "reason": "Moderate anemia risk detected on non-invasive screening",
  "notes": "Recommend immediate CBC and Serum Ferritin testing."
}
```
- **Response `201 Created`**

### `PATCH /referrals/{referral_id}`
Updates referral status (`Pending`, `Referred`, `Lab Test Completed`, `Follow-up Required`).
- **Request Body**:
```json
{
  "status": "Lab Test Completed",
  "lab_confirmed_hb": 9.2,
  "clinical_notes": "Prescribed iron and folic acid supplements (IFA)."
}
```

---

## 5. Offline Batch Synchronization (`POST /sync`)

The core endpoint supporting the offline-first architecture. Accepts a batch of pending local SQLite operations.
- **Request Body**:
```json
{
  "worker_id": "ASHA-UP-VNS-042",
  "client_timestamp": "2026-08-27T10:30:00Z",
  "patients": [ ... ],
  "screenings": [ ... ],
  "referrals": [ ... ]
}
```
- **Response `200 OK`**:
```json
{
  "status": "success",
  "synced_patients": 2,
  "synced_screenings": 3,
  "synced_referrals": 1,
  "server_timestamp": "2026-08-27T10:30:01Z",
  "conflicts_resolved": 0
}
```

---

## 6. Dashboard & Health Authority Analytics

- `GET /dashboard/summary`: High-level counters (Patients, Screenings, Risk counts, Referrals).
- `GET /dashboard/risk-distribution`: Proportional breakdown (`NORMAL`, `MILD`, `MODERATE`, `SEVERE`).
- `GET /dashboard/location-summary`: Village/ward/district level aggregate risk maps.
- `GET /dashboard/demographics`: Age group & pregnancy status risk breakdowns.
- `POST /demo/reset`: Resets database to standard synthetic hackathon demo state.
- `GET /health`: Healthcheck endpoint for container orchestration.
