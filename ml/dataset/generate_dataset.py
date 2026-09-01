"""
RaktDrishti Clinical Optical Biomarker Dataset Generator.
Synthesizes a realistic multi-site training cohort based on published clinical literature
relating palpebral conjunctiva, fingernail capillary beds, and palmar creases to reference
venous laboratory hemoglobin concentrations (WHO guidelines: Normal >= 12.0, Mild 11.0-11.9,
Moderate 8.0-10.9, Severe < 8.0 g/dL).
"""

import os
import numpy as np
import pandas as pd

def generate_multi_site_dataset(n_samples: int = 2500, seed: int = 42, output_path: str = None) -> pd.DataFrame:
    np.random.seed(seed)

    # 1. Target: Venous Hemoglobin (g/dL) distribution modeled on Indian population demographics (NFHS-5)
    # Range: 4.5 to 16.5 g/dL with elevated prevalence in 8.0-11.5 g/dL
    hb_values = np.concatenate([
        np.random.normal(loc=13.4, scale=1.1, size=int(n_samples * 0.40)),  # Normal
        np.random.normal(loc=11.4, scale=0.3, size=int(n_samples * 0.20)),  # Mild Anemia
        np.random.normal(loc=9.4, scale=0.8, size=int(n_samples * 0.25)),   # Moderate Anemia
        np.random.normal(loc=6.8, scale=0.8, size=int(n_samples * 0.15)),   # Severe Anemia
    ])
    np.random.shuffle(hb_values)
    hb_values = np.clip(hb_values, 4.0, 17.5)

    # 2. Derive Categories based on WHO diagnostic cutoffs
    categories = []
    binary_risk = []
    for hb in hb_values:
        if hb >= 12.0:
            categories.append("NORMAL")
            binary_risk.append(0)
        elif hb >= 11.0:
            categories.append("MILD")
            binary_risk.append(1)
        elif hb >= 8.0:
            categories.append("MODERATE")
            binary_risk.append(1)
        else:
            categories.append("SEVERE")
            binary_risk.append(1)

    # 3. Simulate Optical Features Correlated with Hemoglobin
    # (a) Palpebral Conjunctiva:
    # Erythema Index (EI): high Hb => high redness (0.42 to 0.58), low Hb => pale (0.12 to 0.30)
    ei = 0.032 * hb_values + np.random.normal(0, 0.035, size=len(hb_values))
    ei = np.clip(ei, 0.10, 0.65)

    # CIELAB a* (chromatic redness): high Hb => 18 to 28, low Hb => 6 to 14
    lab_a = 1.65 * hb_values + np.random.normal(0, 1.8, size=len(hb_values))
    lab_a = np.clip(lab_a, 4.0, 32.0)

    # Hemoglobin Color Index (HCI):
    hci = 0.058 * hb_values + np.random.normal(0, 0.05, size=len(hb_values))
    hci = np.clip(hci, 0.20, 1.10)

    # (b) Fingernail Beds:
    # Capillary redness ratio: high Hb => 0.40 to 0.50, low Hb => 0.25 to 0.35
    nail_redness = 0.022 * hb_values + np.random.normal(0, 0.03, size=len(hb_values))
    nail_redness = np.clip(nail_redness, 0.18, 0.55)

    nail_perfusion = 0.065 * hb_values + np.random.normal(0, 0.08, size=len(hb_values))
    nail_perfusion = np.clip(nail_perfusion, 0.20, 1.0)

    # (c) Palmar Creases:
    # Pallor Index (inverse contrast): low Hb => high pallor (4.0 to 6.5), high Hb => low pallor (1.5 to 3.0)
    palm_pallor = 8.5 - (0.45 * hb_values) + np.random.normal(0, 0.4, size=len(hb_values))
    palm_pallor = np.clip(palm_pallor, 1.0, 7.5)

    # (d) Image Quality Metrics (Simulated IQA scores 70 - 98)
    q_conj = np.random.uniform(75.0, 96.0, size=len(hb_values))
    q_nail = np.random.uniform(78.0, 97.0, size=len(hb_values))
    q_palm = np.random.uniform(72.0, 95.0, size=len(hb_values))

    # (e) Skin Tone Diversity (Fitzpatrick Scale I to VI)
    fitzpatrick = np.random.choice([1, 2, 3, 4, 5, 6], size=len(hb_values), p=[0.05, 0.10, 0.25, 0.35, 0.20, 0.05])

    df = pd.DataFrame({
        "sample_id": [f"RD-SYNTH-{i:05d}" for i in range(len(hb_values))],
        "hb_venous_ref": np.round(hb_values, 2),
        "anemia_risk_category": categories,
        "is_elevated_risk": binary_risk,
        "conjunctiva_erythema_index": np.round(ei, 4),
        "conjunctiva_lab_a": np.round(lab_a, 2),
        "conjunctiva_hci": np.round(hci, 3),
        "nail_capillary_redness": np.round(nail_redness, 4),
        "nail_perfusion_index": np.round(nail_perfusion, 3),
        "palmar_pallor_index": np.round(palm_pallor, 3),
        "conjunctiva_quality": np.round(q_conj, 1),
        "nail_quality": np.round(q_nail, 1),
        "palm_quality": np.round(q_palm, 1),
        "fitzpatrick_scale": fitzpatrick
    })

    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        df.to_csv(output_path, index=False)
        print(f"[OK] Successfully generated synthetic clinical dataset ({len(df)} samples) at {output_path}")

    return df

if __name__ == "__main__":
    output = os.path.abspath(os.path.join(os.path.dirname(__file__), "anemia_multi_site_cohort.csv"))
    generate_multi_site_dataset(n_samples=2500, output_path=output)
