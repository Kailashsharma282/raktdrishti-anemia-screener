import 'image_preprocessor.dart';

class MLPredictionResult {
  final double riskScore; // 0.0 to 1.0
  final String riskCategory; // NORMAL, MILD, MODERATE, SEVERE
  final double confidence; // 0.0 to 1.0
  final Map<String, double> siteScores;
  final double overallQuality;
  final String modelName;
  final String modelVersion;
  final bool isDemoModel;

  MLPredictionResult({
    required this.riskScore,
    required this.riskCategory,
    required this.confidence,
    required this.siteScores,
    required this.overallQuality,
    this.modelName = 'RaktDrishti-MultiSite-Fusion',
    this.modelVersion = 'v1.0.0-mvp-demo',
    this.isDemoModel = true,
  });
}

class AnemiaRiskModel {
  static const String modelName = 'RaktDrishti-MultiSite-Fusion';
  static const String modelVersion = 'v1.0.0-mvp-demo';

  /// Executes multi-site fusion inference over preprocessed site features
  static MLPredictionResult predict({
    required PreprocessedFeatures conjunctiva,
    required PreprocessedFeatures nail,
    required PreprocessedFeatures palm,
  }) {
    // 1. Calculate Individual Site Risk Heuristic Scores
    // Conjunctiva: EI & lab_a
    final conjEi = conjunctiva.colorFeatures['erythema_index'] ?? 0.40;
    final conjLabA = conjunctiva.colorFeatures['lab_a'] ?? 20.0;
    final conjRisk = (1.0 - (conjEi * 1.2 + (conjLabA / 35.0)) / 2.0).clamp(0.05, 0.95);

    // Nail: Capillary redness
    final nailRedness = nail.colorFeatures['nail_capillary_redness'] ?? 0.40;
    final nailRisk = (1.0 - (nailRedness * 2.1)).clamp(0.05, 0.95);

    // Palm: Palmar pallor index
    final palmPallor = palm.colorFeatures['palmar_pallor_index'] ?? 2.5;
    final palmRisk = (palmPallor / 5.5).clamp(0.05, 0.95);

    // 2. Weights & Multi-Site Fusion
    // Priors: Conjunctiva (0.45), Nail (0.30), Palm (0.25)
    final wConj = 0.45 * (conjunctiva.qualityScore / 100.0) * 0.88;
    final wNail = 0.30 * (nail.qualityScore / 100.0) * 0.84;
    final wPalm = 0.25 * (palm.qualityScore / 100.0) * 0.80;

    final totalWeight = wConj + wNail + wPalm;
    final fusedScore = (conjRisk * wConj + nailRisk * wNail + palmRisk * wPalm) / (totalWeight > 0 ? totalWeight : 1.0);
    final clampedScore = double.parse(fusedScore.clamp(0.05, 0.95).toStringAsFixed(2));

    // 3. Risk Categorization
    String category;
    if (clampedScore < 0.36) {
      category = 'NORMAL';
    } else if (clampedScore < 0.56) {
      category = 'MILD';
    } else if (clampedScore < 0.76) {
      category = 'MODERATE';
    } else {
      category = 'SEVERE';
    }

    final avgQuality = (conjunctiva.qualityScore + nail.qualityScore + palm.qualityScore) / 3.0;

    return MLPredictionResult(
      riskScore: clampedScore,
      riskCategory: category,
      confidence: 0.85,
      siteScores: {
        'conjunctiva': double.parse(conjRisk.toStringAsFixed(2)),
        'nail': double.parse(nailRisk.toStringAsFixed(2)),
        'palm': double.parse(palmRisk.toStringAsFixed(2)),
      },
      overallQuality: double.parse(avgQuality.toStringAsFixed(1)),
      modelName: modelName,
      modelVersion: modelVersion,
      isDemoModel: true,
    );
  }
}
