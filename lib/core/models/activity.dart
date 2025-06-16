enum ActivityType {
  multipleChoice,
  trueFalse,
  shortAnswer,
  dragAndDrop,
  videoInteraction,
}

class Activity {
  final String id;
  final String question;
  final ActivityType type;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int xp;

  Activity({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.xp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      question: json['question'],
      type: ActivityType.values.byName(json['type']),
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      xp: json['xp'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'type': type.name,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'xp': xp,
      };
}
