"""
RaktDrishti Multi-Site Optical Risk Fusion Engine.
Combines optical biomarkers from Palpebral Conjunctiva, Nail Bed capillaries,
and Palmar creases weighted by regional image quality and model confidence.
"""

from typing import Dict, Any, List, Optional
from dataclasses import dataclass

@dataclass
class SiteInference:
    site_type: str  # 'conjunctiva', 'nail', 'palm'
    risk_score: float  # 0.0 to 1.0
    quality_score: float  # 0.0 to 100.0 (normalized to 0.0-1.0 internally)
    confidence: float  # 0.0 to 1.0
    features: Dict[str, float]

class MultiSiteRiskFusion:
    """
    Fuses multi-site predictions using quality-and-confidence weighted formula:
    Final Score = Σ (score_i * quality_i * confidence_i) / Σ (quality_i * confidence_i)
    """
    
    # Regional baseline clinical sensitivity prior weights
    SITE_PRIORS = {
        "conjunctiva": 0.45,  # Mucosal membrane, zero melanin
        "nail": 0.30,         # Capillary bed perfusion
        "palm": 0.25          # Crease pallor
    }

    @classmethod
    def fuse_predictions(cls, sites: List[SiteInference]) -> Dict[str, Any]:
        if not sites:
            return {
                "final_risk_score": 0.0,
                "final_risk_category": "NORMAL",
                "overall_confidence": 0.0,
                "sites_evaluated": []
            }

        weighted_score_sum = 0.0
        total_weights = 0.0
        confidence_accum = 0.0
        site_details = {}

        for site in sites:
            # Normalized quality weight (0.0 to 1.0)
            norm_quality = max(0.01, min(1.0, site.quality_score / 100.0))
            prior = cls.SITE_PRIORS.get(site.site_type, 0.33)
            
            # Effective combined weight
            effective_weight = prior * norm_quality * max(0.1, site.confidence)
            
            weighted_score_sum += site.risk_score * effective_weight
            total_weights += effective_weight
            confidence_accum += site.confidence * norm_quality
            
            site_details[site.site_type] = {
                "score": round(site.risk_score, 3),
                "quality": round(site.quality_score, 1),
                "confidence": round(site.confidence, 3),
                "effective_weight": round(effective_weight, 3)
            }

        final_score = weighted_score_sum / max(1e-5, total_weights)
        final_score = float(max(0.0, min(1.0, final_score)))
        
        overall_confidence = float(min(0.98, confidence_accum / len(sites)))

        # Categorize
        if final_score < 0.36:
            category = "NORMAL"
        elif final_score < 0.56:
            category = "MILD"
        elif final_score < 0.76:
            category = "MODERATE"
        else:
            category = "SEVERE"

        return {
            "final_risk_score": round(final_score, 3),
            "final_risk_category": category,
            "overall_confidence": round(overall_confidence, 3),
            "sites_evaluated": [s.site_type for s in sites],
            "per_site_breakdown": site_details
        }
