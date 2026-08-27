import uuid
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from backend.app.models import (
    User, Worker, Location, Patient, Screening, ScreeningImage, ScreeningPrediction, Referral, SyncEvent, AuditLog
)
from backend.app.auth.security import get_password_hash

def seed_initial_data(db: Session, reset: bool = False):
    """
    Seeds initial synthetic demo dataset for hackathon presentation.
    If reset=True, clears existing records first.
    """
    if reset:
        db.query(AuditLog).delete()
        db.query(SyncEvent).delete()
        db.query(Referral).delete()
        db.query(ScreeningPrediction).delete()
        db.query(ScreeningImage).delete()
        db.query(Screening).delete()
        db.query(Patient).delete()
        db.query(Worker).delete()
        db.query(Location).delete()
        db.query(User).delete()
        db.commit()

    # Check if already seeded
    if db.query(User).first() is not None and not reset:
        return

    # 1. Locations
    loc1 = Location(
        id=str(uuid.uuid4()),
        village="Demo Village",
        ward="Ward 4",
        block="Varanasi Block A",
        district="Varanasi",
        state="Uttar Pradesh"
    )
    loc2 = Location(
        id=str(uuid.uuid4()),
        village="Shivpur Rural",
        ward="Ward 2",
        block="Varanasi Block A",
        district="Varanasi",
        state="Uttar Pradesh"
    )
    loc3 = Location(
        id=str(uuid.uuid4()),
        village="Ramnagar",
        ward="Ward 7",
        block="Varanasi Block B",
        district="Varanasi",
        state="Uttar Pradesh"
    )
    db.add_all([loc1, loc2, loc3])
    db.flush()

    # 2. Users & Workers
    # Admin User
    admin_user = User(
        id="u-admin-0001-demo-hackathon-2026",
        username="admin",
        email="admin@raktdrishti.in",
        hashed_password=get_password_hash("AdminPass2026!"),
        role="admin",
        is_active=True
    )
    # ASHA Worker Anita Devi
    worker_user1 = User(
        id="u-8d91f2c4-8390-4a8f-91bd-e1293a90ab12",
        username="asha_anita",
        email="anita.devi@raktdrishti.in",
        hashed_password=get_password_hash("AshaPass2026!"),
        role="health_worker",
        is_active=True
    )
    # ANM Worker Priya Sharma
    worker_user2 = User(
        id="u-7c82a1b3-5120-4e7f-82ac-f2194b80bc34",
        username="anm_priya",
        email="priya.sharma@raktdrishti.in",
        hashed_password=get_password_hash("AnmPass2026!"),
        role="health_worker",
        is_active=True
    )
    db.add_all([admin_user, worker_user1, worker_user2])
    db.flush()

    worker1 = Worker(
        id="w-asha-001-varanasi",
        user_id=worker_user1.id,
        worker_code="ASHA-UP-VNS-042",
        full_name="Anita Devi",
        phone="+91-9876501234",
        role_type="ASHA",
        village="Demo Village",
        district="Varanasi",
        state="Uttar Pradesh"
    )
    worker2 = Worker(
        id="w-anm-002-varanasi",
        user_id=worker_user2.id,
        worker_code="ANM-UP-VNS-018",
        full_name="Priya Sharma",
        phone="+91-9876505678",
        role_type="ANM",
        village="Shivpur Rural",
        district="Varanasi",
        state="Uttar Pradesh"
    )
    db.add_all([worker1, worker2])
    db.flush()

    # 3. Synthetic Patients
    # Patient 1: Ananya Rao (Moderate Anemia - Pregnant) - Key demo case
    p1 = Patient(
        id="p-12903-abcd-4902-8821-ananya-rao",
        patient_code="RD-2026-0042",
        worker_id=worker1.id,
        name="Ananya Rao",
        age=24,
        gender="female",
        pregnancy_status="pregnant",
        phone="+91-9876543210",
        village="Demo Village",
        location_id=loc1.id,
        notes="Second trimester ANC visit. Reports mild fatigue and pale conjunctiva.",
        sync_status="SYNCED",
        created_at=datetime.utcnow() - timedelta(days=5)
    )
    # Patient 2: Sunita Devi (Severe Anemia - Lactating)
    p2 = Patient(
        id="p-22901-bbcd-4902-8822-sunita-devi",
        patient_code="RD-2026-0043",
        worker_id=worker1.id,
        name="Sunita Devi",
        age=29,
        gender="female",
        pregnancy_status="not_pregnant",
        phone="+91-9876543211",
        village="Demo Village",
        location_id=loc1.id,
        notes="Postnatal follow up at 6 weeks. Severe palmar pallor.",
        sync_status="SYNCED",
        created_at=datetime.utcnow() - timedelta(days=4)
    )
    # Patient 3: Aarav Kumar (Normal - Pediatric)
    p3 = Patient(
        id="p-33902-cccd-4902-8823-aarav-kumar",
        patient_code="RD-2026-0044",
        worker_id=worker1.id,
        name="Aarav Kumar",
        age=4,
        gender="male",
        pregnancy_status="not_applicable",
        phone="+91-9876543212",
        village="Demo Village",
        location_id=loc1.id,
        notes="Routine Anganwadi growth monitoring.",
        sync_status="SYNCED",
        created_at=datetime.utcnow() - timedelta(days=3)
    )
    # Patient 4: Meena Patel (Mild Risk - Adolescent)
    p4 = Patient(
        id="p-44903-ddcd-4902-8824-meena-patel",
        patient_code="RD-2026-0045",
        worker_id=worker1.id,
        name="Meena Patel",
        age=16,
        gender="female",
        pregnancy_status="not_pregnant",
        phone="+91-9876543213",
        village="Shivpur Rural",
        location_id=loc2.id,
        notes="Adolescent health screening campaign (WIFS).",
        sync_status="SYNCED",
        created_at=datetime.utcnow() - timedelta(days=2)
    )
    # Patient 5: Ramesh Chandra (Normal - Adult Male)
    p5 = Patient(
        id="p-55904-eecd-4902-8825-ramesh-chandra",
        patient_code="RD-2026-0046",
        worker_id=worker2.id,
        name="Ramesh Chandra",
        age=42,
        gender="male",
        pregnancy_status="not_applicable",
        phone="+91-9876543214",
        village="Ramnagar",
        location_id=loc3.id,
        notes="General health camp screening.",
        sync_status="SYNCED",
        created_at=datetime.utcnow() - timedelta(days=1)
    )
    db.add_all([p1, p2, p3, p4, p5])
    db.flush()

    # 4. Screenings
    # Screening 1 for Ananya Rao (Moderate Anemia)
    s1 = Screening(
        id="sc-001-ananya-rao-moderate",
        patient_id=p1.id,
        worker_id=worker1.id,
        screening_date=datetime.utcnow() - timedelta(days=5),
        device_id="Samsung-Galaxy-A14",
        conjunctiva_quality=88.5,
        nail_quality=92.0,
        palm_quality=86.0,
        overall_quality=88.8,
        final_risk_category="MODERATE",
        risk_score=0.72,
        confidence=0.81,
        model_version="v1.0.0-mvp-demo",
        status="completed",
        sync_status="SYNCED"
    )
    # Screening 2 for Sunita Devi (Severe Anemia)
    s2 = Screening(
        id="sc-002-sunita-devi-severe",
        patient_id=p2.id,
        worker_id=worker1.id,
        screening_date=datetime.utcnow() - timedelta(days=4),
        device_id="Samsung-Galaxy-A14",
        conjunctiva_quality=94.0,
        nail_quality=89.0,
        palm_quality=91.0,
        overall_quality=91.3,
        final_risk_category="SEVERE",
        risk_score=0.86,
        confidence=0.89,
        model_version="v1.0.0-mvp-demo",
        status="completed",
        sync_status="SYNCED"
    )
    # Screening 3 for Aarav Kumar (Normal)
    s3 = Screening(
        id="sc-003-aarav-kumar-normal",
        patient_id=p3.id,
        worker_id=worker1.id,
        screening_date=datetime.utcnow() - timedelta(days=3),
        device_id="Samsung-Galaxy-A14",
        conjunctiva_quality=85.0,
        nail_quality=88.0,
        palm_quality=82.0,
        overall_quality=85.0,
        final_risk_category="NORMAL",
        risk_score=0.22,
        confidence=0.88,
        model_version="v1.0.0-mvp-demo",
        status="completed",
        sync_status="SYNCED"
    )
    # Screening 4 for Meena Patel (Mild Risk)
    s4 = Screening(
        id="sc-004-meena-patel-mild",
        patient_id=p4.id,
        worker_id=worker1.id,
        screening_date=datetime.utcnow() - timedelta(days=2),
        device_id="Samsung-Galaxy-A14",
        conjunctiva_quality=90.0,
        nail_quality=87.0,
        palm_quality=89.0,
        overall_quality=88.7,
        final_risk_category="MILD",
        risk_score=0.48,
        confidence=0.84,
        model_version="v1.0.0-mvp-demo",
        status="completed",
        sync_status="SYNCED"
    )
    # Screening 5 for Ramesh Chandra (Normal)
    s5 = Screening(
        id="sc-005-ramesh-chandra-normal",
        patient_id=p5.id,
        worker_id=worker2.id,
        screening_date=datetime.utcnow() - timedelta(days=1),
        device_id="Redmi-Note-12",
        conjunctiva_quality=92.0,
        nail_quality=91.0,
        palm_quality=90.0,
        overall_quality=91.0,
        final_risk_category="NORMAL",
        risk_score=0.18,
        confidence=0.92,
        model_version="v1.0.0-mvp-demo",
        status="completed",
        sync_status="SYNCED"
    )
    db.add_all([s1, s2, s3, s4, s5])
    db.flush()

    # 5. Screening Predictions details
    pred1 = ScreeningPrediction(
        id=str(uuid.uuid4()),
        screening_id=s1.id,
        model_name="RaktDrishti-MultiSite-Fusion",
        model_version="v1.0.0-mvp-demo",
        conjunctiva_score=0.63,
        nail_score=0.71,
        palm_score=0.66,
        final_score=0.72,
        risk_category="MODERATE",
        confidence=0.81,
        feature_vector={"conjunctiva_ei": 0.38, "nail_redness": 0.41, "palm_contrast": 0.29}
    )
    pred2 = ScreeningPrediction(
        id=str(uuid.uuid4()),
        screening_id=s2.id,
        model_name="RaktDrishti-MultiSite-Fusion",
        model_version="v1.0.0-mvp-demo",
        conjunctiva_score=0.88,
        nail_score=0.84,
        palm_score=0.86,
        final_score=0.86,
        risk_category="SEVERE",
        confidence=0.89,
        feature_vector={"conjunctiva_ei": 0.18, "nail_redness": 0.29, "palm_contrast": 0.14}
    )
    db.add_all([pred1, pred2])

    # 6. Screening Images
    for sc, sc_id in [(s1, s1.id), (s2, s2.id)]:
        for site in ["conjunctiva", "nail", "palm"]:
            img = ScreeningImage(
                id=str(uuid.uuid4()),
                screening_id=sc_id,
                site_type=site,
                local_path=f"/storage/screenings/{sc_id}_{site}.jpg",
                cloud_path=f"https://storage.raktdrishti.in/screenings/{sc_id}_{site}.jpg",
                quality_score=90.0,
                calibration_detected=True,
                illumination_gain=1.04,
                color_features={"lab_L": 62.4, "lab_a": 18.2, "lab_b": 12.1}
            )
            db.add(img)

    # 7. Referrals
    # Referral 1 for Ananya Rao
    ref1 = Referral(
        id="ref-001-ananya-rao",
        screening_id=s1.id,
        patient_id=p1.id,
        worker_id=worker1.id,
        referral_facility="Community Health Centre (CHC) Shivpur",
        urgency="high",
        status="Referred",
        clinical_notes="Referred for confirmatory CBC and Serum Ferritin.",
        sync_status="SYNCED"
    )
    # Referral 2 for Sunita Devi
    ref2 = Referral(
        id="ref-002-sunita-devi",
        screening_id=s2.id,
        patient_id=p2.id,
        worker_id=worker1.id,
        referral_facility="District Hospital Varanasi",
        urgency="immediate",
        status="Lab Test Completed",
        lab_confirmed_hb=7.4,
        clinical_notes="Confirmatory venous test confirmed Hb 7.4 g/dL. Initiated on therapeutic oral iron + folic acid.",
        prescribed_treatment="Therapeutic IFA 200mg BD",
        sync_status="SYNCED"
    )
    db.add_all([ref1, ref2])

    # 8. Sync Event
    sync1 = SyncEvent(
        id=str(uuid.uuid4()),
        worker_id=worker1.id,
        device_id="Samsung-Galaxy-A14",
        client_timestamp=datetime.utcnow() - timedelta(hours=2),
        synced_patients=4,
        synced_screenings=4,
        synced_referrals=2,
        conflicts_resolved=0,
        status="SUCCESS",
        payload_summary={"synced_records": 10}
    )
    db.add(sync1)

    # 9. Audit Log
    audit1 = AuditLog(
        id=str(uuid.uuid4()),
        user_id=worker_user1.id,
        action="SYNC",
        entity_type="SyncEvent",
        details="Offline batch sync completed successfully (10 records)",
        ip_address="127.0.0.1"
    )
    db.add(audit1)

    db.commit()
    print("Seed data successfully populated!")
