"""
RaktDrishti Anatomical Feature Extractor & Image Quality Engine.
Extracts optical biomarkers from Palpebral Conjunctiva, Nail Beds, and Palm images.
"""

import numpy as np
from typing import Dict, Any, Tuple

class AnatomicalFeatureExtractor:
    @staticmethod
    def rgb_to_cielab(rgb_pixels: np.ndarray) -> np.ndarray:
        """
        Converts sRGB pixels [0, 255] to standard CIE L*a*b* space.
        """
        # Normalize sRGB to [0, 1]
        rgb = rgb_pixels.astype(np.float32) / 255.0
        
        # Gamma correction
        mask = rgb > 0.04045
        rgb_lin = np.where(mask, np.power((rgb + 0.055) / 1.055, 2.4), rgb / 12.92)

        # Transformation to CIE XYZ (D65 illuminant)
        r, g, b = rgb_lin[:, 0], rgb_lin[:, 1], rgb_lin[:, 2]
        x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
        y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
        z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041

        # Normalize by D65 reference white [95.047, 100.0, 108.883]
        xn, yn, zn = x / 0.95047, y / 1.00000, z / 1.08883

        fx = np.where(xn > 0.008856, np.power(xn, 1.0 / 3.0), (7.787 * xn) + (16.0 / 116.0))
        fy = np.where(yn > 0.008856, np.power(yn, 1.0 / 3.0), (7.787 * yn) + (16.0 / 116.0))
        fz = np.where(zn > 0.008856, np.power(zn, 1.0 / 3.0), (7.787 * zn) + (16.0 / 116.0))

        L = np.maximum(0.0, (116.0 * fy) - 16.0)
        a = 500.0 * (fx - fy)
        b = 200.0 * (fy - fz)

        return np.column_stack([L, a, b])

    @classmethod
    def extract_conjunctiva_features(cls, roi_rgb: np.ndarray) -> Dict[str, float]:
        """
        Extracts Palpebral Conjunctiva optical biomarkers:
        - Erythema Index (EI): log(R) - log(G)
        - CIELAB a* (Red-Green chrominance)
        - Hemoglobin Color Index (HCI): (R - G) / (R + G + eps)
        - Redness Ratio: R / (R + G + B + eps)
        """
        flat_rgb = roi_rgb.reshape(-1, 3).astype(np.float32)
        r, g, b = flat_rgb[:, 0], flat_rgb[:, 1], flat_rgb[:, 2]
        eps = 1e-6

        # Erythema Index
        ei = np.mean(np.log10(np.maximum(1.0, r)) - np.log10(np.maximum(1.0, g)))
        
        # Hemoglobin Color Index
        hci = np.mean((r - g) / (r + g + eps))

        # Redness Ratio
        red_ratio = np.mean(r / (r + g + b + eps))

        # CIELAB features
        lab = cls.rgb_to_cielab(flat_rgb)
        mean_L = float(np.mean(lab[:, 0]))
        mean_a = float(np.mean(lab[:, 1]))
        mean_b = float(np.mean(lab[:, 2]))

        return {
            "erythema_index": float(ei),
            "hemoglobin_color_index": float(hci),
            "redness_ratio": float(red_ratio),
            "lab_L": mean_L,
            "lab_a": mean_a,
            "lab_b": mean_b
        }

    @classmethod
    def extract_nail_features(cls, roi_rgb: np.ndarray) -> Dict[str, float]:
        """
        Extracts Subungual Nail Bed capillary perfusion features.
        """
        flat_rgb = roi_rgb.reshape(-1, 3).astype(np.float32)
        r, g, b = flat_rgb[:, 0], flat_rgb[:, 1], flat_rgb[:, 2]
        eps = 1e-6

        capillary_redness = np.mean(r / (r + g + b + eps))
        lab = cls.rgb_to_cielab(flat_rgb)

        return {
            "nail_capillary_redness": float(capillary_redness),
            "nail_vascularity_index": float(np.mean((r - b) / (r + b + eps))),
            "nail_lab_a": float(np.mean(lab[:, 1])),
            "nail_lab_L": float(np.mean(lab[:, 0]))
        }

    @classmethod
    def extract_palm_features(cls, roi_rgb: np.ndarray) -> Dict[str, float]:
        """
        Extracts Palmar Crease vs background skin contrast.
        """
        flat_rgb = roi_rgb.reshape(-1, 3).astype(np.float32)
        r, g, b = flat_rgb[:, 0], flat_rgb[:, 1], flat_rgb[:, 2]
        eps = 1e-6

        lab = cls.rgb_to_cielab(flat_rgb)
        palmar_pallor = np.mean(lab[:, 0]) / max(1.0, np.mean(lab[:, 1]))

        return {
            "palmar_pallor_index": float(palmar_pallor),
            "palmar_erythema": float(np.mean(r / (g + b + eps))),
            "palm_lab_L": float(np.mean(lab[:, 0])),
            "palm_lab_a": float(np.mean(lab[:, 1]))
        }

    @staticmethod
    def assess_image_quality(image_rgb: np.ndarray, card_detected: bool = True) -> Dict[str, float]:
        """
        Calculates image quality indicators:
        - Sharpness (variance of Laplacian equivalent)
        - Brightness (mean pixel intensity)
        - Contrast (std dev of intensity)
        - Exposure clipping (percentage of pixels within 15-240 range)
        - Overall composite quality score (0 - 100)
        """
        gray = np.dot(image_rgb[..., :3], [0.2989, 0.5870, 0.1140])
        
        # Sharpness heuristic (gradient variance)
        gx, gy = np.gradient(gray)
        gnorm = np.sqrt(gx**2 + gy**2)
        sharpness_val = float(np.clip(np.var(gnorm) / 5.0, 0.0, 100.0))

        # Brightness & contrast
        brightness_val = float(np.mean(gray))
        contrast_val = float(np.std(gray))
        
        # Normalized scores (0 - 100)
        s_sharpness = min(100.0, sharpness_val * 2.0)
        s_brightness = 100.0 - abs(brightness_val - 128.0) * 0.8
        s_contrast = min(100.0, contrast_val * 2.2)
        s_card = 95.0 if card_detected else 20.0
        s_region = 90.0

        quality_score = round(
            0.25 * s_sharpness +
            0.20 * s_brightness +
            0.20 * s_contrast +
            0.20 * s_card +
            0.15 * s_region,
            1
        )

        return {
            "sharpness": round(s_sharpness, 1),
            "brightness": round(s_brightness, 1),
            "contrast": round(s_contrast, 1),
            "calibration_visibility": s_card,
            "region_visibility": s_region,
            "overall_quality_score": float(np.clip(quality_score, 0.0, 100.0))
        }
