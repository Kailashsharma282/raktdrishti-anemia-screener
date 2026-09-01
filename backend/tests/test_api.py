import pytest
from datetime import datetime

def test_health_check(client):
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "model_version" in data

def test_auth_login(client):
    response = client.post(
        "/api/v1/auth/login",
        json={"username": "asha_anita", "password": "AshaPass2026!"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["user"]["username"] == "asha_anita"

def test_get_patients(client):
    response = client.get("/api/v1/patients")
    assert response.status_code == 200
    data = response.json()
    assert data["total"] >= 1
    assert len(data["items"]) >= 1
    # Check Ananya Rao seeded patient
    names = [p["name"] for p in data["items"]]
    assert "Ananya Rao" in names

def test_create_patient(client):
    new_patient = {
        "name": "Kavita Devi",
        "age": 28,
        "gender": "female",
        "pregnancy_status": "pregnant",
        "phone": "+91-9988776655",
        "village": "Demo Village",
        "notes": "First trimester registration."
    }
    response = client.post("/api/v1/patients", json=new_patient)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Kavita Devi"
    assert data["patient_code"].startswith("RD-2026-")

def test_create_screening_and_auto_referral(client):
    # Fetch a patient ID
    p_res = client.get("/api/v1/patients")
    patient_id = p_res.json()["items"][0]["id"]

    screening_payload = {
        "patient_id": patient_id,
        "conjunctiva_quality": 89.0,
        "nail_quality": 91.5,
        "palm_quality": 87.0,
        "final_risk_category": "SEVERE",
        "risk_score": 0.88,
        "confidence": 0.90,
        "images": [
            {
                "site_type": "conjunctiva",
                "quality_score": 89.0,
                "calibration_detected": True
            }
        ]
    }
    response = client.post("/api/v1/screenings", json=screening_payload)
    assert response.status_code == 201
    data = response.json()
    assert data["final_risk_category"] == "SEVERE"
    assert data["risk_score"] == 0.88
    # Ensure automated referral was linked
    assert data["referral_id"] is not None

def test_batch_sync_offline_queue(client):
    sync_payload = {
        "device_id": "Redmi-12-Offline-Test",
        "client_timestamp": datetime.utcnow().isoformat(),
        "patients": [
            {
                "id": "p-offline-sync-001",
                "patient_code": "RD-OFFLINE-001",
                "name": "Radha Bai",
                "age": 35,
                "gender": "female",
                "pregnancy_status": "not_pregnant",
                "village": "Shivpur Rural"
            }
        ],
        "screenings": [
            {
                "id": "sc-offline-sync-001",
                "patient_id": "p-offline-sync-001",
                "conjunctiva_quality": 92.0,
                "nail_quality": 90.0,
                "palm_quality": 88.0,
                "final_risk_category": "MILD",
                "risk_score": 0.42,
                "confidence": 0.85
            }
        ],
        "referrals": []
    }
    response = client.post("/api/v1/sync", json=sync_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["synced_patients"] == 1
    assert data["synced_screenings"] == 1

def test_dashboard_summary_and_analytics(client):
    # Summary
    res_sum = client.get("/api/v1/dashboard/summary")
    assert res_sum.status_code == 200
    sum_data = res_sum.json()
    assert sum_data["total_patients"] >= 1
    assert sum_data["total_screenings"] >= 1

    # Risk Distribution
    res_dist = client.get("/api/v1/dashboard/risk-distribution")
    assert res_dist.status_code == 200
    dist_data = res_dist.json()
    assert "percentages" in dist_data

    # Location summary
    res_loc = client.get("/api/v1/dashboard/location-summary")
    assert res_loc.status_code == 200
    loc_data = res_loc.json()
    assert isinstance(loc_data, list)

    # Demographics
    res_demo = client.get("/api/v1/dashboard/demographics")
    assert res_demo.status_code == 200
    demo_data = res_demo.json()
    assert "age_groups" in demo_data
    assert "pregnancy_breakdown" in demo_data

def test_demo_reset(client):
    response = client.post("/api/v1/demo/reset")
    assert response.status_code == 200
    assert response.json()["status"] == "success"

def test_end_to_end_integration_flow(client):
    """
    Section 45 Integration Test:
    Patient registration -> Screening -> Result -> Referral -> Offline storage -> Sync
    """
    # 1. Patient registration
    patient_payload = {
        "name": "Pooja Verma",
        "age": 25,
        "gender": "female",
        "pregnancy_status": "pregnant",
        "village": "Demo Village",
        "phone": "+91-9123456780",
        "notes": "First ANC visit screening."
    }
    p_res = client.post("/api/v1/patients", json=patient_payload)
    assert p_res.status_code == 201
    p_data = p_res.json()
    patient_id = p_data["id"]
    assert p_data["name"] == "Pooja Verma"

    # 2. Screening creation & inference result
    screening_payload = {
        "patient_id": patient_id,
        "conjunctiva_quality": 91.0,
        "nail_quality": 89.5,
        "palm_quality": 93.0,
        "final_risk_category": "MODERATE",
        "risk_score": 0.73,
        "confidence": 0.88,
        "images": [
            {"site_type": "conjunctiva", "quality_score": 91.0, "calibration_detected": True},
            {"site_type": "nail", "quality_score": 89.5, "calibration_detected": True},
            {"site_type": "palm", "quality_score": 93.0, "calibration_detected": True}
        ]
    }
    s_res = client.post("/api/v1/screenings", json=screening_payload)
    assert s_res.status_code == 201
    s_data = s_res.json()
    screening_id = s_data["id"]
    assert s_data["final_risk_category"] == "MODERATE"

    # 3. Fetch screening result detail
    s_detail = client.get(f"/api/v1/screenings/{screening_id}")
    assert s_detail.status_code == 200
    assert s_detail.json()["patient_name"] == "Pooja Verma"

    # 4. Referral creation & update
    ref_payload = {
        "patient_id": patient_id,
        "referral_facility": "Community Health Centre (CHC) Shivpur",
        "urgency": "high",
        "notes": "Moderate risk optical estimation during 1st ANC visit."
    }
    ref_res = client.post(f"/api/v1/screenings/{screening_id}/referral", json=ref_payload)
    assert ref_res.status_code == 201
    ref_id = ref_res.json()["id"]

    patch_res = client.patch(
        f"/api/v1/referrals/{ref_id}",
        json={"status": "Lab Test Completed", "lab_confirmed_hb": 9.2}
    )
    assert patch_res.status_code == 200
    assert patch_res.json()["status"] == "Lab Test Completed"
    assert patch_res.json()["lab_confirmed_hb"] == 9.2

    # 5. Offline Storage -> Sync Endpoint test
    sync_payload = {
        "device_id": "Integration-Test-Phone",
        "client_timestamp": datetime.now().isoformat(),
        "patients": [
            {
                "id": "p-offline-e2e-001",
                "patient_code": "RD-OFFLINE-E2E",
                "name": "Lalita Bai",
                "age": 31,
                "gender": "female",
                "pregnancy_status": "not_pregnant",
                "village": "Ramnagar"
            }
        ],
        "screenings": [
            {
                "id": "sc-offline-e2e-001",
                "patient_id": "p-offline-e2e-001",
                "conjunctiva_quality": 88.0,
                "nail_quality": 87.0,
                "palm_quality": 90.0,
                "final_risk_category": "NORMAL",
                "risk_score": 0.21,
                "confidence": 0.89
            }
        ],
        "referrals": []
    }
    sync_res = client.post("/api/v1/sync", json=sync_payload)
    assert sync_res.status_code == 200
    assert sync_res.json()["synced_patients"] == 1
    assert sync_res.json()["synced_screenings"] == 1

    # 6. Verify dashboard KPIs updated
    dash_res = client.get("/api/v1/dashboard/summary")
    assert dash_res.status_code == 200
    assert dash_res.json()["total_screenings"] >= 2

