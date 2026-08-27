# Database Architecture & Entity Relationships

RaktDrishti uses **PostgreSQL** in production with **SQLAlchemy 2.0** ORM and **Alembic** migrations. For local offline execution on the Flutter client, it mirrors schemas using **SQLite** with synchronized UUID primary keys.

---

## 1. Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    USERS ||--o| WORKERS : "identifies"
    WORKERS ||--o{ PATIENTS : "registers"
    WORKERS ||--o{ SCREENINGS : "conducts"
    PATIENTS ||--o{ SCREENINGS : "receives"
    SCREENINGS ||--o{ SCREENING_IMAGES : "contains"
    SCREENINGS ||--o| SCREENING_PREDICTIONS : "generates"
    SCREENINGS ||--o| REFERRALS : "triggers"
    WORKERS ||--o{ SYNC_EVENTS : "logs"
    LOCATIONS ||--o{ PATIENTS : "locates"

    USERS {
        uuid id PK
        string username UK
        string email
        string hashed_password
        string role
        boolean is_active
        datetime created_at
    }

    WORKERS {
        uuid id PK
        uuid user_id FK
        string worker_code UK
        string full_name
        string phone
        string role_type
        string village
        string district
        datetime created_at
    }

    PATIENTS {
        uuid id PK
        string patient_code UK
        uuid worker_id FK
        string name
        int age
        string gender
        string pregnancy_status
        string phone
        string village
        uuid location_id FK
        string notes
        string sync_status
        datetime created_at
        datetime updated_at
    }

    SCREENINGS {
        uuid id PK
        uuid patient_id FK
        uuid worker_id FK
        datetime screening_date
        string device_id
        float conjunctiva_quality
        float nail_quality
        float palm_quality
        string final_risk_category
        float risk_score
        float confidence
        string model_version
        string status
        string sync_status
        datetime created_at
        datetime updated_at
    }

    SCREENING_IMAGES {
        uuid id PK
        uuid screening_id FK
        string site_type
        string local_path
        string cloud_path
        float quality_score
        boolean calibration_detected
        datetime created_at
    }

    SCREENING_PREDICTIONS {
        uuid id PK
        uuid screening_id FK
        string model_name
        string model_version
        float conjunctiva_score
        float nail_score
        float palm_score
        float final_score
        float confidence
        json feature_vector
        datetime created_at
    }

    REFERRALS {
        uuid id PK
        uuid screening_id FK
        uuid patient_id FK
        uuid worker_id FK
        string referral_facility
        string urgency
        string status
        float lab_confirmed_hb
        string clinical_notes
        string sync_status
        datetime created_at
        datetime updated_at
    }

    SYNC_EVENTS {
        uuid id PK
        uuid worker_id FK
        string client_timestamp
        int synced_patients
        int synced_screenings
        int synced_referrals
        string status
        datetime created_at
    }

    LOCATIONS {
        uuid id PK
        string village
        string ward
        string block
        string district
        string state
    }

    AUDIT_LOGS {
        uuid id PK
        uuid user_id FK
        string action
        string entity_type
        uuid entity_id
        string ip_address
        datetime created_at
    }
```

---

## 2. Synchronization & Conflict Resolution Strategy

1. **Client-Side UUID Primary Keys**: Ensures both offline SQLite client and PostgreSQL server use non-colliding entity identifiers.
2. **Sync Status Enum**:
   - `PENDING`: Stored locally on mobile device, waiting for internet connection.
   - `SYNCING`: Currently in transit in HTTP POST payload.
   - `SYNCED`: Successfully acknowledged by backend and committed to PostgreSQL.
   - `FAILED`: Encountered network/validation error, marked for exponential backoff retry.
3. **Deterministic Last-Write-Wins (LWW) with Audit Trail**:
   - Updates compare `updated_at` timestamps.
   - All inbound synchronizations write an entry to `audit_logs` and `sync_events`.
