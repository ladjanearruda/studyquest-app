class Mission {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final List<String> activityIds;
  final bool isOptional;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.activityIds,
    this.isOptional = false,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      xpReward: json['xpReward'],
      activityIds: List<String>.from(json['activityIds']),
      isOptional: json['isOptional'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'activityIds': activityIds,
        'isOptional': isOptional,
      };
}
