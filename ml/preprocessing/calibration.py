"""
RaktDrishti Color Calibration & Lighting Normalization Engine.
Detects 12 standard color patches from camera frame and estimates
3x3 linear color correction matrix (CCM) to normalize illuminant shift and skin-tone bias.
"""

import numpy as np
from typing import Dict, Tuple, Optional

# Ground Truth D65 sRGB standard reference patch color values (0-255)
STANDARD_REFERENCE_PATCHES = {
    "white_95": np.array([242, 242, 242], dtype=np.float32),
    "gray_18": np.array([119, 119, 119], dtype=np.float32),
    "black_5": np.array([13, 13, 13], dtype=np.float32),
    "red_primary": np.array([211, 47, 47], dtype=np.float32),
    "green_primary": np.array([56, 142, 60], dtype=np.float32),
    "blue_primary": np.array([25, 118, 210], dtype=np.float32),
    "skin_type_1_2": np.array([252, 229, 216], dtype=np.float32),
    "skin_type_3": np.array([226, 172, 137], dtype=np.float32),
    "skin_type_4": np.array([189, 139, 103], dtype=np.float32),
    "skin_type_5": np.array([141, 85, 36], dtype=np.float32),
    "erythema_ref": np.array([229, 115, 115], dtype=np.float32),
    "pallor_ref": np.array([248, 187, 208], dtype=np.float32),
}

class ColorCalibrationEngine:
    def __init__(self, target_patches: Optional[Dict[str, np.ndarray]] = None):
        self.target_patches = target_patches or STANDARD_REFERENCE_PATCHES

    def estimate_color_correction_matrix(
        self, detected_patches: Dict[str, np.ndarray]
    ) -> Tuple[np.ndarray, float]:
        """
        Estimates 3x3 Color Correction Matrix (CCM) using constrained least-squares.
        Maps raw detected sensor RGB to calibrated standard sRGB space:
            RGB_calibrated = CCM @ RGB_raw
        Returns:
            CCM: 3x3 transformation matrix
            quality_delta_e: Mean residual color discrepancy error
        """
        raw_colors = []
        target_colors = []

        for name, target_rgb in self.target_patches.items():
            if name in detected_patches:
                raw_colors.append(detected_patches[name])
                target_colors.append(target_rgb)

        if len(raw_colors) < 3:
            # Fallback identity if insufficient patches detected
            return np.eye(3, dtype=np.float32), 0.0

        R_raw = np.array(raw_colors, dtype=np.float32)  # shape (N, 3)
        R_target = np.array(target_colors, dtype=np.float32)  # shape (N, 3)

        # Solve Least Squares: R_raw @ CCM.T = R_target => CCM.T = pinv(R_raw) @ R_target
        ccm_t, residuals, rank, s = np.linalg.lstsq(R_raw, R_target, rcond=None)
        ccm = ccm_t.T

        # Predict calibrated colors and calculate mean delta
        predicted = (ccm @ R_raw.T).T
        delta_e = float(np.mean(np.linalg.norm(predicted - R_target, axis=1)))

        return ccm.astype(np.float32), delta_e

    def apply_color_correction(self, image_rgb: np.ndarray, ccm: np.ndarray) -> np.ndarray:
        """
        Applies 3x3 CCM transformation to an entire RGB image array.
        """
        orig_shape = image_rgb.shape
        flat_rgb = image_rgb.reshape(-1, 3).astype(np.float32)
        calibrated_flat = np.dot(flat_rgb, ccm.T)
        calibrated_flat = np.clip(calibrated_flat, 0.0, 255.0)
        return calibrated_flat.reshape(orig_shape).astype(np.uint8)

    def compute_white_balance_gains(self, detected_gray_18: np.ndarray) -> np.ndarray:
        """
        Computes channel gains from the 18% neutral gray patch.
        Target is neutral gray where R = G = B = 119.0.
        """
        g_val = max(1.0, float(detected_gray_18[1]))
        r_gain = g_val / max(1.0, float(detected_gray_18[0]))
        b_gain = g_val / max(1.0, float(detected_gray_18[2]))
        return np.array([r_gain, 1.0, b_gain], dtype=np.float32)
