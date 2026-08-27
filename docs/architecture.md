# RaktDrishti System Architecture

> **Omnikon National Hackathon 2026** — *Omni_BioTech_2: Non-Invasive Anemia Screening*
> **Tagline**: "See the risk. Confirm with confidence."

---

## 1. Executive Summary

**RaktDrishti** is an Android-first, offline-resilient healthcare screening platform designed for frontline health workers (ASHA, ANM, Anganwadi workers) and parents in resource-constrained rural and semi-urban settings. It provides non-invasive anemia risk screening using smartphone camera images of three key anatomical sites:
1. **Palpebral Conjunctiva** (Inner lower eyelid)
2. **Nail Beds** (Fingernails)
3. **Palmar Surface** (Palm / skin)

To mitigate lighting variances and skin-tone bias across diverse demographic groups, all captures are calibrated in real-time against a low-cost, printable 12-patch reference calibration card.

---

## 2. High-Level System Architecture

```mermaid
flowchart TB
    subgraph Client_Side ["📱 Android Client (Flutter + Dart)"]
        UI["UI Layer\n(24+ Healthcare Screens)"]
        CamModule["Guided Camera Module\n(Framing + ROI + Auto-Quality)"]
        CalibEngine["Color Calibration Engine\n(Patch Detection + Matrix Transform)"]
        MLEngine["On-Device ML Engine\n(TFLite + Multi-Site Fusion)"]
        LocalDB[("Local SQLite Database\n(Offline Persistence)")]
        SyncQ["Sync Queue Manager\n(Exponential Backoff + Conflict Handling)"]
        
        UI --> CamModule
        CamModule --> CalibEngine
        CalibEngine --> MLEngine
        MLEngine --> LocalDB
        LocalDB --> SyncQ
    end

    subgraph Network_Boundary ["🌐 Connectivity Layer"]
        NetDetector{"Internet\nAvailable?"}
        SyncQ --> NetDetector
    end

    subgraph Backend_Cloud ["☁️ Cloud Backend (FastAPI + PostgreSQL)"]
        API["FastAPI REST Gateway\n(OAuth2 / JWT Auth)"]
        SyncEndpoint["Idempotent Sync Service\n(Batch Record Upsert)"]
        ScreeningService["Screening & Referral Engine"]
        AnalyticsService["Aggregate Analytics & Geo Engine"]
        CloudDB[("PostgreSQL Database\n(ACID Compliant)")]
        AuditLogs["Audit & Compliance Logs"]
        
        NetDetector -- "Yes (REST / JSON)" --> API
        NetDetector -- "No (Queue Locally)" --> LocalDB
        API --> SyncEndpoint
        API --> ScreeningService
        API --> AnalyticsService
        SyncEndpoint --> CloudDB
        ScreeningService --> CloudDB
        AnalyticsService --> CloudDB
        API --> AuditLogs
    end

    subgraph Portal ["💻 Health Authority & Admin Dashboard"]
        WebDashboard["Responsive Web Dashboard\n(KPIs, Heatmaps, Demographics)"]
        WebDashboard --> API
    end
```

---

## 3. End-to-End Screening Flow

```mermaid
sequenceDiagram
    autonumber
    actor Worker as ASHA / Health Worker
    participant App as RaktDrishti Mobile
    participant Cam as Camera & Calibration
    participant ML as On-Device ML
    participant DB as SQLite DB
    participant Sync as Sync Manager
    participant Backend as FastAPI Server
    participant CloudDB as PostgreSQL

    Worker->>App: Login & Select/Register Patient
    Worker->>Cam: Position Calibration Card & Patient
    Cam->>Cam: Capture Conjunctiva, Nails, Palm
    Cam->>Cam: Validate Quality (Sharpness, Exposure, Card)
    Cam->>ML: Extract Normalized Color Features (LAB, EI, Pallor)
    ML->>ML: Run Multi-Site Fusion Algorithm
    ML-->>App: Return Risk Level (NORMAL / MILD / MODERATE / SEVERE)
    App->>Worker: Display Result & Confirmatory Testing Guidance
    alt Moderate or Severe Risk
        Worker->>App: Issue Lab Referral to CHC/PHC
    end
    App->>DB: Persist Record (status: PENDING_SYNC)
    App->>Sync: Trigger Background Sync
    alt Online
        Sync->>Backend: POST /api/v1/sync (Batch payload)
        Backend->>CloudDB: Upsert Patient, Screening, Referral
        Backend-->>Sync: 200 OK (Sync Acknowledged)
        Sync->>DB: Update status to SYNCED
    else Offline
        Sync-->>App: Stored safely in local queue
    end
```

---

## 4. Architectural Pillars

### 4.1 Offline-First Resilience
- Full local SQLite database mirror for offline operation.
- Health workers can register dozens of patients and execute complete screenings in remote villages without cell connectivity.
- Cryptographically secure UUIDs generated client-side prevent synchronization ID collisions.
- Network state change triggers automatic, non-blocking queue drain.

### 4.2 Color Normalization & Anti-Bias Pipeline
- Uses known RGB/CIELAB reference values from the 12-patch printable calibration card.
- Computes $3 \times 3$ color transfer matrix and white-balance gains in linear RGB.
- Eliminates ambient illuminant cast (warm incandescent, cold fluorescent, direct sunlight, deep shadows).
- Normalizes skin pigmentation baseline to isolate vascular hemoglobin pallor.

### 4.3 Multi-Site Confidence-Weighted Fusion
- Combines three complementary anatomical sites:
  1. **Conjunctiva**: High capillary density, minimum melanin interference.
  2. **Nail Bed**: Sensitive to peripheral perfusion and microvascular changes.
  3. **Palmar Creases**: Classic clinical physical exam site for severe pallor.
- Weighted fusion formula accounts for per-site image quality score and ML model confidence.

### 4.4 Medical Safety Guardrails
- **Screening, Not Diagnostic**: Clear disclaimers throughout all interfaces.
- **Mandatory Referral**: Moderate and Severe risk outputs automatically generate structured referrals for laboratory venous blood tests (CBC / Hemoglobin).
- **No False Comfort**: Low-risk results explicitly remind health workers not to disregard clinical symptoms.
