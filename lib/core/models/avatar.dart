// lib/core/models/avatar.dart - Sistema V6.9.2 com 3 Estados Emocionais
// ✅ ATUALIZADO: 24 PNGs integrados (8 avatares × 3 estados)

import 'user_profile.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

enum AvatarType {
  academico,
  competitivo,
  explorador,
  equilibrado,
}

enum AvatarGender {
  masculino,
  feminino,
}

enum AvatarEmotion {
  neutro, // Default: menus, navegação, telas
  feliz, // Acertos, conquistas, XP ganho
  determinado, // Erros, desafios, motivação
}

class Avatar {
  final AvatarType type;
  final AvatarGender gender;
  final String personalityTitle; // "o Estudioso", "a Estudiosa"
  final String description;
  final String primaryColor;
  final String secondaryColor;
  final List<String> characteristics;

  // ✅ NOVO: 3 paths para os 3 estados emocionais
  final String neutralPath;
  final String happyPath;
  final String determinedPath;

  const Avatar({
    required this.type,
    required this.gender,
    required this.personalityTitle,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.characteristics,
    required this.neutralPath,
    required this.happyPath,
    required this.determinedPath,
  });

  // ✅ NOVO: Obter path baseado na emoção
  String getPath(AvatarEmotion emotion) {
    switch (emotion) {
      case AvatarEmotion.neutro:
        return neutralPath;
      case AvatarEmotion.feliz:
        return happyPath;
      case AvatarEmotion.determinado:
        return determinedPath;
    }
  }

  // Gerar nome completo com nome do usuário
  String getFullName(String userName) {
    return '$userName, $personalityTitle';
  }

  // ID único para identificar avatar específico
  String get uniqueId => '${type.name}_${gender.name}';

  // Factory para criar avatar baseado em tipo e gênero
  factory Avatar.fromTypeAndGender(AvatarType type, AvatarGender gender) {
    switch (type) {
      case AvatarType.academico:
        return gender == AvatarGender.masculino
            ? _createAcademicoMasculino()
            : _createAcademicoFeminino();

      case AvatarType.competitivo:
        return gender == AvatarGender.masculino
            ? _createCompetitivoMasculino()
            : _createCompetitivoFeminino();

      case AvatarType.explorador:
        return gender == AvatarGender.masculino
            ? _createExploradorMasculino()
            : _createExploradorFeminino();

      case AvatarType.equilibrado:
        return gender == AvatarGender.masculino
            ? _createEquilibradoMasculino()
            : _createEquilibradoFeminino();
    }
  }

  // Factory para compatibilidade com código existente
  factory Avatar.fromType(AvatarType type) {
    return Avatar.fromTypeAndGender(type, AvatarGender.masculino);
  }

  // ========================================
  // CRIADORES DOS 8 AVATARES COM 3 ESTADOS
  // ========================================

  static Avatar _createAcademicoMasculino() {
    return const Avatar(
      type: AvatarType.academico,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Estudioso',
      description: 'Dedicado e focado, domina a teoria antes da prática!',
      primaryColor: '#2E7D55',
      secondaryColor: '#4A9B6B',
      characteristics: [
        'Metódico e organizado',
        'Gosta de teoria',
        'Planeja antes de agir',
        'Foco na precisão'
      ],
      neutralPath:
          'assets/images/avatars/academico/masculino/academico_masculino_neutro.png',
      happyPath:
          'assets/images/avatars/academico/masculino/academico_masculino_feliz.png',
      determinedPath:
          'assets/images/avatars/academico/masculino/academico_masculino_determinado.png',
    );
  }

  static Avatar _createAcademicoFeminino() {
    return const Avatar(
      type: AvatarType.academico,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Estudiosa',
      description: 'Dedicada e intelectual, sempre vai além nas pesquisas!',
      primaryColor: '#2E7D55',
      secondaryColor: '#4A9B6B',
      characteristics: [
        'Intelectual e dedicada',
        'Gosta de pesquisar',
        'Colaborativa',
        'Foco na excelência'
      ],
      neutralPath:
          'assets/images/avatars/academico/feminino/academico_feminino_neutro.png',
      happyPath:
          'assets/images/avatars/academico/feminino/academico_feminino_feliz.png',
      determinedPath:
          'assets/images/avatars/academico/feminino/academico_feminino_determinado.png',
    );
  }

  static Avatar _createCompetitivoMasculino() {
    return const Avatar(
      type: AvatarType.competitivo,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Determinado',
      description: 'Competitivo nato, busca sempre estar no topo!',
      primaryColor: '#E74C3C',
      secondaryColor: '#F39C12',
      characteristics: [
        'Ambicioso e determinado',
        'Gosta de desafios',
        'Busca a vitória',
        'Persistente'
      ],
      neutralPath:
          'assets/images/avatars/competitivo/masculino/competitivo_masculino_neutro.png',
      happyPath:
          'assets/images/avatars/competitivo/masculino/competitivo_masculino_feliz.png',
      determinedPath:
          'assets/images/avatars/competitivo/masculino/competitivo_masculino_determinado.png',
    );
  }

  static Avatar _createCompetitivoFeminino() {
    return const Avatar(
      type: AvatarType.competitivo,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Determinada',
      description: 'Focada em resultados e sempre em busca da vitória!',
      primaryColor: '#E74C3C',
      secondaryColor: '#F39C12',
      characteristics: [
        'Focada e vencedora',
        'Gosta de competir',
        'Busca excelência',
        'Estratégica'
      ],
      neutralPath:
          'assets/images/avatars/competitivo/feminino/competitivo_feminino_neutro.png',
      happyPath:
          'assets/images/avatars/competitivo/feminino/competitivo_feminino_feliz.png',
      determinedPath:
          'assets/images/avatars/competitivo/feminino/competitivo_feminino_determinado.png',
    );
  }

