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
