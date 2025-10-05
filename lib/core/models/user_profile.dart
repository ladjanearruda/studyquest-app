// lib/core/models/user_profile.dart - Integração Avatar V4.1

import 'avatar.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

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

  // ✅ CAMPOS AVATAR V4.1 - ATUALIZADOS
  final AvatarType? selectedAvatarType;
  final AvatarGender? selectedAvatarGender;

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
    this.selectedAvatarType,
    this.selectedAvatarGender,
  });

  // ✅ NOVOS GETTERS V4.1

  // Verificar se tem avatar completo selecionado
  bool get hasSelectedAvatar =>
      selectedAvatarType != null && selectedAvatarGender != null;

  // Obter avatar selecionado completo
  Avatar? get selectedAvatar {
    if (selectedAvatarType != null && selectedAvatarGender != null) {
      return Avatar.fromTypeAndGender(
          selectedAvatarType!, selectedAvatarGender!);
    }
    return null;
  }

  // Obter avatar recomendado (sempre disponível)
  AvatarType get recommendedAvatarType => Avatar.recommendForProfile(this);

  // Obter avatar ativo (selecionado ou recomendado)
  Avatar getActiveAvatar({AvatarGender? defaultGender}) {
    if (hasSelectedAvatar) {
      return selectedAvatar!;
    }

    // Se não tem selecionado, usar recomendado com gênero padrão
    final gender = defaultGender ?? AvatarGender.masculino;
    return Avatar.fromTypeAndGender(recommendedAvatarType, gender);
  }

  // Obter nome completo do avatar ativo
  String getActiveAvatarName({AvatarGender? defaultGender}) {
    final avatar = getActiveAvatar(defaultGender: defaultGender);
    return avatar.getFullName(name);
  }

  // ✅ FACTORY E SERIALIZAÇÃO ATUALIZADOS

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
      // ✅ NOVOS CAMPOS V4.1
      selectedAvatarType: json['selectedAvatarType'] != null
          ? AvatarType.values.byName(json['selectedAvatarType'])
          : null,
      selectedAvatarGender: json['selectedAvatarGender'] != null
          ? AvatarGender.values.byName(json['selectedAvatarGender'])
          : null,
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
      // ✅ NOVOS CAMPOS V4.1
      'selectedAvatarType': selectedAvatarType?.name,
      'selectedAvatarGender': selectedAvatarGender?.name,
    };
  }

  // ✅ COPYWITH ATUALIZADO
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
    AvatarType? selectedAvatarType,
    AvatarGender? selectedAvatarGender,
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
      selectedAvatarType: selectedAvatarType ?? this.selectedAvatarType,
      selectedAvatarGender: selectedAvatarGender ?? this.selectedAvatarGender,
    );
  }

  // ✅ MÉTODOS HELPER PARA AVATAR

  // Selecionar avatar específico
  UserProfile selectAvatar(AvatarType type, AvatarGender gender) {
    return copyWith(
      selectedAvatarType: type,
      selectedAvatarGender: gender,
    );
  }

  // Limpar seleção de avatar (volta para recomendado)
  UserProfile clearAvatarSelection() {
    return copyWith(
      selectedAvatarType: null,
      selectedAvatarGender: null,
    );
  }

  // Verificar se avatar específico está selecionado
  bool isAvatarSelected(AvatarType type, AvatarGender gender) {
    return selectedAvatarType == type && selectedAvatarGender == gender;
  }

  // Obter opções de avatar recomendadas (masculino e feminino do tipo recomendado)
  List<Avatar> getRecommendedAvatarOptions() {
    final recommendedType = recommendedAvatarType;
    return [
      Avatar.fromTypeAndGender(recommendedType, AvatarGender.masculino),
      Avatar.fromTypeAndGender(recommendedType, AvatarGender.feminino),
    ];
  }
}

// ✅ EXTENSÃO ATUALIZADA PARA COMPATIBILIDADE
extension UserProfileAvatar on UserProfile {
  // Compatibilidade com código existente
  AvatarType? get selectedAvatar => selectedAvatarType;

  AvatarType get recommendedAvatar => recommendedAvatarType;

  Avatar get avatarData => getActiveAvatar();
}
