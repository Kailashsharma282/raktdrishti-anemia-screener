"""
RaktDrishti Multi-Site Optical Machine Learning Training Engine.
Trains a Gradient Boosting classifier and regressor on multi-site optical biomarkers
(Conjunctiva + Nail + Palm) to predict anemia risk category and continuous risk score.
Exports trained weights to ml/demo_model/trained_anemia_fusion_model.joblib.
"""

import os
import sys
import datetime
import joblib
import numpy as np
import pandas as pd

from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import GradientBoostingClassifier, GradientBoostingRegressor
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    confusion_matrix,
    classification_report
)

# Local imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))
from ml.dataset.generate_dataset import generate_multi_site_dataset

def train_model(dataset_path: str = None, export_path: str = None):
    # 1. Load or Generate Dataset
    if dataset_path and os.path.exists(dataset_path):
        print(f"Loading existing cohort dataset from {dataset_path}...")
        df = pd.read_csv(dataset_path)
    else:
        print("Generating synthetic 2,500-sample multi-site clinical training cohort...")
        csv_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../dataset/anemia_multi_site_cohort.csv"))
        df = generate_multi_site_dataset(n_samples=2500, output_path=csv_path)

    # 2. Feature Columns
    feature_cols = [
        "conjunctiva_erythema_index",
        "conjunctiva_lab_a",
        "conjunctiva_hci",
        "nail_capillary_redness",
        "nail_perfusion_index",
        "palmar_pallor_index",
        "conjunctiva_quality",
        "nail_quality",
        "palm_quality",
        "fitzpatrick_scale"
    ]

    X = df[feature_cols].values
    y_cat = df["anemia_risk_category"].values
    y_binary = df["is_elevated_risk"].values
    
    # Continuous Risk Score: mapped monotonically from venous Hb (e.g. 15 g/dL => ~0.1, 7 g/dL => ~0.9)
    # Risk Score = clip(1.0 - (hb - 5.0) / 10.0, 0.05, 0.95)
    y_cont = np.clip(1.0 - (df["hb_venous_ref"].values - 5.0) / 10.0, 0.05, 0.95)

    # 3. Train-Test Split (80% Train, 20% Held-out Test)
    X_train, X_test, y_cat_train, y_cat_test, y_bin_train, y_bin_test, y_cont_train, y_cont_test = train_test_split(
        X, y_cat, y_binary, y_cont, test_size=0.20, random_state=42, stratify=y_cat
    )

    # 4. Standard Scaling
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    # 5. Model Architecture: Gradient Boosting Classifier & Regressor
    print("Training Multi-Site Gradient Boosting Classifier & Regressor...")
    clf = GradientBoostingClassifier(
        n_estimators=120,
        learning_rate=0.08,
        max_depth=4,
        subsample=0.85,
        random_state=42
    )
    clf.fit(X_train_scaled, y_cat_train)

    reg = GradientBoostingRegressor(
        n_estimators=100,
        learning_rate=0.08,
        max_depth=4,
        subsample=0.85,
        random_state=42
    )
    reg.fit(X_train_scaled, y_cont_train)

    # 6. Evaluation on Held-out Test Cohort
    y_cat_pred = clf.predict(X_test_scaled)
    y_cont_pred = reg.predict(X_test_scaled)

    # Binary triage predictions: Any non-NORMAL is elevated risk
    y_bin_pred = np.array([0 if c == "NORMAL" else 1 for c in y_cat_pred])

    acc = accuracy_score(y_cat_test, y_cat_pred)
    bin_acc = accuracy_score(y_bin_test, y_bin_pred)
    sensitivity = recall_score(y_bin_test, y_bin_pred)  # Sensitivity
    precision = precision_score(y_bin_test, y_bin_pred)
    f1 = f1_score(y_bin_test, y_bin_pred)
    
    # Binary probabilities for ROC-AUC
    classes = list(clf.classes_)
    normal_idx = classes.index("NORMAL") if "NORMAL" in classes else 0
    y_prob_anemic = 1.0 - clf.predict_proba(X_test_scaled)[:, normal_idx]
    roc_auc = roc_auc_score(y_bin_test, y_prob_anemic)

    cm = confusion_matrix(y_bin_test, y_bin_pred)
    tn, fp, fn, tp = cm.ravel()
    specificity = tn / (tn + fp) if (tn + fp) > 0 else 0.0

    print("=" * 65)
    print("       RAKTDRISHTI ML MODEL TRAINING & EVALUATION REPORT")
    print("=" * 65)
    print(f"Total Cohort Samples: {len(df)} (Train: {len(X_train)}, Test: {len(X_test)})")
    print(f"4-Tier Categorical Accuracy : {acc * 100:.2f}%")
    print(f"Binary Triage Accuracy       : {bin_acc * 100:.2f}%")
    print(f"Sensitivity / Recall (Triage): {sensitivity * 100:.2f}%")
    print(f"Specificity                  : {specificity * 100:.2f}%")
    print(f"Precision                    : {precision * 100:.2f}%")
    print(f"F1-Score                     : {f1:.4f}")
    print(f"ROC-AUC                      : {roc_auc:.4f}")
    print("-" * 65)
    print(f"Confusion Matrix (Triage):")
    print(f"  True Normal:   {tn:4d}  |  False Positive: {fp:4d}")
    print(f"  False Normal:  {fn:4d}  |  True Anemic:    {tp:4d}")
    print("=" * 65)

    # 7. Package and Export Trained Bundle
    if not export_path:
        export_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../demo_model/trained_anemia_fusion_model.joblib"))

    model_bundle = {
        "model_name": "RaktDrishti-MultiSite-GradientBoosting",
        "model_version": "v1.2.0-trained-ensemble",
        "training_timestamp": datetime.datetime.now().isoformat(),
        "classifier": clf,
        "regressor": reg,
        "scaler": scaler,
        "feature_names": feature_cols,
        "classes": classes,
        "metrics": {
            "accuracy": float(acc),
            "sensitivity": float(sensitivity),
            "specificity": float(specificity),
            "precision": float(precision),
            "f1_score": float(f1),
            "roc_auc": float(roc_auc)
        }
    }

    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    joblib.dump(model_bundle, export_path)
    print(f"[OK] Trained model bundle saved successfully to: {export_path}")

    return model_bundle

if __name__ == "__main__":
    train_model()
