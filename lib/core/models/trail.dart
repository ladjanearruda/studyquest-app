enum TrailType {
  cienciasNatureza,
  exatas,
  humanas,
  linguagens,
  tecnologia,
}

class Trail {
  final String id;
  final String title;
  final String description;
  final TrailType type;
  final List<String> subjectIds; // IDs das matérias associadas
  final List<String> missionIds; // IDs das missões

  Trail({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.subjectIds,
    required this.missionIds,
  });

  factory Trail.fromJson(Map<String, dynamic> json) {
    return Trail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: TrailType.values.byName(json['type']),
      subjectIds: List<String>.from(json['subjectIds']),
      missionIds: List<String>.from(json['missionIds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'subjectIds': subjectIds,
        'missionIds': missionIds,
      };
}
