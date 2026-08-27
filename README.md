# RaktDrishti — Non-Invasive Anemia Screening Platform

> **Omnikon National Hackathon 2026** | Problem Statement: `Omni_BioTech_2 — Non-Invasive Anemia Screening`
> **Tagline**: *"See the risk. Confirm with confidence."*

[![FastAPI](https://img.shields.io/badge/FastAPI-0.110.0-009688.svg?logo=fastapi)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-02569B.svg?logo=flutter)](https://flutter.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791.svg?logo=postgresql)](https://www.postgresql.org)
[![TensorFlow Lite](https://img.shields.io/badge/TFLite-2.16-FF6F00.svg?logo=tensorflow)](https://tensorflow.org/lite)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg?logo=docker)](https://docker.com)

---

## 🩸 Project Overview

**RaktDrishti** is an Android-first, offline-first mobile screening and cloud analytics platform designed to empower frontline community health workers (ASHA, ANM, Anganwadi workers) and caregivers to detect anemia risk without invasive blood draws.

By analyzing smartphone camera images of three key anatomical regions — the **inner lower eyelid (conjunctiva)**, **fingernail beds**, and **palmar creases** — against a **low-cost printable color-calibration reference card**, RaktDrishti normalizes ambient lighting variations and mitigates skin-tone bias to generate rapid, accessible triage scores.

```
                    ┌─────────────────────────────────────────────────────────┐
                    │               📱 RaktDrishti Mobile App                 │
                    │   Guided Multi-Site Capture + Calibration Normalization │
                    └────────────────────────────┬────────────────────────────┘
                                                 │
                                                 ▼
                    ┌─────────────────────────────────────────────────────────┐
                    │               🧠 On-Device TFLite Engine                │
                    │      Conjunctiva + Nail + Palm Multi-Site Fusion        │
                    │   Output: NORMAL / MILD RISK / MODERATE / SEVERE RISK   │
                    └────────────────────────────┬────────────────────────────┘
                                                 │
                                                 ▼
              ┌──────────────────────────────────┴──────────────────────────────────┐
              ▼                                                                     ▼
┌───────────────────────────┐                                         ┌───────────────────────────┐
│   💾 Offline SQLite DB    │                                         │ 🏥 Immediate Lab Referral  │
│  Resilient Queue & Retry  │                                         │ Confirmatory Blood Test   │
└─────────────┬─────────────┘                                         └───────────────────────────┘
              │ (When Internet returns)
              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                     ☁️ FastAPI + PostgreSQL Cloud Sync & Aggregate Analytics                    │
│                          Geospatial Village Heatmaps & Health Dashboard                         │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚠️ Important Medical Safety Disclaimer

> **RaktDrishti is an initial triage and screening aid, NOT a medical diagnostic device.**
> - It does not calculate exact venous hemoglobin concentrations ($g/dL$) and does not replace certified laboratory hematology analyzers.
> - High-risk and moderate-risk results **mandate confirmatory blood testing** (CBC, Serum Ferritin) at a Primary Health Centre (PHC) or Community Health Centre (CHC).
> - Low-risk results do **not** rule out anemia if clinical symptoms (fatigue, shortness of breath, dizziness) are present.

---

## 🌟 Key Features

1. **Multi-Site Optical Fusion**: Fuses colorimetric erythema metrics across Palpebral Conjunctiva, Nail Bed capillaries, and Palmar creases.
2. **Low-Cost Printed Color-Calibration Card**: Uses a standard printable 12-patch reference card visible in frame to calculate 3x3 color correction matrices (CCM) and eliminate lighting/melanin bias.
3. **Automated Image Quality Assessment (IQA)**: Real-time sharpness, exposure, contrast, and card visibility heuristics prevent unreadable captures.
4. **100% Offline-First Architecture**: Health workers in remote villages can register patients, conduct multi-site screenings, and generate referrals completely offline.
5. **Automatic Intelligent Sync**: Automatically detects network restoration, resolves conflicts, and flushes queued records to PostgreSQL.
6. **Frontline ASHA Worker UX**: High-contrast, large touch targets, step-by-step visual framing guides, and English/Hindi localization architecture.
7. **Population Health Analytics Dashboard**: Real-time epidemiological monitoring, village-level anemia risk maps, age-group breakdowns, and referral tracking for health officers.
8. **Hackathon Demo Mode**: One-click demo mode with synthetic cases and a instant data reset button for seamless live presentations.

---

## 📁 Monorepo Structure

```
raktdrishti/
├── mobile/                  # Android-first Flutter Mobile Application
│   ├── lib/                 # Clean Architecture (Core, Data, Domain, Presentation)
│   ├── assets/              # Calibration card, UI assets, and ML model weights
│   ├── test/                # Flutter unit & widget test suites
│   └── pubspec.yaml         # Dependencies
├── backend/                 # High-Performance FastAPI REST Server
│   ├── app/                 # Routers, Schemas, Models, Services, Auth & Utils
│   ├── tests/               # Pytest automated API and sync test suite
│   ├── requirements.txt     # Python backend dependencies
│   └── Dockerfile           # Production container build
├── dashboard/               # Responsive Health Authority & Admin Dashboard
│   ├── index.html           # Modern Glassmorphic UI & Interactive Simulator
│   ├── css/style.css        # Responsive healthcare styling system
│   └── js/                  # App logic, Chart.js integrations & live demo bench
├── ml/                      # Machine Learning & Color Calibration Pipeline
│   ├── preprocessing/       # Card patch detection, CCM calculation & illumination correction
│   ├── features/            # Erythema Index, CIELAB chroma, capillary vascularity extraction
│   ├── training/            # Multi-site confidence fusion network
│   ├── evaluation/          # ROC-AUC, Sensitivity, Specificity, Confusion Matrix
│   └── demo_model/          # Deterministic demo adapter & TFLite converter
├── assets/
│   └── calibration/         # Printable calibration card PDF generator & assets
├── docs/                    # Complete Engineering & Clinical Documentation
│   ├── architecture.md      # Detailed system architecture & Mermaid diagrams
│   ├── api.md               # REST API reference and payload specifications
│   ├── ml.md                # ML algorithms, feature extraction & calibration math
│   ├── database.md          # PostgreSQL schemas, ER diagram & sync model
│   ├── setup.md             # Local and Docker setup instructions
│   └── demo.md              # 3-5 minute live hackathon presentation guide
├── docker-compose.yml       # Orchestrates Postgres, FastAPI, and Dashboard
├── .env.example             # Environment variable template
└── README.md                # Project documentation
```

---

## 🚀 Getting Started

### 1. Docker Compose (Recommended)
```bash
cp .env.example .env
docker compose up --build
```
- **Backend API**: `http://localhost:8000` (Swagger docs at `/docs`)
- **Web Dashboard**: `http://localhost:3000`

### 2. Local Backend Run
```bash
cd backend
python -m venv venv
# Windows: .\venv\Scripts\activate | Linux: source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### 3. Run Web Dashboard
```bash
cd dashboard
python -m http.server 3000
# Open http://localhost:3000 in your browser
```

### 4. Run Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

---

## 🧪 Testing

```bash
# Backend test suite
pytest backend/tests/ -v

# ML evaluation test
python ml/evaluation/evaluate.py

# Generate printable calibration card
python assets/calibration/generate_card.py
```

---

## 📜 Documentation Index
- [Architecture & Flow Diagrams](file:///docs/architecture.md)
- [REST API Specifications](file:///docs/api.md)
- [ML & Calibration Pipeline](file:///docs/ml.md)
- [Database Schema & ERD](file:///docs/database.md)
- [Setup & Deployment Guide](file:///docs/setup.md)
- [Hackathon Demo Walkthrough](file:///docs/demo.md)
