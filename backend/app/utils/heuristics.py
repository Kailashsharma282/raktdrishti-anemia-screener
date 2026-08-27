from typing import Tuple, Dict, Any

def calculate_risk_category(risk_score: float) -> str:
    """
    Maps continuous risk score [0.0, 1.0] to standardized screening risk categories:
    - 0.00 - 0.35: NORMAL
    - 0.36 - 0.55: MILD
    - 0.56 - 0.75: MODERATE
    - 0.76 - 1.00: SEVERE
    """
    if risk_score < 0.36:
        return "NORMAL"
    elif risk_score < 0.56:
        return "MILD"
    elif risk_score < 0.76:
        return "MODERATE"
    else:
        return "SEVERE"

def calculate_quality_score(
    sharpness: float,
    brightness: float,
    contrast: float,
    calibration_visibility: float,
    region_visibility: float
) -> float:
    """
    Computes weighted Image Quality Assessment score (0-100).
    Formula from engineering specs:
    quality = 0.25*sharpness + 0.20*brightness + 0.20*contrast + 0.20*calib_vis + 0.15*region_vis
    """
    score = (
        0.25 * max(0.0, min(100.0, sharpness)) +
        0.20 * max(0.0, min(100.0, brightness)) +
        0.20 * max(0.0, min(100.0, contrast)) +
        0.20 * max(0.0, min(100.0, calibration_visibility)) +
        0.15 * max(0.0, min(100.0, region_visibility))
    )
    return round(score, 1)

def get_guidance_text(risk_category: str) -> Dict[str, Any]:
    """Returns standardized clinical guidance and safe triage wording."""
    disclaimer = "RaktDrishti is a screening aid and does not diagnose anemia."
    
    if risk_category in ["MODERATE", "SEVERE"]:
        action = "Please visit a healthcare facility for a confirmatory blood test."
        detail = (
            "This screening suggests an elevated anemia risk. A confirmatory venous blood test "
            "(Complete Blood Count / Hemoglobin) is required at the nearest PHC/CHC."
        )
        referral_needed = True
    elif risk_category == "MILD":
        action = "Dietary counseling & routine follow-up recommended."
        detail = (
            "Low-to-moderate risk indicated. Recommend iron-rich nutrition (green leafy vegetables, jaggery) "
            "and follow-up in 30 days."
        )
        referral_needed = False
    else:
        action = "Low anemia risk detected."
        detail = (
            "A low-risk result does not rule out anemia or replace clinical evaluation when symptoms "
            "(fatigue, paleness, dizziness) are present."
        )
        referral_needed = False
        
    return {
        "disclaimer": disclaimer,
        "action": action,
        "detail": detail,
        "referral_needed": referral_needed
    }