  static Avatar _createExploradorMasculino() {
    return const Avatar(
      type: AvatarType.explorador,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Aventureiro',
      description: 'Curioso e investigativo, quer descobrir todos os segredos!',
      primaryColor: '#3498DB',
      secondaryColor: '#2ECC71',
      characteristics: [
        'Curioso por natureza',
        'Gosta de experimentar',
        'Faz muitas perguntas',
        'Aprende explorando'
      ],
      neutralPath:
          'assets/images/avatars/explorador/masculino/explorador_masculino_neutro.png',
      happyPath:
          'assets/images/avatars/explorador/masculino/explorador_masculino_feliz.png',
      determinedPath:
          'assets/images/avatars/explorador/masculino/explorador_masculino_determinado.png',
    );
  }

  static Avatar _createExploradorFeminino() {
    return const Avatar(
      type: AvatarType.explorador,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Aventureira',
      description: 'Curiosa e criativa, sempre buscando novos caminhos!',
      primaryColor: '#3498DB',
      secondaryColor: '#2ECC71',
      characteristics: [
        'Curiosa e criativa',
        'Gosta de inovar',
        'Busca novos caminhos',
        'Aprende fazendo'
      ],
      neutralPath:
          'assets/images/avatars/explorador/feminino/explorador_feminino_neutro.png',
      happyPath:
          'assets/images/avatars/explorador/feminino/explorador_feminino_feliz.png',
      determinedPath:
          'assets/images/avatars/explorador/feminino/explorador_feminino_determinado.png',
    );
  }

  static Avatar _createEquilibradoMasculino() {
    return const Avatar(
      type: AvatarType.equilibrado,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Sábio',
      description: 'Analítico e inteligente, sempre tem um plano equilibrado!',
      primaryColor: '#9B59B6',
      secondaryColor: '#8E44AD',
      characteristics: [
        'Equilibrado e sereno',
        'Pensa antes de agir',
        'Analisa padrões',
        'Busca harmonia'
      ],
      neutralPath:
          'assets/images/avatars/equilibrado/masculino/equilibrado_masculino_neutro.png',
      happyPath:
          'assets/images/avatars/equilibrado/masculino/equilibrado_masculino_feliz.png',
      determinedPath:
          'assets/images/avatars/equilibrado/masculino/equilibrado_masculino_determinado.png',
    );
  }

  static Avatar _createEquilibradoFeminino() {
    return const Avatar(
      type: AvatarType.equilibrado,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Sábia',
      description: 'Analítica e sábia, combina estratégia com serenidade!',
      primaryColor: '#9B59B6',
      secondaryColor: '#8E44AD',
      characteristics: [
        'Sábia e equilibrada',
        'Estratégia é tudo',
        'Busca harmonia',
        'Centrada e focada'
      ],
      neutralPath:
          'assets/images/avatars/equilibrado/feminino/equilibrado_feminino_neutro.png',
      happyPath:
          'assets/images/avatars/equilibrado/feminino/equilibrado_feminino_feliz.png',
      determinedPath:
          'assets/images/avatars/equilibrado/feminino/equilibrado_feminino_determinado.png',
    );
  }

  // Recomendação baseada no perfil do usuário
  static AvatarType recommendForProfile(UserProfile profile) {
    if (profile.targetUniversity != null &&
        profile.preferredTrail == ProfessionalTrail.matematicaTecnologia) {
      return AvatarType.academico;
    }

    if (profile.preferredTrail == ProfessionalTrail.cienciasNatureza) {
      return AvatarType.explorador;
    }

    if (profile.difficulties.length >= 3) {
      return AvatarType.academico;
    }

    if (profile.primaryGoal == StudyGoal.enemPrep ||
        profile.dailyStudyMinutes >= 120) {
      return AvatarType.competitivo;
    }

    return AvatarType.equilibrado;
  }

  // Obter todos os avatares disponíveis (8 total)
  static List<Avatar> getAllAvatars() {
    final List<Avatar> avatars = [];

    for (final type in AvatarType.values) {
      for (final gender in AvatarGender.values) {
        avatars.add(Avatar.fromTypeAndGender(type, gender));
      }
    }

    return avatars;
  }

  // Obter avatares por tipo (2 por tipo - masculino e feminino)
  static List<Avatar> getAvatarsByType(AvatarType type) {
    return [
      Avatar.fromTypeAndGender(type, AvatarGender.masculino),
      Avatar.fromTypeAndGender(type, AvatarGender.feminino),
    ];
  }

  // Converte cor hex para Color (para usar no Flutter)
  static int hexToColor(String hex) {
    return int.parse(hex.replaceFirst('#', '0xFF'));
  }
}

// Extensão para UserProfile incluir avatar com gênero
extension UserProfileAvatar on UserProfile {
  AvatarType? get selectedAvatarType {
    return null; // Será expandido quando integrarmos
  }

  AvatarGender? get selectedAvatarGender {
    return null; // Será expandido quando integrarmos
  }

  AvatarType get recommendedAvatarType {
    return Avatar.recommendForProfile(this);
  }

  Avatar getRecommendedAvatar({AvatarGender? preferredGender}) {
    final type = recommendedAvatarType;
    final gender = preferredGender ?? AvatarGender.masculino;
    return Avatar.fromTypeAndGender(type, gender);
  }

  Avatar getCurrentAvatar({AvatarGender? preferredGender}) {
    final type = selectedAvatarType ?? recommendedAvatarType;
    final gender =
        selectedAvatarGender ?? preferredGender ?? AvatarGender.masculino;
    return Avatar.fromTypeAndGender(type, gender);
  }
}
