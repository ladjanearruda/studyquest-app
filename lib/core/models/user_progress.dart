class UserProgress {
  final String userId;
  final String missionId;
  final List<String> completedActivityIds;
  final int earnedXP;
  final bool completed;

  UserProgress({
    required this.userId,
    required this.missionId,
    required this.completedActivityIds,
    required this.earnedXP,
    required this.completed,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'],
      missionId: json['missionId'],
      completedActivityIds: List<String>.from(json['completedActivityIds']),
      earnedXP: json['earnedXP'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'missionId': missionId,
        'completedActivityIds': completedActivityIds,
        'earnedXP': earnedXP,
        'completed': completed,
      };
}
