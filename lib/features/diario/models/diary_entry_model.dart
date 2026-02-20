// lib/features/diario/models/diary_entry_model.dart
// ✅ V9.0 - Sprint 9: Model para anotações do Diário
// 📅 Criado: 18/02/2026

class DiaryEntry {
  final String id;
  final String odId;
  final String questionId;
  final String questionText;
  final String correctAnswer;
  final String userAnswer;
  final String userNote; // "O que aprendi com esse erro?"
  final String userStrategy; // "Como vou evitar esse erro?"
  final int difficultyRating; // 1-5 estrelas
  final String emotion; // Emoji: 😫😔😐🙂😊
  final String subject; // Matéria
  final DateTime createdAt;
  final DateTime? nextReviewDate; // Spaced repetition
  final int timesReviewed;
  final bool mastered;
  final int xpEarned;

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.userAnswer,
    required this.userNote,
    required this.userStrategy,
    required this.difficultyRating,
    required this.emotion,
    required this.subject,
    required this.createdAt,
    this.nextReviewDate,
    this.timesReviewed = 0,
    this.mastered = false,
    this.xpEarned = 25,
  });

  // Criar a partir do Firebase
  factory DiaryEntry.fromJson(Map<String, dynamic> json, String id) {
    return DiaryEntry(
      id: id,
      userId: json['user_id'] ?? '',
      questionId: json['question_id'] ?? '',
      questionText: json['question_text'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      userAnswer: json['user_answer'] ?? '',
      userNote: json['user_note'] ?? '',
      userStrategy: json['user_strategy'] ?? '',
      difficultyRating: json['difficulty_rating'] ?? 3,
      emotion: json['emotion'] ?? '😐',
      subject: json['subject'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      nextReviewDate: json['next_review_date'] != null
          ? DateTime.parse(json['next_review_date'])
          : null,
      timesReviewed: json['times_reviewed'] ?? 0,
      mastered: json['mastered'] ?? false,
      xpEarned: json['xp_earned'] ?? 25,
    );
  }

  // Converter para JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'question_id': questionId,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'user_answer': userAnswer,
      'user_note': userNote,
      'user_strategy': userStrategy,
      'difficulty_rating': difficultyRating,
      'emotion': emotion,
      'subject': subject,
      'created_at': createdAt.toIso8601String(),
      'next_review_date': nextReviewDate?.toIso8601String(),
      'times_reviewed': timesReviewed,
      'mastered': mastered,
      'xp_earned': xpEarned,
    };
  }

  // Calcular próxima data de revisão (Spaced Repetition)
  DateTime calculateNextReviewDate() {
    final intervals = [1, 3, 7, 14, 30]; // dias
    final intervalIndex = timesReviewed.clamp(0, intervals.length - 1);
    final daysToAdd = intervals[intervalIndex];
    return DateTime.now().add(Duration(days: daysToAdd));
  }

  // Verificar se precisa de revisão
  bool get needsReview {
    if (mastered) return false;
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  // Verificar urgência da revisão
  ReviewUrgency get reviewUrgency {
    if (!needsReview) return ReviewUrgency.onTime;
    if (nextReviewDate == null) return ReviewUrgency.urgent;

    final daysOverdue = DateTime.now().difference(nextReviewDate!).inDays;
    if (daysOverdue >= 3) return ReviewUrgency.urgent;
    if (daysOverdue >= 1) return ReviewUrgency.overdue;
    return ReviewUrgency.today;
  }

  // Copiar com modificações
  DiaryEntry copyWith({
    String? userNote,
    String? userStrategy,
    int? difficultyRating,
    String? emotion,
    DateTime? nextReviewDate,
    int? timesReviewed,
    bool? mastered,
  }) {
    return DiaryEntry(
      id: id,
      userId: userId,
      questionId: questionId,
      questionText: questionText,
      correctAnswer: correctAnswer,
      userAnswer: userAnswer,
      userNote: userNote ?? this.userNote,
      userStrategy: userStrategy ?? this.userStrategy,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      emotion: emotion ?? this.emotion,
      subject: subject,
      createdAt: createdAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      mastered: mastered ?? this.mastered,
      xpEarned: xpEarned,
    );
  }
}

enum ReviewUrgency {
  urgent, // 🔴 Atrasado 3+ dias
  overdue, // 🟡 Atrasado 1-2 dias
  today, // 🟠 Revisar hoje
  onTime, // 🟢 Em dia
}

extension ReviewUrgencyExtension on ReviewUrgency {
  String get emoji {
    switch (this) {
      case ReviewUrgency.urgent:
        return '🔴';
      case ReviewUrgency.overdue:
        return '🟡';
      case ReviewUrgency.today:
        return '🟠';
      case ReviewUrgency.onTime:
        return '🟢';
    }
  }

  String get label {
    switch (this) {
      case ReviewUrgency.urgent:
        return 'Urgente';
      case ReviewUrgency.overdue:
        return 'Atrasado';
      case ReviewUrgency.today:
        return 'Hoje';
      case ReviewUrgency.onTime:
        return 'Em dia';
    }
  }
}
