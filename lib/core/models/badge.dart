class Badge {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final int requiredXP;
  final String? trailId;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.requiredXP,
    this.trailId,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      requiredXP: json['requiredXP'],
      trailId: json['trailId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconUrl': iconUrl,
        'requiredXP': requiredXP,
        'trailId': trailId,
      };
}
