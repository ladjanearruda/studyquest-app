// lib/features/diario/models/diary_emotion_model.dart
// ✅ V9.0 - Sprint 9: Model para emoções pós-sessão
// 📅 Criado: 18/02/2026

class DiaryEmotion {
  final String id;
  final String userId;
  final String sessionId;
  final EmotionLevel emotion;
  final double accuracy; // % de acertos da sessão
  final int questionsAnswered;
  final Duration sessionDuration;
  final DateTime timestamp;

  DiaryEmotion({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.emotion,
    required this.accuracy,
    required this.questionsAnswered,
    required this.sessionDuration,
    required this.timestamp,
  });

  // Criar a partir do Firebase
  factory DiaryEmotion.fromJson(Map<String, dynamic> json, String id) {
    return DiaryEmotion(
      id: id,
      userId: json['user_id'] ?? '',
      sessionId: json['session_id'] ?? '',
      emotion: EmotionLevelHelper.fromEmoji(json['emotion'] ?? '😐'),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      questionsAnswered: json['questions_answered'] ?? 0,
      sessionDuration: Duration(seconds: json['duration_seconds'] ?? 0),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  // Converter para JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'emotion': emotion.emoji,
      'accuracy': accuracy,
      'questions_answered': questionsAnswered,
      'duration_seconds': sessionDuration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum EmotionLevel {
  veryBad, // 😫 Muito difícil
  bad, // 😔 Difícil
  neutral, // 😐 Normal
  good, // 🙂 Fácil
  veryGood, // 😊 Muito fácil
}

extension EmotionLevelExtension on EmotionLevel {
  String get emoji {
    switch (this) {
      case EmotionLevel.veryBad:
        return '😫';
      case EmotionLevel.bad:
        return '😔';
      case EmotionLevel.neutral:
        return '😐';
      case EmotionLevel.good:
        return '🙂';
      case EmotionLevel.veryGood:
        return '😊';
    }
  }

  String get label {
    switch (this) {
      case EmotionLevel.veryBad:
        return 'Muito difícil';
      case EmotionLevel.bad:
        return 'Difícil';
      case EmotionLevel.neutral:
        return 'Normal';
      case EmotionLevel.good:
        return 'Fácil';
      case EmotionLevel.veryGood:
        return 'Muito fácil';
    }
  }

  int get value {
    switch (this) {
      case EmotionLevel.veryBad:
        return 1;
      case EmotionLevel.bad:
        return 2;
      case EmotionLevel.neutral:
        return 3;
      case EmotionLevel.good:
        return 4;
      case EmotionLevel.veryGood:
        return 5;
    }
  }
}

// Helper class para métodos estáticos
class EmotionLevelHelper {
  static EmotionLevel fromEmoji(String emoji) {
    switch (emoji) {
      case '😫':
        return EmotionLevel.veryBad;
      case '😔':
        return EmotionLevel.bad;
      case '😐':
        return EmotionLevel.neutral;
      case '🙂':
        return EmotionLevel.good;
      case '😊':
        return EmotionLevel.veryGood;
      default:
        return EmotionLevel.neutral;
    }
  }

  static EmotionLevel fromValue(int value) {
    switch (value) {
      case 1:
        return EmotionLevel.veryBad;
      case 2:
        return EmotionLevel.bad;
      case 3:
        return EmotionLevel.neutral;
      case 4:
        return EmotionLevel.good;
      case 5:
        return EmotionLevel.veryGood;
      default:
        return EmotionLevel.neutral;
    }
  }
}

// Classe para análise de correlação emoção × performance
class EmotionPerformanceAnalysis {
  final Map<EmotionLevel, double> averageAccuracyByEmotion;
  final EmotionLevel bestPerformingEmotion;
  final int totalSessions;
  final String insight;

  EmotionPerformanceAnalysis({
    required this.averageAccuracyByEmotion,
    required this.bestPerformingEmotion,
    required this.totalSessions,
    required this.insight,
  });

  factory EmotionPerformanceAnalysis.fromEmotions(List<DiaryEmotion> emotions) {
    if (emotions.isEmpty) {
      return EmotionPerformanceAnalysis(
        averageAccuracyByEmotion: {},
        bestPerformingEmotion: EmotionLevel.neutral,
        totalSessions: 0,
        insight: 'Complete mais sessões para ver insights!',
      );
    }

    // Calcular média de precisão por emoção
    final Map<EmotionLevel, List<double>> accuraciesByEmotion = {};
    for (final emotion in emotions) {
      accuraciesByEmotion
          .putIfAbsent(emotion.emotion, () => [])
          .add(emotion.accuracy);
    }

    final Map<EmotionLevel, double> averages = {};
    EmotionLevel? best;
    double bestAvg = 0;

    for (final entry in accuraciesByEmotion.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      averages[entry.key] = avg;
      if (avg > bestAvg) {
        bestAvg = avg;
        best = entry.key;
      }
    }

    // Gerar insight
    String insight = 'Continue assim!';
    if (best == EmotionLevel.veryGood || best == EmotionLevel.good) {
      insight = 'Você aprende melhor quando está feliz! 😊';
    } else if (best == EmotionLevel.neutral) {
      insight = 'Você mantém consistência em diferentes humores!';
    } else {
      insight = 'Desafios te motivam! Você performa bem sob pressão.';
    }

    return EmotionPerformanceAnalysis(
      averageAccuracyByEmotion: averages,
      bestPerformingEmotion: best ?? EmotionLevel.neutral,
      totalSessions: emotions.length,
      insight: insight,
    );
  }
}
