// lib/core/models/user_score_model.dart
// Model para Score do Usuário no Sistema de Rankings
// Sprint 7 - Observatório Educacional MVP

class UserScore {
  final String userId;
  final String name;
  final String avatarType;
  final int score;
  final int position;
  final String schoolLevel;
  final String state; // ⚠️ Temporário: "DF" até coletar dados reais
  final int totalQuestions;
  final int correctAnswers;
  final int xpTotal;
  final int streakDays;
  final double accuracy;
  final DateTime updatedAt;

  UserScore({
    required this.userId,
    required this.name,
    required this.avatarType,
    required this.score,
    required this.position,
    required this.schoolLevel,
    required this.state,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpTotal,
    required this.streakDays,
    required this.accuracy,
    required this.updatedAt,
  });

  /// Calcula score total do usuário
  /// Fórmula: (acertos × 10) + (XP ÷ 10) + (streak × 5)
  static int calculateScore({
    required int correctAnswers,
    required int xpTotal,
    required int streakDays,
  }) {
    return (correctAnswers * 10) + (xpTotal ~/ 10) + (streakDays * 5);
  }

  /// Cria UserScore vazio (para loading)
  factory UserScore.empty() {
    return UserScore(
      userId: '',
      name: '',
      avatarType: 'equilibrado_masculino',
      score: 0,
      position: 0,
      schoolLevel: '',
      state: 'DF',
      totalQuestions: 0,
      correctAnswers: 0,
      xpTotal: 0,
      streakDays: 0,
      accuracy: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  /// Converte JSON do Firebase → UserScore
  factory UserScore.fromJson(Map<String, dynamic> json) {
    return UserScore(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      avatarType: json['avatar_type'] ?? 'equilibrado_masculino',
      score: json['score'] ?? 0,
      position: json['position'] ?? 0,
      schoolLevel: json['school_level'] ?? '',
      state: json['state'] ?? 'DF', // ⚠️ Fallback temporário
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      xpTotal: json['xp_total'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// Converte UserScore → JSON para Firebase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'avatar_type': avatarType,
      'score': score,
      'position': position,
      'school_level': schoolLevel,
      'state': state,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'xp_total': xpTotal,
      'streak_days': streakDays,
      'accuracy': accuracy,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com mudanças
  UserScore copyWith({
    String? userId,
    String? name,
    String? avatarType,
    int? score,
    int? position,
    String? schoolLevel,
    String? state,
    int? totalQuestions,
    int? correctAnswers,
    int? xpTotal,
    int? streakDays,
    double? accuracy,
    DateTime? updatedAt,
  }) {
    return UserScore(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarType: avatarType ?? this.avatarType,
      score: score ?? this.score,
      position: position ?? this.position,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      state: state ?? this.state,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      xpTotal: xpTotal ?? this.xpTotal,
      streakDays: streakDays ?? this.streakDays,
      accuracy: accuracy ?? this.accuracy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserScore(name: $name, score: $score, position: $position, accuracy: ${accuracy.toStringAsFixed(1)}%)';
  }
}
