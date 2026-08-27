import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))

import numpy as np
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    confusion_matrix,
    classification_report
)
from ml.demo_model.adapter import AnemiaRiskModel

def generate_synthetic_evaluation_cohort(n_samples: int = 200, seed: int = 42):
    """
    Generates realistic synthetic evaluation cohort spanning normal, mild, moderate, and severe anemia cases.
    NOTE: Real clinical trials with certified laboratory venous Hb validation are required for actual deployment.
    """
    np.random.seed(seed)
    # Ground truth: 0 = Low Risk (Normal), 1 = Elevated Risk (Mild/Mod/Severe)
    y_true_binary = np.random.choice([0, 1], size=n_samples, p=[0.45, 0.55])
    
    y_scores = []
    y_pred_binary = []

    model = AnemiaRiskModel()

    for is_anemic in y_true_binary:
        if is_anemic == 1:
            # Pale conjunctiva, reduced redness
            conj_features = {
                "erythema_index": float(np.random.normal(0.22, 0.05)),
                "lab_a": float(np.random.normal(12.0, 2.5))
            }
            nail_features = {
                "nail_capillary_redness": float(np.random.normal(0.33, 0.04))
            }
            palm_features = {
                "palmar_pallor_index": float(np.random.normal(4.2, 0.6))
            }
        else:
            # Healthy mucosal perfusion
            conj_features = {
                "erythema_index": float(np.random.normal(0.48, 0.06)),
                "lab_a": float(np.random.normal(22.0, 3.0))
            }
            nail_features = {
                "nail_capillary_redness": float(np.random.normal(0.44, 0.04))
            }
            palm_features = {
                "palmar_pallor_index": float(np.random.normal(2.1, 0.4))
            }

        quality_scores = {
            "conjunctiva": float(np.random.uniform(80, 95)),
            "nail": float(np.random.uniform(80, 95)),
            "palm": float(np.random.uniform(75, 92))
        }

        res = model.predict(conj_features, nail_features, palm_features, quality_scores)
        score = res["final_risk_score"]
        y_scores.append(score)
        y_pred_binary.append(1 if score >= 0.36 else 0)

    return np.array(y_true_binary), np.array(y_pred_binary), np.array(y_scores)

def run_evaluation():
    y_true, y_pred, y_scores = generate_synthetic_evaluation_cohort(200)

    acc = accuracy_score(y_true, y_pred)
    prec = precision_score(y_true, y_pred)
    rec = recall_score(y_true, y_pred)  # Sensitivity
    f1 = f1_score(y_true, y_pred)
    roc_auc = roc_auc_score(y_true, y_scores)
    cm = confusion_matrix(y_true, y_pred)
    
    # Specificity = TN / (TN + FP)
    tn, fp, fn, tp = cm.ravel()
    spec = tn / (tn + fp) if (tn + fp) > 0 else 0.0

    print("=" * 60)
    print("      RAKTDRISHTI ML EVALUATION REPORT (SYNTHETIC BENCHMARK)")
    print("=" * 60)
    print(f"Total Cohort Size : {len(y_true)} samples")
    print(f"Accuracy          : {acc * 100:.2f}%")
    print(f"Sensitivity/Recall: {rec * 100:.2f}% (Critical for Screening Triage)")
    print(f"Specificity       : {spec * 100:.2f}%")
    print(f"Precision         : {prec * 100:.2f}%")
    print(f"F1-Score          : {f1:.4f}")
    print(f"ROC-AUC           : {roc_auc:.4f}")
    print("-" * 60)
    print(f"Confusion Matrix  : \n  True Negative: {tn:3d}  |  False Positive: {fp:3d}\n  False Negative: {fn:3d} |  True Positive:  {tp:3d}")
    print("=" * 60)
    print("NOTE: These results demonstrate pipeline execution on synthetic benchmarks.")
    print("Prospective clinical trials are mandatory prior to clinical deployment.")
    print("=" * 60)

    return {
        "accuracy": acc,
        "sensitivity": rec,
        "specificity": spec,
        "precision": prec,
        "f1": f1,
        "roc_auc": roc_auc,
        "confusion_matrix": cm.tolist()
    }

if __name__ == "__main__":
    run_evaluation()
