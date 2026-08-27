# RaktDrishti Setup & Installation Guide

This guide provides end-to-end instructions for running the RaktDrishti platform across backend, dashboard, ML pipelines, and mobile client.

---

## 1. Prerequisites

- **Python**: 3.10+ (Tested on Python 3.11/3.12/3.13)
- **Node.js**: v18+ (Optional for dashboard static server)
- **Docker & Docker Compose**: (Optional for containerized run)
- **Flutter SDK**: 3.19+ (For mobile Android build)

---

## 2. Quickstart with Docker Compose

To launch PostgreSQL, FastAPI Backend, and the Web Dashboard simultaneously:

```bash
# 1. Clone repository
git clone https://github.com/your-org/raktdrishti.git
cd raktdrishti

# 2. Copy environment file
cp .env.example .env

# 3. Spin up all containers
docker compose up --build
```

- **Backend API**: `http://localhost:8000`
- **Interactive Swagger Docs**: `http://localhost:8000/docs`
- **Web Dashboard**: `http://localhost:3000`

---

## 3. Local Backend Setup (FastAPI + SQLite/PostgreSQL)

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
.\venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the FastAPI server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 4. Web Dashboard Setup

The dashboard is built with responsive vanilla HTML5, CSS3, and JavaScript (with Chart.js), requiring zero heavy build chains:

```bash
# Navigate to dashboard directory
cd dashboard

# Serve with any lightweight static server or Python HTTP server:
python -m http.server 3000
```
Open `http://localhost:3000` in your web browser.

---

## 5. Mobile Application Setup (Flutter)

```bash
# Navigate to mobile directory
cd mobile

# Get Flutter dependencies
flutter pub get

# Run on connected Android device or emulator
flutter run

# Build APK for Android
flutter build apk --release
```

---

## 6. Running Test Suites

```bash
# Run backend tests
pytest backend/tests/ -v

# Run ML pipeline evaluation
python ml/evaluation/evaluate.py

# Generate printable calibration card
python assets/calibration/generate_card.py
```
