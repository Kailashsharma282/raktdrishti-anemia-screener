# Hackathon Live Demo & Presentation Walkthrough

> **Omnikon National Hackathon 2026**
> **Time**: 3–5 Minutes Live Presentation

---

## 1. Demo Narrative Arc & Flow

| Step | Time | Screen / Action | Talking Points |
|---|---|---|---|
| **1. Hook & Problem** | 0:00 - 0:45 | Slide / Intro | "Over 50% of pregnant women and young children in rural India suffer from anemia, yet screening currently requires invasive finger-pricks, expensive lab trips, and cold-chain reagents. Frontline ASHA workers need a zero-cost, instant screening aid." |
| **2. Login & Offline Status** | 0:45 - 1:15 | Worker Home Screen | "Login as ASHA worker Anita Devi. Notice the active **OFFLINE-FIRST** indicator: all local operations work seamlessly without cell connectivity in remote villages." |
| **3. Patient Registration** | 1:15 - 1:45 | Register Patient | "Register a patient (Ananya Rao, 24, Pregnant, Varanasi Block A). Notice pregnancy-specific risk profiles and unique offline UUID generation." |
| **4. Guided Multi-Site Capture** | 1:45 - 2:45 | Guided Camera Flow | "Demonstrate the multi-site pipeline: <br>1. **Calibration Card Setup**: Print-at-home 12-patch reference card visible in frame.<br>2. **Palpebral Conjunctiva Capture**: Inner eyelid with ROI guide.<br>3. **Nail Bed Capture**: Capillary bed illumination.<br>4. **Palmar Crease Capture**: Crease pallor assessment." |
| **5. Quality Engine & ML Fusion** | 2:45 - 3:30 | Processing & Results | "Automated image quality gate checks sharpness and card fiducials. On-device TFLite model normalizes illumination and fuses all 3 sites: <br>Result: **MODERATE RISK (Score: 72%, Confidence: 81%)**. Note safety disclaimer: *Screening aid, not a diagnosis*." |
| **6. Referral Generation** | 3:30 - 4:00 | Referral Screen | "Instant digital referral generated for CHC Shivpur for confirmatory venous blood testing (CBC)." |
| **7. Offline Simulation & Sync** | 4:00 - 4:30 | Sync Center | "Simulate airplane mode / offline screening. Stored safely in local SQLite. Reconnect internet: watch batch background sync drain queue to PostgreSQL with zero data loss." |
| **8. Admin Dashboard & Geo Analytics** | 4:30 - 5:00 | Web Dashboard | "Health officers view real-time village heatmaps, demographic risk distributions, and referral completion rates to target nutrition interventions." |

---

## 2. Fast Demo Quick-Actions

1. **Demo Mode Switch**: Located in the mobile app drawer and Web Dashboard navbar. Instantly pre-fills realistic patient profiles and multi-site synthetic images.
2. **Demo Data Reset**: Click `Reset Demo Data` on the Dashboard or trigger `POST /api/v1/demo/reset` to restore standard baseline synthetic records for clean repeatability across judging rounds.
