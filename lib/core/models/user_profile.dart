enum EducationLevel {
  fundamental6,
  fundamental7,
  fundamental8,
  fundamental9,
  medio1,
  medio2,
  medio3,
}

enum StudyGoal {
  improveGrades,
  enemPrep,
  specificUniversity,
}

enum ProfessionalTrail {
  cienciasNatureza,
  exatas,
  humanas,
  linguagens,
  tecnologia,
}

class UserProfile {
  final String id;
  final String name;
  final String email;

  final EducationLevel educationLevel;
  final StudyGoal primaryGoal;
  final ProfessionalTrail preferredTrail;

  final int dailyStudyMinutes;
  final List<String> difficulties;
  final String? targetUniversity;

  final int totalXP;
  final int currentLevel;
  final Map<String, double> subjectProgress;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.educationLevel,
    required this.primaryGoal,
    required this.preferredTrail,
    required this.dailyStudyMinutes,
    required this.difficulties,
    this.targetUniversity,
    required this.totalXP,
    required this.currentLevel,
    required this.subjectProgress,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      educationLevel: EducationLevel.values.byName(json['educationLevel']),
      primaryGoal: StudyGoal.values.byName(json['primaryGoal']),
      preferredTrail: ProfessionalTrail.values.byName(json['preferredTrail']),
      dailyStudyMinutes: json['dailyStudyMinutes'],
      difficulties: List<String>.from(json['difficulties'] ?? []),
      targetUniversity: json['targetUniversity'],
      totalXP: json['totalXP'],
      currentLevel: json['currentLevel'],
      subjectProgress: Map<String, double>.from(json['subjectProgress']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'educationLevel': educationLevel.name,
      'primaryGoal': primaryGoal.name,
      'preferredTrail': preferredTrail.name,
      'dailyStudyMinutes': dailyStudyMinutes,
      'difficulties': difficulties,
      'targetUniversity': targetUniversity,
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'subjectProgress': subjectProgress,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    EducationLevel? educationLevel,
    StudyGoal? primaryGoal,
    ProfessionalTrail? preferredTrail,
    int? dailyStudyMinutes,
    List<String>? difficulties,
    String? targetUniversity,
    int? totalXP,
    int? currentLevel,
    Map<String, double>? subjectProgress,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      educationLevel: educationLevel ?? this.educationLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      preferredTrail: preferredTrail ?? this.preferredTrail,
      dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
      difficulties: difficulties ?? this.difficulties,
      targetUniversity: targetUniversity ?? this.targetUniversity,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      subjectProgress: subjectProgress ?? this.subjectProgress,
    );
  }
}
