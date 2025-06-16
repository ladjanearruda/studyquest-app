class ActivityFeedback {
  final String userId;
  final String activityId;
  final bool wasCorrect;
  final String? comment;
  final DateTime submittedAt;

  ActivityFeedback({
    required this.userId,
    required this.activityId,
    required this.wasCorrect,
    this.comment,
    required this.submittedAt,
  });

  factory ActivityFeedback.fromJson(Map<String, dynamic> json) {
    return ActivityFeedback(
      userId: json['userId'],
      activityId: json['activityId'],
      wasCorrect: json['wasCorrect'],
      comment: json['comment'],
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'activityId': activityId,
        'wasCorrect': wasCorrect,
        'comment': comment,
        'submittedAt': submittedAt.toIso8601String(),
      };
}
