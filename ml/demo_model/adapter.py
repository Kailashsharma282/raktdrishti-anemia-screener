"""
RaktDrishti ML Inference Abstraction & Model Adapter.
Executes trained Multi-Site Gradient Boosting ensemble inference on optical features
(Palpebral Conjunctiva, Nail Bed capillaries, Palmar creases) and falls back
gracefully to deterministic optical heuristics when running in lightweight environments.
"""

import os
import joblib
import numpy as np
from typing import Dict, Any, List
from ml.training.fusion import MultiSiteRiskFusion, SiteInference

class AnemiaRiskModel:
    """
    Standard Machine Learning Inference Interface for RaktDrishti.
    Uses trained Gradient Boosting weights if present; otherwise runs calibrated optical heuristic.
    """
    MODEL_NAME = "RaktDrishti-MultiSite-GradientBoosting"
    MODEL_VERSION = "v1.2.0-trained-ensemble"

    def __init__(self, model_path: str = None):
        if not model_path:
            model_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "trained_anemia_fusion_model.joblib"))
        
        self.model_path = model_path
        self.trained_bundle = None
        self.is_trained_model = False

        if os.path.exists(model_path):
            try:
                self.trained_bundle = joblib.load(model_path)
                self.clf = self.trained_bundle["classifier"]
                self.reg = self.trained_bundle["regressor"]
                self.scaler = self.trained_bundle["scaler"]
                self.feature_names = self.trained_bundle["feature_names"]
                self.classes = self.trained_bundle["classes"]
                self.is_trained_model = True
            except Exception as e:
                self.is_trained_model = False

    def predict(
        self,
        conjunctiva_features: Dict[str, float],
        nail_features: Dict[str, float],
        palm_features: Dict[str, float],
        quality_scores: Dict[str, float]
    ) -> Dict[str, Any]:
        """
        Executes multi-site feature inference and fusion.
        """
        ei = conjunctiva_features.get("erythema_index", 0.40)
        lab_a_conj = conjunctiva_features.get("lab_a", 16.0)
        hci = conjunctiva_features.get("hci", 0.65)
        nail_redness = nail_features.get("nail_capillary_redness", 0.42)
        nail_perfusion = nail_features.get("nail_perfusion", 0.70)
        palm_pallor = palm_features.get("palmar_pallor_index", 3.2)
        q_conj = quality_scores.get("conjunctiva", 88.0)
        q_nail = quality_scores.get("nail", 90.0)
        q_palm = quality_scores.get("palm", 85.0)

        # If trained ML model is available, perform inference with Gradient Boosting
        if self.is_trained_model:
            # Construct feature vector matching trained schema
            # ["conjunctiva_erythema_index", "conjunctiva_lab_a", "conjunctiva_hci",
            #  "nail_capillary_redness", "nail_perfusion_index", "palmar_pallor_index",
            #  "conjunctiva_quality", "nail_quality", "palm_quality", "fitzpatrick_scale"]
            feat_vector = np.array([[
                float(ei),
                float(lab_a_conj),
                float(hci),
                float(nail_redness),
                float(nail_perfusion),
                float(palm_pallor),
                float(q_conj),
                float(q_nail),
                float(q_palm),
                4.0  # Median Fitzpatrick scale baseline
            ]])

            X_scaled = self.scaler.transform(feat_vector)
            pred_category = str(self.clf.predict(X_scaled)[0])
            pred_score = float(np.clip(self.reg.predict(X_scaled)[0], 0.05, 0.98))
            
            # Predict class probabilities
            probs = self.clf.predict_proba(X_scaled)[0]
            confidence = float(np.max(probs))

            # Quality weighted breakdown
            overall_quality = round((q_conj * 0.45 + q_nail * 0.30 + q_palm * 0.25), 1)

            return {
                "final_risk_score": round(pred_score, 3),
                "final_risk_category": pred_category,
                "overall_confidence": round(confidence, 3),
                "overall_quality": overall_quality,
                "model_name": self.MODEL_NAME,
                "model_version": self.MODEL_VERSION,
                "is_trained_model": True,
                "is_demo_adapter": False,
                "sites_evaluated": ["conjunctiva", "nail", "palm"],
                "per_site_breakdown": {
                    "conjunctiva": {"erythema_index": round(ei, 3), "lab_a": round(lab_a_conj, 1), "quality": q_conj},
                    "nail": {"capillary_redness": round(nail_redness, 3), "quality": q_nail},
                    "palm": {"palmar_pallor_index": round(palm_pallor, 2), "quality": q_palm}
                }
            }

        # Fallback to calibrated optical heuristic
        conj_risk = float(max(0.05, min(0.95, 1.0 - (ei * 1.2 + (lab_a_conj / 35.0)) / 2.0)))
        nail_risk = float(max(0.05, min(0.95, 1.0 - (nail_redness * 2.1))))
        palm_risk = float(max(0.05, min(0.95, palm_pallor / 6.0)))

        sites = [
            SiteInference(
                site_type="conjunctiva",
                risk_score=conj_risk,
                quality_score=q_conj,
                confidence=0.86,
                features=conjunctiva_features
            ),
            SiteInference(
                site_type="nail",
                risk_score=nail_risk,
                quality_score=q_nail,
                confidence=0.82,
                features=nail_features
            ),
            SiteInference(
                site_type="palm",
                risk_score=palm_risk,
                quality_score=q_palm,
                confidence=0.79,
                features=palm_features
            ),
        ]

        fusion_result = MultiSiteRiskFusion.fuse_predictions(sites)
        fusion_result["model_name"] = "RaktDrishti-MultiSite-Fusion-Heuristic"
        fusion_result["model_version"] = "v1.0.0-mvp-demo"
        fusion_result["is_trained_model"] = False
        fusion_result["is_demo_adapter"] = True
        
        return fusion_result
