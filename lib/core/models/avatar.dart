// lib/core/models/avatar.dart - Sistema V4.1 com nomes dinâmicos

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

class Avatar {
  final AvatarType type;
  final AvatarGender gender;
  final String personalityTitle; // "o Estudioso", "a Estudiosa"
  final String description;
  final String assetPath;
  final String primaryColor;
  final String secondaryColor;
  final List<String> characteristics;

  const Avatar({
    required this.type,
    required this.gender,
    required this.personalityTitle,
    required this.description,
    required this.assetPath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.characteristics,
  });

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
    // Por padrão, retorna masculino para manter compatibilidade
    return Avatar.fromTypeAndGender(type, AvatarGender.masculino);
  }

  // Criadores específicos dos 8 avatares
  static Avatar _createAcademicoMasculino() {
    return const Avatar(
      type: AvatarType.academico,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Estudioso',
      description: 'Dedicado e focado, domina a teoria antes da prática!',
      assetPath: 'assets/images/avatars/academico_masculino.png',
      primaryColor: '#2E7D55', // Verde acadêmico
      secondaryColor: '#4A9B6B',
      characteristics: [
        'Metódico e organizado',
        'Gosta de teoria',
        'Planeja antes de agir',
        'Foco na precisão'
      ],
    );
  }

  static Avatar _createAcademicoFeminino() {
    return const Avatar(
      type: AvatarType.academico,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Estudiosa',
      description: 'Dedicada e intelectual, sempre vai além nas pesquisas!',
      assetPath: 'assets/images/avatars/academico_feminino.png',
      primaryColor: '#2E7D55', // Verde acadêmico
      secondaryColor: '#4A9B6B',
      characteristics: [
        'Intelectual e dedicada',
        'Gosta de pesquisar',
        'Colaborativa',
        'Foco na excelência'
      ],
    );
  }

  static Avatar _createCompetitivoMasculino() {
    return const Avatar(
      type: AvatarType.competitivo,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Determinado',
      description: 'Competitivo nato, busca sempre estar no topo!',
      assetPath: 'assets/images/avatars/competitivo_masculino.png',
      primaryColor: '#E74C3C', // Vermelho competitivo
      secondaryColor: '#F39C12',
      characteristics: [
        'Ambicioso e determinado',
        'Gosta de desafios',
        'Busca a vitória',
        'Persistente'
      ],
    );
  }

  static Avatar _createCompetitivoFeminino() {
    return const Avatar(
      type: AvatarType.competitivo,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Determinada',
      description: 'Focada em resultados e sempre em busca da vitória!',
      assetPath: 'assets/images/avatars/competitivo_feminino.png',
      primaryColor: '#E74C3C', // Vermelho competitivo
      secondaryColor: '#F39C12',
      characteristics: [
        'Focada e vencedora',
        'Gosta de competir',
        'Busca excelência',
        'Estratégica'
      ],
    );
  }

  static Avatar _createExploradorMasculino() {
    return const Avatar(
      type: AvatarType.explorador,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Aventureiro',
      description: 'Curioso e investigativo, quer descobrir todos os segredos!',
      assetPath: 'assets/images/avatars/explorador_masculino.png',
      primaryColor: '#3498DB', // Azul explorador
      secondaryColor: '#2ECC71',
      characteristics: [
        'Curioso por natureza',
        'Gosta de experimentar',
        'Faz muitas perguntas',
        'Aprende explorando'
      ],
    );
  }

  static Avatar _createExploradorFeminino() {
    return const Avatar(
      type: AvatarType.explorador,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Aventureira',
      description: 'Curiosa e criativa, sempre buscando novos caminhos!',
      assetPath: 'assets/images/avatars/explorador_feminino.png',
      primaryColor: '#3498DB', // Azul explorador
      secondaryColor: '#2ECC71',
      characteristics: [
        'Curiosa e criativa',
        'Gosta de inovar',
        'Busca novos caminhos',
        'Aprende fazendo'
      ],
    );
  }

  static Avatar _createEquilibradoMasculino() {
    return const Avatar(
      type: AvatarType.equilibrado,
      gender: AvatarGender.masculino,
      personalityTitle: 'o Sábio',
      description: 'Analítico e inteligente, sempre tem um plano equilibrado!',
      assetPath: 'assets/images/avatars/equilibrado_masculino.png',
      primaryColor: '#9B59B6', // Roxo equilibrado
      secondaryColor: '#8E44AD',
      characteristics: [
        'Equilibrado e sereno',
        'Pensa antes de agir',
        'Analisa padrões',
        'Busca harmonia'
      ],
    );
  }

  static Avatar _createEquilibradoFeminino() {
    return const Avatar(
      type: AvatarType.equilibrado,
      gender: AvatarGender.feminino,
      personalityTitle: 'a Sábia',
      description: 'Analítica e sábia, combina estratégia com serenidade!',
      assetPath: 'assets/images/avatars/equilibrado_feminino.png',
      primaryColor: '#9B59B6', // Roxo equilibrado
      secondaryColor: '#8E44AD',
      characteristics: [
        'Sábia e equilibrada',
        'Estratégia é tudo',
        'Busca harmonia',
        'Centrada e focada'
      ],
    );
  }

  // Recomendação baseada no perfil do usuário (mantém lógica existente)
  static AvatarType recommendForProfile(UserProfile profile) {
    // Se tem universidade específica + matemática/tecnologia = Acadêmico
    if (profile.targetUniversity != null &&
        profile.preferredTrail == ProfessionalTrail.matematicaTecnologia) {
      return AvatarType.academico;
    }

    // Se gosta de ciências natureza = Explorador
    if (profile.preferredTrail == ProfessionalTrail.cienciasNatureza) {
      return AvatarType.explorador;
    }

    // Se tem muitas dificuldades = Acadêmico (metódico)
    if (profile.difficulties.length >= 3) {
      return AvatarType.academico;
    }

    // Padrão para ENEM ou metas altas = Competitivo
    if (profile.primaryGoal == StudyGoal.enemPrep ||
        profile.dailyStudyMinutes >= 120) {
      return AvatarType.competitivo;
    }

    // Fallback padrão
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
    // Por enquanto retorna null, será expandido quando integrarmos
    return null;
  }

  AvatarGender? get selectedAvatarGender {
    // Por enquanto retorna null, será expandido quando integrarmos
    return null;
  }

  AvatarType get recommendedAvatarType {
    return Avatar.recommendForProfile(this);
  }

  // Obter avatar recomendado (por padrão masculino, mas usuário pode escolher)
  Avatar getRecommendedAvatar({AvatarGender? preferredGender}) {
    final type = recommendedAvatarType;
    final gender = preferredGender ?? AvatarGender.masculino;
    return Avatar.fromTypeAndGender(type, gender);
  }

  // Obter avatar selecionado ou recomendado
  Avatar getCurrentAvatar({AvatarGender? preferredGender}) {
    final type = selectedAvatarType ?? recommendedAvatarType;
    final gender =
        selectedAvatarGender ?? preferredGender ?? AvatarGender.masculino;
    return Avatar.fromTypeAndGender(type, gender);
  }
}
