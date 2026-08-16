# RaktDrishti 🩸👁️

**Non-invasive, smartphone-based anemia screening — no blood draw required.**

> Built for **Omnikon National Hackathon 2026** · Problem Statement `Omni_BioTech_2`
> Team: **kailashsharma8**

---

## 📌 Problem Statement

Anemia is widespread across India, especially among children and pregnant women, but current diagnosis relies on invasive blood tests that are inconvenient and often inaccessible for mass screening in low-resource and rural settings.

**Omni_BioTech_2** calls for an app that screens for anemia non-invasively using smartphone camera analysis of the eyes, nails, or skin.

## 💡 The Idea

**RaktDrishti** ("blood-vision") is a mobile app that estimates hemoglobin risk by analyzing smartphone photos of the **inner eyelid (conjunctiva)**, **nail beds**, and **palm**, using a low-cost printed **colour-calibration card** placed in-frame as a lighting/colour reference.

A guided capture flow walks the user (or a community health worker) through taking the photo correctly, an on-device ML model normalises for lighting and skin-tone bias, and the app returns a **risk band** — Normal / Mild / Moderate / Severe — with a clear recommendation to seek a confirmatory lab test when risk is elevated.

RaktDrishti is a **triage and screening aid**, not a diagnostic replacement — every high-risk result is routed to a real blood test at a health facility.

### Why it matters

- Removes the need for a blood draw for a first-pass screen
- Lets ASHA/ANM and anganwadi workers screen many people quickly, in one visit
- Gives parents and patients an accessible way to check risk early
- Generates aggregate, location-tagged data to help public health programs target resources

## ⚙️ How It Works

1. **Capture** — user photographs the eye/nail alongside the colour-reference card
2. **Calibrate** — on-device processing normalises lighting and skin tone using the reference card
3. **Predict** — an on-device ML model estimates hemoglobin risk band
4. **Guide** — the app shows the result and, if risk is high, prompts a lab visit
5. **Flag** — high-risk cases are flagged for confirmatory testing
6. **Sync** — results sync to a community health-worker dashboard when connectivity is available

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Android-first, offline-capable) |
| On-device ML | TensorFlow Lite (image classification + regression on colour features) |
| Backend | FastAPI (Python) + PostgreSQL |
| Cloud / Sync | Firebase Auth + Cloud Storage |
| Hardware | Smartphone camera + low-cost printed colour-calibration card |

## 📂 Project Structure

```
raktdrishti/
├── mobile/            # Flutter app source
├── ml/                # TFLite model training & conversion scripts
├── backend/           # FastAPI service + PostgreSQL models
├── docs/              # Design docs, architecture diagrams
└── README.md
```

*(Update this section as the actual repo structure is built out.)*

## 🚀 Getting Started

```bash
# Clone the repo
git clone https://github.com/<your-username>/raktdrishti.git
cd raktdrishti

# Mobile app
cd mobile
flutter pub get
flutter run

# Backend
cd ../backend
pip install -r requirements.txt
uvicorn main:app --reload
```

*(Fill in exact setup steps once the codebase is in place.)*

## 🎯 Impact

- **Social:** Earlier anemia detection in children and pregnant women reduces risk of maternal complications, low birth weight, and impaired child development.
- **Economic:** Lower cost per screen than lab-based testing; helps programs target scarce lab resources at those who need confirmation most.
- **Health-system:** Aggregate, location-tagged risk data supports better-targeted nutrition and supplementation programs.

## ⚠️ Disclaimer

RaktDrishti is a **screening aid**, not a certified medical diagnostic device. All high-risk results should be confirmed with a standard blood test at a licensed health facility.

## 👥 Team

| Name | Role |
|---|---|
| Pochiraju Kailash Ram Markandeya Sharma | Developer |

## 📄 License

This project is submitted for Omnikon National Hackathon 2026. License to be finalized (MIT recommended for open-source release).
