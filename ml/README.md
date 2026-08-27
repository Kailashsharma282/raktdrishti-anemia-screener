# RaktDrishti Machine Learning Architecture & Development Pipeline

## 1. Overview
The `ml/` subsystem handles all optical feature engineering, color calibration matrix calculations, multi-site confidence fusion, and model evaluation for the RaktDrishti platform.

## 2. Directory Structure
- `preprocessing/`: Color calibration card patch segmentation, 3x3 CCM computation, illumination normalization.
- `features/`: Optical biomarker extraction (Erythema Index, CIELAB $a^*$, Hemoglobin Color Index, Palmar Pallor, Subungual Capillary Redness) and Image Quality Assessment (IQA).
- `training/`: Multi-site confidence-and-quality weighted fusion model.
- `evaluation/`: Clinical screening evaluation suite (Accuracy, Precision, Recall/Sensitivity, Specificity, ROC-AUC, Confusion Matrix).
- `conversion/`: TensorFlow Lite export and metadata generation.
- `demo_model/`: Plug-and-play adapter architecture and deterministic demo inference engine.

## 3. Running Evaluation
```bash
python ml/evaluation/evaluate.py
```

## 4. Replacing Demo Weights with Clinically Validated Model
To deploy real weights from prospective clinical trials:
1. Export your trained TensorFlow/PyTorch model to TFLite format using INT8 quantization.
2. Save the `.tflite` file into `mobile/assets/ml/raktdrishti_clinical_v1.tflite`.
3. In `mobile/lib/ml/anemia_risk_model.dart`, toggle `useTfliteNative = true`.
4. Update `MODEL_VERSION` to match your registered clinical trial identifier.
