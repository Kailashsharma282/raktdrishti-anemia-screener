# Machine Learning & Color Calibration Pipeline

> **Disclaimer**: RaktDrishti is an engineering triage prototype. In the absence of prospective clinical trial datasets, all mathematical models and weights are structured as modular adapters. They demonstrate production-ready architectural pipelines without fabricating fraudulent medical validation.

---

## 1. Color Calibration & Normalization Engine

Smartphone camera sensors have different spectral response functions, auto-white-balance (AWB) algorithms, and exposure curves. Ambient lighting in rural clinics ranges from direct outdoor sunlight (~5500K) to dim tungsten (~2700K).

### 1.1 Reference Color Card
The RaktDrishti printable calibration card contains 12 standard reference patches:
- **Achromatic Row**: Pure White (95%), Light Gray (75%), Neutral Gray 18% ($L^*=50$), Dark Gray (25%), Pure Black (5%).
- **Primary / Secondary Colors**: High-saturation Red, Green, Blue, Cyan, Magenta, Yellow.
- **Fitzpatrick Skin Tone Reference Patches**: Type I through Type VI baseline melanin tiles.

### 1.2 Transformation Algorithm
1. **Patch Detection**: The preprocessor localizes the card fiducial corner markers and segments each known color patch.
2. **Illuminant Estimation**: The 18% neutral gray patch is used to compute white-point chromaticity coordinates $(x_w, y_w)$.
3. **Linear Color Correction Matrix (CCM)**:
   A $3 \times 3$ affine matrix $M$ is estimated via constrained Least Squares optimization:
   $$\begin{bmatrix} R_{\text{cal}} \\ G_{\text{cal}} \\ B_{\text{cal}} \end{bmatrix} = \mathbf{M} \times \begin{bmatrix} R_{\text{raw}} \\ G_{\text{raw}} \\ B_{\text{raw}} \end{bmatrix}$$
   such that $\sum_{k=1}^{N} \|\mathbf{M} \mathbf{p}_{\text{raw}, k} - \mathbf{p}_{\text{target}, k}\|^2$ is minimized.
4. **CIELAB Conversion**: Images are converted to standard CIE $L^*a^*b^*$ color space using standard D65 illuminant white reference.

---

## 2. Anatomical Feature Extraction

### 2.1 Palpebral Conjunctiva
The lower inner eyelid is an optimal screening site because the thin mucosal epithelial membrane has no melanocytes, allowing direct optical observation of microvascular hemoglobin absorption.
- **Erythema Index ($EI$)**:
  $$EI = \log_{10}(S_{\text{Red}}) - \log_{10}(S_{\text{Green}})$$
  Lower values correlate with pallor and lower hemoglobin content.
- **Red-Green Chrominance ($a^*$ in CIELAB)**: Captures blood vascularity independent of luminance $L^*$.
- **Hemoglobin Color Index ($HCI$)**:
  $$HCI = \frac{R - G}{R + G + \epsilon}$$

### 2.2 Nail Beds
- **Vascularity Quotient**: Measures capillary bed redness in subungual tissue.
- **Pressure Artifact Rejection**: Detects blanche spots caused by excessive finger pressure.

### 2.3 Palmar Creases
- **Crease vs Palmar Base Contrast**: In healthy individuals, palmar flexion creases are distinctly hyperpigmented/red compared to surrounding skin. In severe anemia ($Hb < 7\text{ g/dL}$), creases lose pigmentation and match surrounding skin pallor.

---

## 3. Image Quality Assessment (IQA) Engine

Before inference, images undergo automated quality checks ($0 - 100$ score):

$$\text{Quality Score} = 0.25 \times S_{\text{sharpness}} + 0.20 \times S_{\text{brightness}} + 0.20 \times S_{\text{contrast}} + 0.20 \times S_{\text{card\_vis}} + 0.15 \times S_{\text{region\_vis}}$$

- **Sharpness**: Laplacian variance threshold $\sigma^2(\nabla^2 I)$. Rejects motion blur.
- **Exposure**: Histograms checking for overexposed clipping ($R > 250$) or underexposed shadows ($R < 15$).
- **Calibration Visibility**: Geometric confidence of card corner fiducials.
- **Rejection Threshold**: Score $< 60.0$ triggers immediate feedback: *"Image quality is too low. Move to brighter indirect light and try again."*

---

## 4. Multi-Site Confidence-Weighted Fusion

Individual site features are processed through calibrated regression/classification heads to yield site risk scores $s_i \in [0.0, 1.0]$, quality scores $q_i \in [0.0, 1.0]$, and confidence values $c_i \in [0.0, 1.0]$:

$$\text{Final Risk Score} = \frac{\sum_{i \in \{\text{conj}, \text{nail}, \text{palm}\}} s_i \cdot q_i \cdot c_i}{\sum_{i \in \{\text{conj}, \text{nail}, \text{palm}\}} q_i \cdot c_i}$$

### Risk Categorization Thresholds
| Risk Category | Score Range | Clinical Action Recommendation |
|---|---|---|
| **NORMAL** | $0.00 - 0.35$ | Routine annual checkup. Low risk detected. |
| **MILD RISK** | $0.36 - 0.55$ | Dietary counseling & iron-rich nutrition guidance. |
| **MODERATE RISK** | $0.56 - 0.75$ | Confirmatory blood test (CBC) at Primary Health Centre. |
| **SEVERE RISK** | $0.76 - 1.00$ | Urgent referral to Community Health Centre / District Hospital. |

---

## 5. Model Architecture & TensorFlow Lite Conversion

```
Input Features [Conjunctiva (8) + Nail (6) + Palm (6) + Calibration (6) + Quality (3)]
                           │
                           ▼
               Dense(64, ReLU) + BatchNorm + Dropout(0.2)
                           │
                           ▼
               Dense(32, ReLU) + BatchNorm
                           │
                 ┌─────────┴─────────┐
                 ▼                   ▼
    Risk Regression Head     Risk Classifier Head
     Dense(1, Sigmoid)        Dense(4, Softmax)
    [Continuous 0.0-1.0]     [Normal/Mild/Mod/Sev]
```

Converted to `tflite` format using INT8 dynamic range quantization for low-latency on-device execution on budget Android smartphones ($< 45\text{ms}$ inference latency).
