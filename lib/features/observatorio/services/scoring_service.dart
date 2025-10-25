// lib/features/observatorio/services/scoring_service.dart
// Service para Cálculo de Pontuações e Métricas
// Sprint 7 - Observatório Educacional MVP

class ScoringService {
  /// Calcula score total do usuário
  /// Fórmula: (acertos × 10) + (XP ÷ 10) + (streak × 5)
  ///
  /// Exemplo:
  /// - 50 acertos = 500 pontos
  /// - 1000 XP = 100 pontos
  /// - 7 dias streak = 35 pontos
  /// Total = 635 pontos
  static int calculateScore({
    required int correctAnswers,
    required int xpTotal,
    required int streakDays,
  }) {
    final baseScore = correctAnswers * 10;
    final xpBonus = xpTotal ~/ 10;
    final streakBonus = streakDays * 5;

    final totalScore = baseScore + xpBonus + streakBonus;

    print('📊 Score calculado: $totalScore');
    print('   └─ Acertos: $correctAnswers × 10 = $baseScore');
    print('   └─ XP: $xpTotal ÷ 10 = $xpBonus');
    print('   └─ Streak: $streakDays × 5 = $streakBonus');

    return totalScore;
  }

  /// Calcula accuracy (precisão/taxa de acerto)
  /// Fórmula: (acertos ÷ total) × 100
  ///
  /// Exemplo:
  /// - 45 acertos de 50 questões = 90%
  /// - 30 acertos de 40 questões = 75%
  static double calculateAccuracy({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    if (totalQuestions == 0) return 0.0;

    final accuracy = (correctAnswers / totalQuestions) * 100;

    print('🎯 Accuracy: ${accuracy.toStringAsFixed(1)}%');
    print('   └─ $correctAnswers acertos de $totalQuestions questões');

    return accuracy;
  }

  /// Calcula pontos necessários para alcançar próxima posição
  ///
  /// Exemplo:
  /// - Meu score: 635
  /// - Próxima posição: 700
  /// - Faltam: 65 pontos
  static int pointsToNextPosition({
    required int currentScore,
    required int nextPositionScore,
  }) {
    final pointsNeeded = nextPositionScore - currentScore;

    if (pointsNeeded <= 0) {
      print('🎉 Você já ultrapassou essa posição!');
      return 0;
    }

    print('📈 Faltam $pointsNeeded pontos para próxima posição');
    print('   └─ Seu score: $currentScore');
    print('   └─ Próxima posição: $nextPositionScore');

    return pointsNeeded;
  }

  /// Calcula quantas questões o usuário precisa acertar para subir N posições
  /// Considera apenas pontos de acertos (10 pontos cada)
  ///
  /// Exemplo:
  /// - Faltam 65 pontos
  /// - Precisa acertar: 7 questões (7 × 10 = 70 pontos)
  static int questionsNeededToClimb({
    required int pointsNeeded,
  }) {
    final questions = (pointsNeeded / 10).ceil();

    print(
        '📝 Precisa acertar $questions questões para ganhar $pointsNeeded pontos');

    return questions;
  }

  /// Estima posição futura baseado em taxa de crescimento
  /// (Placeholder para IA futura - Sprint 7 avançado)
  static Map<String, int> estimateFuturePosition({
    required int currentPosition,
    required int averagePointsPerDay,
    required int daysAhead,
  }) {
    final estimatedPoints = averagePointsPerDay * daysAhead;
    final estimatedClimb =
        (estimatedPoints / 50).floor(); // Estimativa: 50 pontos = 1 posição
    final estimatedPosition =
        (currentPosition - estimatedClimb).clamp(1, 999999);

    print('🔮 Estimativa $daysAhead dias:');
    print('   └─ Posição atual: $currentPosition');
    print('   └─ Estimativa: $estimatedPosition');
    print('   └─ Subida: $estimatedClimb posições');

    return {
      'estimated_position': estimatedPosition,
      'positions_climbed': estimatedClimb,
      'estimated_points': estimatedPoints,
    };
  }
}
