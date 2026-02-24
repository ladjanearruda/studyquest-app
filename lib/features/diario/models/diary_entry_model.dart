// lib/features/diario/models/diary_entry_model.dart
// ✅ V9.0 - Sprint 9: Model de entrada do Diário
// 📅 Atualizado: 19/02/2026

/// Urgência de revisão
enum ReviewUrgency {
  urgent, // 🔴 Atrasado mais de 3 dias
  overdue, // 🟡 Atrasado 1-3 dias
  today, // 🟠 Para hoje
  onTime, // 🟢 No prazo
}

/// Entrada do Diário do Explorador
class DiaryEntry {
  final String id;
  final String userId;
  final String questionId;
  final String questionText;
  final String correctAnswer;
  final String userAnswer;
  final String userNote;
  final String userStrategy;
  final int difficultyRating;
  final String emotion;
  final String subject;
  final DateTime createdAt;
  final DateTime? nextReviewDate;
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

  bool get needsReview {
    if (mastered) return false;
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  ReviewUrgency get reviewUrgency {
    if (mastered) return ReviewUrgency.onTime;
    if (nextReviewDate == null) return ReviewUrgency.urgent;

    final now = DateTime.now();
    final diff = now.difference(nextReviewDate!).inDays;

    if (diff > 3) return ReviewUrgency.urgent;
    if (diff > 0) return ReviewUrgency.overdue;
    if (diff == 0) return ReviewUrgency.today;
    return ReviewUrgency.onTime;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      questionId: map['question_id'] ?? '',
      questionText: map['question_text'] ?? '',
      correctAnswer: map['correct_answer'] ?? '',
      userAnswer: map['user_answer'] ?? '',
      userNote: map['user_note'] ?? '',
      userStrategy: map['user_strategy'] ?? '',
      difficultyRating: map['difficulty_rating'] ?? 3,
      emotion: map['emotion'] ?? '😐',
      subject: map['subject'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      nextReviewDate: map['next_review_date'] != null
          ? DateTime.parse(map['next_review_date'])
          : null,
      timesReviewed: map['times_reviewed'] ?? 0,
      mastered: map['mastered'] ?? false,
      xpEarned: map['xp_earned'] ?? 25,
    );
  }

  DiaryEntry copyWith({
    String? id,
    String? userId,
    String? questionId,
    String? questionText,
    String? correctAnswer,
    String? userAnswer,
    String? userNote,
    String? userStrategy,
    int? difficultyRating,
    String? emotion,
    String? subject,
    DateTime? createdAt,
    DateTime? nextReviewDate,
    int? timesReviewed,
    bool? mastered,
    int? xpEarned,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      userNote: userNote ?? this.userNote,
      userStrategy: userStrategy ?? this.userStrategy,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      emotion: emotion ?? this.emotion,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      mastered: mastered ?? this.mastered,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  DateTime calculateNextReviewDate() {
    final intervals = [1, 3, 7, 14, 30];
    final intervalIndex = timesReviewed.clamp(0, intervals.length - 1);
    final daysToAdd = intervals[intervalIndex];
    return DateTime.now().add(Duration(days: daysToAdd));
  }
}
