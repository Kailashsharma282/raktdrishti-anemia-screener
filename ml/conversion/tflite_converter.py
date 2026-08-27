"""
RaktDrishti TensorFlow Lite Exporter & Quantizer.
Structures the TFLite conversion pipeline for on-device Android deployment.
"""

import os
import json

def export_tflite_model_metadata(output_path: str = "ml/demo_model/model_metadata.json"):
    """
    Exports model metadata specification conforming to TFLite Task Library.
    """
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    metadata = {
        "name": "RaktDrishti Non-Invasive Anemia Risk Model",
        "version": "v1.0.0-mvp-demo",
        "description": "Multi-site optical colorimetric feature fusion model for anemia screening.",
        "author": "Omnikon 2026 BioTech Team",
        "inputs": [
            {
                "name": "conjunctiva_features",
                "type": "FLOAT32",
                "shape": [1, 6],
                "description": "Erythema Index, CIELAB L*, a*, b*, HCI, Red Ratio"
            },
            {
                "name": "nail_features",
                "type": "FLOAT32",
                "shape": [1, 4],
                "description": "Capillary redness, Vascularity Index, L*, a*"
            },
            {
                "name": "palm_features",
                "type": "FLOAT32",
                "shape": [1, 4],
                "description": "Palmar pallor index, Erythema, L*, a*"
            },
            {
                "name": "quality_scores",
                "type": "FLOAT32",
                "shape": [1, 3],
                "description": "Image quality assessment scores for each site"
            }
        ],
        "outputs": [
            {
                "name": "risk_score",
                "type": "FLOAT32",
                "shape": [1, 1],
                "description": "Continuous anemia risk score between 0.0 and 1.0"
            },
            {
                "name": "risk_probabilities",
                "type": "FLOAT32",
                "shape": [1, 4],
                "description": "Probabilities over [NORMAL, MILD, MODERATE, SEVERE]"
            }
        ],
        "license": "Apache-2.0",
        "clinical_safety_notice": "Screening aid only. Does not replace clinical laboratory hematology analyzer."
    }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)
    print(f"Model metadata exported: {output_path}")

if __name__ == "__main__":
    export_tflite_model_metadata()
