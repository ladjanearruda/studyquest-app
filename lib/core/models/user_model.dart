// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name; // ✅ Coletado na Tela 1
  final String schoolLevel; // ✅ Tela 2: 'fundamental6', 'fundamental7', etc.
  final String mainGoal; // ✅ Tela 3: 'improveGrades', 'enemPrep', etc.
  final String interestArea; // ✅ Tela 4: 'linguagens', 'cienciasNatureza', etc.
  final String
      dreamUniversity; // ✅ Tela 5: Nome da universidade ou "ainda_nao_decidi"
  final String studyTime; // ✅ Tela 6: "15-30 min", "30-60 min", etc.
  final String mainDifficulty; // ✅ Tela 7: Matéria com dificuldade
  final String behavioralAspect; // ✅ Tela 7: Aspecto comportamental
  final String studyStyle; // ✅ Tela 8: Estilo de estudo
  final DateTime createdAt;
  final DateTime lastLogin;

  // Stats para gamificação
  final int totalXp;
  final int currentLevel;
  final int totalQuestions;
  final int totalCorrect;
  final int totalStudyTime; // em minutos
  final int longestStreak;
  final int currentStreak;

  const UserModel({
    required this.id,
    required this.name,
    required this.schoolLevel,
    required this.mainGoal,
    required this.interestArea,
    required this.dreamUniversity,
    required this.studyTime,
    required this.mainDifficulty,
    required this.behavioralAspect,
    required this.studyStyle,
    required this.createdAt,
    required this.lastLogin,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.totalQuestions = 0,
    this.totalCorrect = 0,
    this.totalStudyTime = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['profile']['name'] ?? '',
      schoolLevel: data['profile']['school_level'] ?? 'fundamental9',
      mainGoal: data['profile']['main_goal'] ?? 'improveGrades',
      interestArea: data['profile']['interest_area'] ?? 'descobrindo',
      dreamUniversity:
          data['profile']['dream_university'] ?? 'ainda_nao_decidi',
      studyTime: data['profile']['study_time'] ?? '30-60 min',
      mainDifficulty: data['profile']['main_difficulty'] ?? 'matematica',
      behavioralAspect:
          data['profile']['behavioral_aspect'] ?? 'foco_concentracao',
      studyStyle: data['profile']['study_style'] ?? 'sozinho_meu_ritmo',
      createdAt: (data['profile']['created_at'] as Timestamp).toDate(),
      lastLogin: (data['profile']['last_login'] as Timestamp).toDate(),
      totalXp: data['stats']['total_xp'] ?? 0,
      currentLevel: data['stats']['current_level'] ?? 1,
      totalQuestions: data['stats']['total_questions'] ?? 0,
      totalCorrect: data['stats']['total_correct'] ?? 0,
      totalStudyTime: data['stats']['total_study_time'] ?? 0,
      longestStreak: data['stats']['longest_streak'] ?? 0,
      currentStreak: data['stats']['current_streak'] ?? 0,
    );
  }

  // Factory para converter do OnboardingData (seu provider existente)
  factory UserModel.fromOnboardingData(
      String userId, Map<String, dynamic> onboardingData) {
    return UserModel(
      id: userId,
      name: onboardingData['name'] ?? '',
      schoolLevel: _convertEducationLevel(onboardingData['educationLevel']),
      mainGoal: _convertStudyGoal(onboardingData['studyGoal']),
      interestArea: _convertProfessionalTrail(onboardingData['interestArea']),
      dreamUniversity: onboardingData['dreamUniversity'] ?? 'ainda_nao_decidi',
      studyTime: onboardingData['studyTime'] ?? '30-60 min',
      mainDifficulty: onboardingData['mainDifficulty'] ?? 'matematica',
      behavioralAspect:
          _convertBehavioralAspect(onboardingData['behavioralAspect']),
      studyStyle: onboardingData['studyStyle'] ?? 'sozinho_meu_ritmo',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  // Conversores para mapear enums do onboarding para strings
  static String _convertEducationLevel(dynamic educationLevel) {
    if (educationLevel == null) return 'fundamental9';
    return educationLevel
        .toString()
        .split('.')
        .last; // EducationLevel.fundamental6 -> fundamental6
  }

  static String _convertStudyGoal(dynamic studyGoal) {
    if (studyGoal == null) return 'improveGrades';
    return studyGoal
        .toString()
        .split('.')
        .last; // StudyGoal.enemPrep -> enemPrep
  }

  static String _convertProfessionalTrail(dynamic trail) {
    if (trail == null) return 'descobrindo';
    return trail
        .toString()
        .split('.')
        .last; // ProfessionalTrail.linguagens -> linguagens
  }

  static String _convertBehavioralAspect(String? aspect) {
    // Mapear os aspectos comportamentais do seu onboarding
    const Map<String, String> aspectMapping = {
      'Foco e concentração': 'foco_concentracao',
      'Memorização e fixação': 'memorizacao_fixacao',
      'Motivação para estudar': 'motivacao_estudar',
      'Ansiedade em provas': 'ansiedade_provas',
      'Raciocínio lógico': 'raciocinio_logico',
      'Organização dos estudos': 'organizacao_estudos',
      'Interpretação de texto': 'interpretacao_texto',
    };
    return aspectMapping[aspect] ?? 'foco_concentracao';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'profile': {
        'name': name,
        'school_level': schoolLevel,
        'main_goal': mainGoal,
        'interest_area': interestArea,
        'dream_university': dreamUniversity,
        'study_time': studyTime,
        'main_difficulty': mainDifficulty,
        'behavioral_aspect': behavioralAspect,
        'study_style': studyStyle,
        'created_at': Timestamp.fromDate(createdAt),
        'last_login': Timestamp.fromDate(lastLogin),
      },
      'stats': {
        'total_xp': totalXp,
        'current_level': currentLevel,
        'total_questions': totalQuestions,
        'total_correct': totalCorrect,
        'total_study_time': totalStudyTime,
        'longest_streak': longestStreak,
        'current_streak': currentStreak,
      },
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? schoolLevel,
    String? mainGoal,
    String? interestArea,
    String? dreamUniversity,
    String? studyTime,
    String? mainDifficulty,
    String? behavioralAspect,
    String? studyStyle,
    DateTime? createdAt,
    DateTime? lastLogin,
    int? totalXp,
    int? currentLevel,
    int? totalQuestions,
    int? totalCorrect,
    int? totalStudyTime,
    int? longestStreak,
    int? currentStreak,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      mainGoal: mainGoal ?? this.mainGoal,
      interestArea: interestArea ?? this.interestArea,
      dreamUniversity: dreamUniversity ?? this.dreamUniversity,
      studyTime: studyTime ?? this.studyTime,
      mainDifficulty: mainDifficulty ?? this.mainDifficulty,
      behavioralAspect: behavioralAspect ?? this.behavioralAspect,
      studyStyle: studyStyle ?? this.studyStyle,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, schoolLevel: $schoolLevel, mainGoal: $mainGoal)';
  }
}
