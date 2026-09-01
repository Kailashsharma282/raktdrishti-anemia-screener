# RaktDrishti — Non-Invasive Anemia Screening Platform

> **Omnikon National Hackathon 2026** | Problem Statement: `Omni_BioTech_2 — Non-Invasive Anemia Screening`  
> **Tagline**: *"See the risk. Confirm with confidence."*  
> **Team**: Pochiraju Kailash Ram Markandeya Sharma

[![FastAPI](https://img.shields.io/badge/FastAPI-0.110.0-009688.svg?logo=fastapi)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-02569B.svg?logo=flutter)](https://flutter.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791.svg?logo=postgresql)](https://www.postgresql.org)
[![TensorFlow Lite](https://img.shields.io/badge/TFLite-2.16-FF6F00.svg?logo=tensorflow)](https://tensorflow.org/lite)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg?logo=docker)](https://docker.com)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

---

## 1. Project Overview

**RaktDrishti** ("blood-vision") is an Android-first, offline-first non-invasive anemia risk screening platform and epidemiological surveillance dashboard. Built for frontline community health workers (ASHA, ANM, Anganwadi workers) and caregivers, it enables rapid point-of-care screening without invasive venous blood draws.

By evaluating optical biomarkers across three anatomical sites — **palpebral conjunctiva (inner lower eyelid)**, **fingernail capillary beds**, and **palmar creases** — against an in-frame printed **12-patch color calibration reference card**, RaktDrishti corrects for ambient illuminant color temperature and mitigates melanin/skin-tone bias to generate calibrated anemia risk estimations.

---

## 2. Problem

Anemia affects over 50% of pregnant women and children across India (NFHS-5). Conventional diagnostic pathways rely on invasive venous blood draws or capillary lancets:
- **Pain and Fear**: Poor compliance among pediatric and antenatal populations.
- **Invasive Infection Risks**: Biohazard sharps disposal issues in rural outposts.
- **Logistical Bottlenecks**: High recurring consumable costs (reagents, microcuvettes) and lack of centralized cold-chain equipment in Primary Health Centres (PHCs).
- **Delayed Intervention**: Delayed laboratory test returns result in high lost-to-follow-up rates.

---

## 3. Solution

RaktDrishti provides a safe, non-invasive triage solution:
1. **Zero Blood Draw First-Pass Screening**: Completely optical and pain-free.
2. **Multi-Site Sensor Fusion**: Captures palpebral conjunctiva, nail beds, and open palm to maximize screening sensitivity ($100\%$ on synthetic benchmarks).
3. **Low-Cost Printed Color-Calibration Card**: Normalizes white balance, exposure, and lighting variations using a 12-patch reference grid.
4. **100% Offline-First Functionality**: Fully autonomous on-device ML inference via TensorFlow Lite and local SQLite persistence.
5. **Intelligent Cloud Sync**: Automatic synchronization with FastAPI and PostgreSQL when internet connectivity returns.
6. **Clinical Referral Pathway**: Automatic lab referral generation for moderate and high-risk cases for confirmatory venous blood testing.

---

## 4. Architecture

```
                                  RAKTDRISHTI SYSTEM TOPOLOGY
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   📱 FLUTTER MOBILE CLIENT                                      │
│                                                                                                 │
│  [Beneficiary Reg] ──► [Camera Framing] ──► [12-Patch Calibration] ──► [IQA Quality Gate]       │
│                                                                                 │               │
│  [Confirmatory Referral] ◄── [Screening Result] ◄── [Multi-Site Fusion ML] ◄────┘               │
│             │                       │                                                           │
│             ▼                       ▼                                                           │
│  ┌────────────────────────────────────────────────────────┐                                     │
│  │               💾 Local SQLite Database                 │                                     │
│  │   (Patients, Screenings, Referrals, Sync Queue)        │                                     │
│  └──────────────────────────┬─────────────────────────────┘                                     │
└─────────────────────────────┼───────────────────────────────────────────────────────────────────┘
                              │  🌐 Automatic Batch Sync (HTTP/REST)
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  ☁️ FASTAPI CLOUD BACKEND                                       │
│                                                                                                 │
│  • JWT Authentication & RBAC               • Offline Sync Conflict Resolution Queue             │
│  • OpenAPI/Swagger REST Endpoints          • Automated Triage & Referral Tracking               │
│  • Audit Logging & Validation              • Epidemiological Summary Analytics                  │
└─────────────────────────────┬───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 🗄️ POSTGRESQL DATABASE & STORAGE                                │
│                                                                                                 │
│  Tables: users, workers, patients, screenings, screening_images, screening_predictions,         │
│          referrals, sync_events, locations, audit_logs (Managed by Alembic Migrations)          │
└─────────────────────────────┬───────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                           📊 EPIDEMIOLOGICAL COMMAND CENTER (WEB)                              │
│                                                                                                 │
│  • Village Anemia Heatmaps                 • Referral Outcomes & Lab Confirmed Hb               │
│  • 6 Interactive Demographic Charts        • Live Multi-Site ML Screening Simulator             │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Technology Stack

- **Mobile Client & Web App**: Flutter 3.19 (Dart 3.2), Flutter Web PWA, `sqflite`, `tflite_flutter`, `camera`, `connectivity_plus`, `flutter_secure_storage`.
- **Backend API**: Python 3.11+, FastAPI, SQLAlchemy 2.0 ORM, Pydantic v2, JWT/OAuth2, Uvicorn.
- **Database & Migrations**: PostgreSQL 15, SQLite (offline client mirror), Alembic.
- **Machine Learning**: TensorFlow Lite, OpenCV/Pillow, Scikit-Learn, NumPy.
- **Web Dashboard & Screener**: Vanilla HTML5/CSS3 (Glassmorphic dark design system), Chart.js, FontAwesome 6, WebRTC camera.
- **DevOps & Containers**: Docker, Docker Compose, Nginx.

---

## 6. Features

- **Guided Multi-Site Capture Flow**: Real-time visual framing guides for conjunctiva, nail beds, and palm.
- **Color Calibration Engine**: 12-patch reference grid localization with 3x3 Color Correction Matrix (CCM) mapping.
- **Image Quality Assessment (IQA)**: Heuristic scoring ($0–100$) evaluating sharpness, brightness, contrast, and card visibility.
- **Confidence-Weighted Multi-Site Fusion**: Fuses optical erythema index ($EI$), subungual capillary redness, and palmar pallor.
- **ASHA Frontline UX**: High-contrast, large touch targets, English/Hindi localization architecture.
- **Confirmatory Lab Referral Workflow**: Status tracking (`Pending`, `Referred`, `Lab Test Completed`, `Follow-up Required`) and lab Hb logging.
- **Geographic Anemia Heatmaps**: Village and block-level aggregate analytics without exposing private household coordinates.
- **Live Hackathon Demo Bench**: Deterministic case presets and instant demo cohort reset.

---

## 7. Screenshots Placeholders

| 1. Worker Home & KPI Cards | 2. Step 3: Conjunctiva Guide | 3. Step 6: Image Quality Review |
|:---:|:---:|:---:|
| `[Screenshot: Worker Home Screen]` | `[Screenshot: Camera Framing Overlay]` | `[Screenshot: IQA Validation]` |

| 4. Screening Result & Guidance | 5. Laboratory Referral Slip | 6. Epidemiological Dashboard |
|:---:|:---:|:---:|
| `[Screenshot: Screening Result Screen]` | `[Screenshot: Confirmatory Referral]` | `[Screenshot: Village Risk Map]` |

---

## 8. Setup & Installation

### Prerequisites
- Python 3.11+
- Flutter SDK 3.19+ and Android Studio (with Android SDK 34)
- Docker & Docker Compose (optional for containerized deployment)
- Git

---

## 9. Flutter Setup (Mobile & Web App)

```bash
cd mobile

# 1. Install Flutter dependencies
flutter pub get

# 2. Run automated test suites (Unit, Widget, and Integration)
flutter test test/unit_test.dart
flutter test test/widget_test.dart
flutter test test/integration_test.dart

# 3. Launch on connected Android device or emulator
flutter run

# 4. Launch on Chrome / Flutter Web
flutter run -d chrome

# 5. Build Flutter Web Production Bundle
flutter build web --release --base-href /
```

> **Instant Browser Experience**: You can also launch the responsive web version of the mobile screener directly at `http://localhost:3000/screener.html` without installing the Flutter SDK.

---

## 10. Backend Setup (FastAPI)

```bash
cd backend

# 1. Create and activate virtual environment
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# 2. Install requirements
pip install -r requirements.txt

# 3. Run Alembic database migrations
alembic upgrade head

# 4. Start development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Swagger UI documentation will be available at: `http://localhost:8000/docs`

---

## 11. Database Setup (PostgreSQL & SQLite)

By default, RaktDrishti uses SQLite (`raktdrishti.db`) for zero-configuration local development and testing. To connect PostgreSQL:
1. Update `.env`:
   ```env
   DATABASE_URL=postgresql://raktdrishti:raktdrishti_secret@localhost:5432/raktdrishti_db
   ```
2. Execute migrations:
   ```bash
   alembic upgrade head
   ```

---

## 12. Firebase Setup (Cloud Identity & Storage)

Firebase is configured for identity verification and optional cloud backups:
1. Create a project in [Firebase Console](https://console.firebase.google.com).
2. Configure authentication (Phone / Email / Anonymous).
3. Set environment variables in `.env`:
   ```env
   FIREBASE_PROJECT_ID=raktdrishti-biotech-2026
   FIREBASE_STORAGE_BUCKET=raktdrishti-biotech-2026.appspot.com
   ```

---

## 13. ML Setup & Pipeline Execution

```bash
# 1. Run ML benchmark evaluation suite
python ml/evaluation/evaluate.py

# 2. Export TensorFlow Lite model metadata specification
python ml/conversion/tflite_converter.py

# 3. Generate printable vector calibration card (PDF & SVG)
python assets/calibration/generate_card.py
```

---

## 14. Running Locally with Docker Compose

Run the entire platform (PostgreSQL + FastAPI + Web Dashboard) with a single command:

```bash
# Copy environment configuration
cp .env.example .env

# Build and start containers
docker compose up --build
```
- **Backend API**: `http://localhost:8000` (OpenAPI at `/docs`)
- **Web Dashboard**: `http://localhost:3000`
- **PostgreSQL**: `localhost:5432`

---

## 15. Demo Mode & Presentation Bench

1. **Mobile App**: Navigate to `Worker Home -> Hackathon Demo Mode` to launch preset clinical test cases (Ananya Rao, Sunita Devi, Aarav Kumar) or execute **Reset Demo Data**.
2. **Web Dashboard**: Open `http://localhost:3000`, switch to **Live ML Simulator**, and click **Run Multi-Site Screening Simulation** to trigger end-to-end telemetry.

---

## 16. API Documentation

Interactive OpenAPI documentation is hosted at `http://localhost:8000/docs`. Detailed markdown schemas are documented in [docs/api.md](file:///docs/api.md).

Key REST endpoints:
- `POST /api/v1/auth/login` & `POST /api/v1/auth/verify`: Authentication tokens.
- `GET /api/v1/workers/me`: Current health worker profile.
- `GET /api/v1/patients` & `POST /api/v1/patients`: Beneficiary management.
- `GET /api/v1/screenings` & `POST /api/v1/screenings`: Multi-site screening submissions.
- `POST /api/v1/screenings/{id}/referral`: Clinical referral generation.
- `PATCH /api/v1/referrals/{id}`: Referral status & lab confirmed Hb outcome.
- `POST /api/v1/sync`: Offline batch queue reconciliation.
- `GET /api/v1/dashboard/summary`: High-level epidemiological KPIs.
- `POST /api/v1/demo/reset`: Instant demo reset.

---

## 17. Testing Suite

The codebase includes exhaustive automated test coverage:
```bash
# Backend pytest suite (9 passed tests including integration workflow)
python -m pytest backend/tests/ -v

# Mobile Unit Tests (Image quality, calibration, ML fusion, patient validation, sync)
flutter test test/unit_test.dart

# Mobile Widget Tests (Login, registration form, result page, offline indicator)
flutter test test/widget_test.dart

# Mobile End-to-End Integration Flow Test
flutter test test/integration_test.dart
```

---

## 18. Limitations

1. **Screening Aid Only**: RaktDrishti is designed for triage and does not replace certified laboratory hematology analyzers.
2. **Lighting Constraints**: Extreme direct sunlight or pitch-black darkness triggers IQA rejection.
3. **Card Requirement**: A printed calibration card is required in frame for illumination normalization.
4. **Clinical Dataset Validation**: The current ML inference layer utilizes a calibrated engineering heuristic adapter. Prospective multi-center clinical trials with venous blood reference standards are required before commercial medical deployment.

---

## 19. Medical Safety Disclaimer

> **IMPORTANT MEDICAL NOTICE**:  
> RaktDrishti is an engineering triage aid, **NOT a medical diagnostic device**.  
> - The application **never claims to diagnose anemia** or determine exact venous hemoglobin concentration.  
> - The system estimates a risk category: **NORMAL**, **MILD RISK**, **MODERATE RISK**, or **SEVERE RISK**.  
> - **All moderate and high-risk results mandate confirmatory blood testing** at a certified healthcare facility (PHC/CHC).  
> - A low-risk result does not rule out anemia or replace clinical evaluation when symptoms or clinical concerns are present.

---

## 20. Future Roadmap

1. **Prospective Clinical Trials**: Multi-center clinical validation across diverse Indian demographic cohorts.
2. **Native INT8 Quantized TFLite Engine**: Transitioning from the adapter layer to edge-optimized neural networks.
3. **Bluetooth Hemoglobinometer Integration**: Direct BLE wireless connectivity with digital point-of-care hemoglobin devices.
4. **HMIS / Ayushman Bharat Digital Mission (ABDM) Integration**: National health record linkages via ABHA ID.
5. **Expanded Vernacular Voice Guidance**: Audio-guided capture prompts in Hindi, Bengali, Tamil, Telugu, and Marathi for frontline workers.

---

## 👥 Contributors
- **Pochiraju Kailash Ram Markandeya Sharma** — Full-Stack & ML Architecture
- *Omnikon National Hackathon 2026 — Team kailashsharma8*
