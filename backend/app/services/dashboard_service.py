from typing import Dict, List, Any
from sqlalchemy.orm import Session
from sqlalchemy import func
from backend.app.models.patient import Patient
from backend.app.models.screening import Screening
from backend.app.models.referral import Referral
from backend.app.models.location import Location
from backend.app.schemas.dashboard import (
    DashboardSummaryResponse, RiskDistributionResponse, LocationSummaryItem, DemographicsSummaryResponse
)

class DashboardService:
    @staticmethod
    def get_summary(db: Session) -> DashboardSummaryResponse:
        total_patients = db.query(Patient).count()
        total_screenings = db.query(Screening).count()
        
        normal_count = db.query(Screening).filter(Screening.final_risk_category == "NORMAL").count()
        mild_count = db.query(Screening).filter(Screening.final_risk_category == "MILD").count()
        moderate_count = db.query(Screening).filter(Screening.final_risk_category == "MODERATE").count()
        high_count = db.query(Screening).filter(Screening.final_risk_category == "SEVERE").count()
        
        pending_referrals = db.query(Referral).filter(Referral.status.in_(["Pending", "Referred"])).count()
        completed_referrals = db.query(Referral).filter(Referral.status == "Lab Test Completed").count()
        pending_sync_count = db.query(Screening).filter(Screening.sync_status == "PENDING").count()
        
        return DashboardSummaryResponse(
            total_patients=total_patients,
            total_screenings=total_screenings,
            normal_count=normal_count,
            mild_count=mild_count,
            moderate_count=moderate_count,
            high_count=high_count,
            pending_referrals=pending_referrals,
            completed_referrals=completed_referrals,
            pending_sync_count=pending_sync_count
        )

    @staticmethod
    def get_risk_distribution(db: Session) -> RiskDistributionResponse:
        normal = db.query(Screening).filter(Screening.final_risk_category == "NORMAL").count()
        mild = db.query(Screening).filter(Screening.final_risk_category == "MILD").count()
        moderate = db.query(Screening).filter(Screening.final_risk_category == "MODERATE").count()
        severe = db.query(Screening).filter(Screening.final_risk_category == "SEVERE").count()
        total = normal + mild + moderate + severe
        
        if total == 0:
            percentages = {"NORMAL": 0.0, "MILD": 0.0, "MODERATE": 0.0, "SEVERE": 0.0}
        else:
            percentages = {
                "NORMAL": round((normal / total) * 100, 1),
                "MILD": round((mild / total) * 100, 1),
                "MODERATE": round((moderate / total) * 100, 1),
                "SEVERE": round((severe / total) * 100, 1),
            }
            
        return RiskDistributionResponse(
            NORMAL=normal,
            MILD=mild,
            MODERATE=moderate,
            SEVERE=severe,
            percentages=percentages
        )

    @staticmethod
    def get_location_summary(db: Session) -> List[LocationSummaryItem]:
        results = []
        villages = db.query(Patient.village).distinct().filter(Patient.village != None).all()
        
        for (v_name,) in villages:
            patients = db.query(Patient).filter(Patient.village == v_name).all()
            patient_ids = [p.id for p in patients]
            screenings = db.query(Screening).filter(Screening.patient_id.in_(patient_ids)).all()
            
            total_sc = len(screenings)
            high_sc = sum(1 for s in screenings if s.final_risk_category == "SEVERE")
            mod_sc = sum(1 for s in screenings if s.final_risk_category == "MODERATE")
            mild_sc = sum(1 for s in screenings if s.final_risk_category == "MILD")
            norm_sc = sum(1 for s in screenings if s.final_risk_category == "NORMAL")
            
            high_pct = round(((high_sc + mod_sc) / total_sc * 100.0), 1) if total_sc > 0 else 0.0
            
            results.append(
                LocationSummaryItem(
                    village=v_name,
                    district="Varanasi",
                    total_screenings=total_sc,
                    high_risk_count=high_sc,
                    moderate_risk_count=mod_sc,
                    mild_risk_count=mild_sc,
                    normal_count=norm_sc,
                    high_risk_percentage=high_pct
                )
            )
        return results

    @staticmethod
    def get_demographics_summary(db: Session) -> DemographicsSummaryResponse:
        # Age brackets
        brackets = {
            "0-5": (0, 5),
            "6-12": (6, 12),
            "13-18": (13, 18),
            "19-30": (19, 30),
            "31-45": (31, 45),
            "46+": (46, 150)
        }
        age_groups = {k: {"NORMAL": 0, "MILD": 0, "MODERATE": 0, "SEVERE": 0} for k in brackets}
        
        all_screenings = db.query(Screening).all()
        for s in all_screenings:
            p = db.query(Patient).filter(Patient.id == s.patient_id).first()
            if p:
                for b_name, (low, high) in brackets.items():
                    if low <= p.age <= high:
                        cat = s.final_risk_category
                        if cat in age_groups[b_name]:
                            age_groups[b_name][cat] += 1
                        break

        # Pregnancy breakdown
        preg_groups = {
            "pregnant": {"NORMAL": 0, "MILD": 0, "MODERATE": 0, "SEVERE": 0},
            "not_pregnant": {"NORMAL": 0, "MILD": 0, "MODERATE": 0, "SEVERE": 0},
            "not_applicable": {"NORMAL": 0, "MILD": 0, "MODERATE": 0, "SEVERE": 0}
        }
        for s in all_screenings:
            p = db.query(Patient).filter(Patient.id == s.patient_id).first()
            if p and p.pregnancy_status in preg_groups:
                cat = s.final_risk_category
                if cat in preg_groups[p.pregnancy_status]:
                    preg_groups[p.pregnancy_status][cat] += 1

        # Gender breakdown
        gender_breakdown = {
            "female": db.query(Patient).filter(Patient.gender == "female").count(),
            "male": db.query(Patient).filter(Patient.gender == "male").count(),
            "other": db.query(Patient).filter(Patient.gender == "other").count()
        }

        # Screening timeline mock/history
        timeline = [
            {"date": "2026-08-23", "screenings": 12, "high_risk": 2},
            {"date": "2026-08-24", "screenings": 18, "high_risk": 4},
            {"date": "2026-08-25", "screenings": 24, "high_risk": 5},
            {"date": "2026-08-26", "screenings": 31, "high_risk": 7},
            {"date": "2026-08-27", "screenings": 38, "high_risk": 9},
        ]

        return DemographicsSummaryResponse(
            age_groups=age_groups,
            pregnancy_breakdown=preg_groups,
            gender_breakdown=gender_breakdown,
            timeline=timeline
        )
