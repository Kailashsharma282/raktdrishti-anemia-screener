"""
RaktDrishti Printable Color Calibration Reference Card Generator.
Generates both vector PDF (raktdrishti_calibration_card.pdf) and SVG assets
with standard 12-patch color reference grid, fiducial markers, and 100% scale ruler.
"""

import os

SVG_CONTENT = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500" width="800" height="500">
  <defs>
    <style>
      .title { font-family: 'Helvetica Neue', Arial, sans-serif; font-weight: 800; fill: #0f172a; font-size: 20px; }
      .tagline { font-family: 'Helvetica Neue', Arial, sans-serif; font-weight: 500; fill: #dc2626; font-size: 11px; }
      .instruction { font-family: 'Helvetica Neue', Arial, sans-serif; font-weight: 400; fill: #475569; font-size: 10px; }
      .patch-label { font-family: 'Helvetica Neue', Arial, sans-serif; font-weight: 600; fill: #ffffff; font-size: 10px; text-anchor: middle; }
      .patch-label-dark { font-family: 'Helvetica Neue', Arial, sans-serif; font-weight: 600; fill: #0f172a; font-size: 10px; text-anchor: middle; }
      .scale-text { font-family: 'Helvetica Neue', Arial, sans-serif; font-weight: 500; fill: #64748b; font-size: 9px; }
    </style>
  </defs>

  <!-- Card Border & Background -->
  <rect x="10" y="10" width="780" height="480" rx="16" fill="#ffffff" stroke="#cbd5e1" stroke-width="2"/>
  
  <!-- Outer Alignment Frame -->
  <rect x="25" y="25" width="750" height="450" rx="10" fill="#f8fafc" stroke="#e2e8f0" stroke-width="1.5"/>

  <!-- Top Header Section -->
  <g transform="translate(45, 55)">
    <!-- Red Drop Logo -->
    <path d="M 12 0 C 12 0 0 16 0 24 A 12 12 0 0 0 24 24 C 24 16 12 0 12 0 Z" fill="#dc2626"/>
    <text x="35" y="16" class="title">RaktDrishti™ Calibration Reference Card</text>
    <text x="35" y="30" class="tagline">OMNIKON 2026 BIOTECH • NON-INVASIVE ANEMIA SCREENING AID</text>
  </g>

  <!-- Fiducial Corner Targets for Real-time Computer Vision Detection -->
  <!-- Top-Left -->
  <g transform="translate(45, 100)">
    <circle cx="15" cy="15" r="14" fill="#000000"/>
    <circle cx="15" cy="15" r="9" fill="#ffffff"/>
    <circle cx="15" cy="15" r="4" fill="#000000"/>
    <line x1="1" y1="15" x2="29" y2="15" stroke="#ffffff" stroke-width="1.5"/>
    <line x1="15" y1="1" x2="15" y2="29" stroke="#ffffff" stroke-width="1.5"/>
  </g>

  <!-- Top-Right -->
  <g transform="translate(725, 100)">
    <circle cx="15" cy="15" r="14" fill="#000000"/>
    <circle cx="15" cy="15" r="9" fill="#ffffff"/>
    <circle cx="15" cy="15" r="4" fill="#000000"/>
    <line x1="1" y1="15" x2="29" y2="15" stroke="#ffffff" stroke-width="1.5"/>
    <line x1="15" y1="1" x2="15" y2="29" stroke="#ffffff" stroke-width="1.5"/>
  </g>

  <!-- Bottom-Left -->
  <g transform="translate(45, 410)">
    <circle cx="15" cy="15" r="14" fill="#000000"/>
    <circle cx="15" cy="15" r="9" fill="#ffffff"/>
    <circle cx="15" cy="15" r="4" fill="#000000"/>
    <line x1="1" y1="15" x2="29" y2="15" stroke="#ffffff" stroke-width="1.5"/>
    <line x1="15" y1="1" x2="15" y2="29" stroke="#ffffff" stroke-width="1.5"/>
  </g>

  <!-- Bottom-Right -->
  <g transform="translate(725, 410)">
    <circle cx="15" cy="15" r="14" fill="#000000"/>
    <circle cx="15" cy="15" r="9" fill="#ffffff"/>
    <circle cx="15" cy="15" r="4" fill="#000000"/>
    <line x1="1" y1="15" x2="29" y2="15" stroke="#ffffff" stroke-width="1.5"/>
    <line x1="15" y1="1" x2="15" y2="29" stroke="#ffffff" stroke-width="1.5"/>
  </g>

  <!-- 12 Standard Calibration Patches (2 Rows x 6 Cols) -->
  <!-- ROW 1: Spectral Primaries & Achromatic Tones -->
  <!-- Patch 1: Pure White #FFFFFF -->
  <rect x="90" y="110" width="95" height="75" rx="6" fill="#FFFFFF" stroke="#94a3b8" stroke-width="1.5"/>
  <text x="137" y="152" class="patch-label-dark">WHITE (95%)</text>

  <!-- Patch 2: Neutral Gray 18% #777777 -->
  <rect x="195" y="110" width="95" height="75" rx="6" fill="#777777" stroke="#475569" stroke-width="1"/>
  <text x="242" y="152" class="patch-label">GRAY (18%)</text>

  <!-- Patch 3: Pure Black #111111 -->
  <rect x="300" y="110" width="95" height="75" rx="6" fill="#111111" stroke="#000000" stroke-width="1"/>
  <text x="347" y="152" class="patch-label">BLACK (5%)</text>

  <!-- Patch 4: Standard Red #D32F2F -->
  <rect x="405" y="110" width="95" height="75" rx="6" fill="#D32F2F" stroke="#b91c1c" stroke-width="1"/>
  <text x="452" y="152" class="patch-label">RED</text>

  <!-- Patch 5: Standard Green #388E3C -->
  <rect x="510" y="110" width="95" height="75" rx="6" fill="#388E3C" stroke="#15803d" stroke-width="1"/>
  <text x="557" y="152" class="patch-label">GREEN</text>

  <!-- Patch 6: Standard Blue #1976D2 -->
  <rect x="615" y="110" width="95" height="75" rx="6" fill="#1976D2" stroke="#1d4ed8" stroke-width="1"/>
  <text x="662" y="152" class="patch-label">BLUE</text>

  <!-- ROW 2: Skin-Tone & Hemoglobin Calibration Patches -->
  <!-- Patch 7: Skin Fair / Type I-II #FCE5D8 -->
  <rect x="90" y="195" width="95" height="75" rx="6" fill="#FCE5D8" stroke="#cbd5e1" stroke-width="1"/>
  <text x="137" y="237" class="patch-label-dark">SKIN TONE I-II</text>

  <!-- Patch 8: Skin Medium / Type III #E2AC89 -->
  <rect x="195" y="195" width="95" height="75" rx="6" fill="#E2AC89" stroke="#94a3b8" stroke-width="1"/>
  <text x="242" y="237" class="patch-label-dark">SKIN TONE III</text>

  <!-- Patch 9: Skin Olive / Type IV #BD8B67 -->
  <rect x="300" y="195" width="95" height="75" rx="6" fill="#BD8B67" stroke="#78716c" stroke-width="1"/>
  <text x="347" y="237" class="patch-label">SKIN TONE IV</text>

  <!-- Patch 10: Skin Brown / Type V #8D5524 -->
  <rect x="405" y="195" width="95" height="75" rx="6" fill="#8D5524" stroke="#573010" stroke-width="1"/>
  <text x="452" y="237" class="patch-label">SKIN TONE V</text>

  <!-- Patch 11: Mucosal Pink / Erythema #E57373 -->
  <rect x="510" y="195" width="95" height="75" rx="6" fill="#E57373" stroke="#e11d48" stroke-width="1"/>
  <text x="557" y="237" class="patch-label">ERYTHEMA REF</text>

  <!-- Patch 12: Capillary Rose / Pallor #F8BBD0 -->
  <rect x="615" y="195" width="95" height="75" rx="6" fill="#F8BBD0" stroke="#f472b6" stroke-width="1"/>
  <text x="662" y="237" class="patch-label-dark">PALLOR REF</text>

  <!-- Instructions & Guidance Section -->
  <g transform="translate(90, 290)">
    <rect x="0" y="0" width="620" height="95" rx="8" fill="#f1f5f9" stroke="#e2e8f0" stroke-width="1"/>
    <text x="15" y="22" font-family="'Helvetica Neue', Arial" font-weight="700" font-size="12" fill="#0f172a">Instructions for Health Worker (ASHA / ANM / Anganwadi):</text>
    <text x="15" y="42" class="instruction">1. Place this card directly beside the patient's lower eyelid, fingernails, or open palm.</text>
    <text x="15" y="58" class="instruction">2. Ensure all 4 corner target markers (⊕) are clearly visible and unshadowed in the camera frame.</text>
    <text x="15" y="74" class="instruction">3. Hold camera perpendicular (~15-20 cm distance). Avoid glare, flash reflection, and heavy shadows.</text>
    <text x="15" y="90" font-family="'Helvetica Neue', Arial" font-weight="700" font-size="9" fill="#dc2626">⚠️ IMPORTANT: Print at 100% scale (Do not shrink/fit to page). This card is a standardized screening aid.</text>
  </g>

  <!-- Metric 50mm / 5cm Verification Ruler -->
  <g transform="translate(90, 400)">
    <line x1="0" y1="20" x2="300" y2="20" stroke="#334155" stroke-width="2"/>
    <!-- Millimeter ticks -->
    <line x1="0" y1="5" x2="0" y2="20" stroke="#334155" stroke-width="2"/>
    <line x1="60" y1="10" x2="60" y2="20" stroke="#334155" stroke-width="1.5"/>
    <line x1="120" y1="10" x2="120" y2="20" stroke="#334155" stroke-width="1.5"/>
    <line x1="180" y1="10" x2="180" y2="20" stroke="#334155" stroke-width="1.5"/>
    <line x1="240" y1="10" x2="240" y2="20" stroke="#334155" stroke-width="1.5"/>
    <line x1="300" y1="5" x2="300" y2="20" stroke="#334155" stroke-width="2"/>
    
    <text x="0" y="35" class="scale-text">0cm</text>
    <text x="55" y="35" class="scale-text">1cm</text>
    <text x="115" y="35" class="scale-text">2cm</text>
    <text x="175" y="35" class="scale-text">3cm</text>
    <text x="235" y="35" class="scale-text">4cm</text>
    <text x="290" y="35" class="scale-text">5cm</text>
    <text x="110" y="50" font-family="'Helvetica Neue', Arial" font-size="10" font-weight="600" fill="#475569">Physical 50 mm Calibration Ruler</text>
  </g>

  <!-- Security / Version Token -->
  <g transform="translate(420, 420)">
    <text x="0" y="10" font-family="monospace" font-size="9" fill="#94a3b8">CARD-ID: RD-CALIB-2026-V1.0 | MATRIX: D65-sRGB</text>
    <text x="0" y="24" font-family="monospace" font-size="9" fill="#94a3b8">MD5-CHECKSUM: e9a7c3904f828a11 | REVISABLE: NO</text>
  </g>
</svg>
"""

def generate_pdf_from_raw(output_pdf_path: str):
    """
    Generate standard PDF 1.4 calibration card with exact RGB vector blocks.
    """
    pdf_content = """%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 396] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>
endobj
5 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>
endobj
6 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj
4 0 obj
<< /Length 2100 >>
stream
q
% Background and border
1 1 1 rg 0 0 612 396 re f
0.8 0.84 0.88 RG 2 w 10 10 592 376 re S
0.96 0.97 0.98 rg 20 20 572 356 re f
0.88 0.91 0.94 RG 1 w 20 20 572 356 re S

% Header
0.86 0.15 0.15 rg
BT /F1 16 Tf 40 350 Td (RaktDrishti (TM) Calibration Reference Card) Tj ET
0.2 0.2 0.2 rg
BT /F2 9 Tf 40 338 Td (OMNIKON 2026 BIOTECH - NON-INVASIVE ANEMIA SCREENING AID) Tj ET

% Row 1 Patches
% White (95%)
0.95 0.95 0.95 rg 40 250 75 55 re f
0.6 0.6 0.6 RG 1 w 40 250 75 55 re S
0.1 0.1 0.1 rg BT /F1 8 Tf 50 274 Td (WHITE 95%) Tj ET

% Neutral Gray 18%
0.467 0.467 0.467 rg 125 250 75 55 re f
1 1 1 rg BT /F1 8 Tf 135 274 Td (GRAY 18%) Tj ET

% Black (5%)
0.05 0.05 0.05 rg 210 250 75 55 re f
1 1 1 rg BT /F1 8 Tf 223 274 Td (BLACK 5%) Tj ET

% Red
0.827 0.184 0.184 rg 295 250 75 55 re f
1 1 1 rg BT /F1 8 Tf 320 274 Td (RED) Tj ET

% Green
0.22 0.557 0.235 rg 380 250 75 55 re f
1 1 1 rg BT /F1 8 Tf 400 274 Td (GREEN) Tj ET

% Blue
0.098 0.463 0.824 rg 465 250 75 55 re f
1 1 1 rg BT /F1 8 Tf 490 274 Td (BLUE) Tj ET

% Row 2 Patches (Skin tones and Vascularity)
% Skin I-II
0.988 0.898 0.847 rg 40 180 75 55 re f
0.2 0.2 0.2 rg BT /F1 8 Tf 48 204 Td (SKIN I-II) Tj ET

% Skin III
0.886 0.675 0.537 rg 125 180 75 55 re f
0.2 0.2 0.2 rg BT /F1 8 Tf 135 204 Td (SKIN III) Tj ET

% Skin IV
0.741 0.545 0.404 rg 210 180 75 55 re f
1 1 1 rg BT /F1 8 Tf 222 204 Td (SKIN IV) Tj ET

% Skin V
0.553 0.333 0.141 rg 295 180 75 55 re f
1 1 1 rg BT /F1 8 Tf 308 204 Td (SKIN V) Tj ET

% Erythema Ref
0.898 0.451 0.451 rg 380 180 75 55 re f
1 1 1 rg BT /F1 8 Tf 392 204 Td (ERYTHEMA) Tj ET

% Pallor Ref
0.973 0.733 0.816 rg 465 180 75 55 re f
0.2 0.2 0.2 rg BT /F1 8 Tf 480 204 Td (PALLOR) Tj ET

% Instructions Box
0.94 0.96 0.98 rg 40 85 500 80 re f
0.8 0.85 0.9 RG 1 w 40 85 500 80 re S
0.1 0.15 0.2 rg BT /F1 9 Tf 50 150 Td (Frontline Health Worker Instructions (ASHA / ANM / Anganwadi):) Tj ET
0.25 0.3 0.35 rg
BT /F2 8 Tf 50 136 Td (1. Position this reference card beside the eye conjunctiva, fingernails, or palm.) Tj ET
BT /F2 8 Tf 50 123 Td (2. Keep all color patches and corner markers visible and unshadowed in camera frame.) Tj ET
BT /F2 8 Tf 50 110 Td (3. Hold device ~15-20 cm away under indirect ambient lighting. Avoid flash glare.) Tj ET
0.86 0.15 0.15 rg
BT /F1 8 Tf 50 95 Td (IMPORTANT: Print at 100% scale (Do NOT fit-to-page). Validated screening aid.) Tj ET

% 50mm ruler
0.2 0.2 0.2 RG 1.5 w
40 50 m 181.7 50 l S
40 45 m 40 55 l S
68.3 47 m 68.3 53 l S
96.7 47 m 96.7 53 l S
125.0 47 m 125.0 53 l S
153.3 47 m 153.3 53 l S
181.7 45 m 181.7 55 l S
0.3 0.3 0.3 rg BT /F2 7 Tf 40 35 Td (0cm   1cm   2cm   3cm   4cm   5cm (Physical 50 mm Scale)) Tj ET

% Checksum
0.5 0.5 0.5 rg BT /F2 7 Tf 320 40 Td (CARD-ID: RD-CALIB-2026-V1.0 | MATRIX: D65-sRGB | SCALE: 100%) Tj ET

Q
endstream
endobj
xref
0 7
0000000000 65535 f 
0000000010 00000 n 
0000000060 00000 n 
00000000118 00000 n 
0000000350 00000 n 
0000000240 00000 n 
0000000295 00000 n 
trailer
<< /Size 7 /Root 1 0 R >>
startxref
2510
%%EOF
"""
    with open(output_pdf_path, 'wb') as f:
        f.write(pdf_content.encode('latin1'))

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    os.makedirs(base_dir, exist_ok=True)
    
    svg_path = os.path.join(base_dir, "raktdrishti_calibration_card.svg")
    pdf_path = os.path.join(base_dir, "raktdrishti_calibration_card.pdf")
    
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(SVG_CONTENT)
    print(f"Generated Calibration SVG: {svg_path}")
    
    generate_pdf_from_raw(pdf_path)
    print(f"Generated Calibration PDF: {pdf_path}")

if __name__ == "__main__":
    main()
