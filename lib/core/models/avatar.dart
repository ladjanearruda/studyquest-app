// lib/core/models/avatar.dart

import 'user_profile.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

enum AvatarType {
  aventureiro,
  explorador,
  estudioso,
  estrategista,
}

class Avatar {
  final AvatarType type;
  final String name;
  final String description;
  final String assetPath;
  final String primaryColor;
  final String secondaryColor;
  final List<String> characteristics;

  const Avatar({
    required this.type,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.characteristics,
  });

  factory Avatar.fromType(AvatarType type) {
    switch (type) {
      case AvatarType.aventureiro:
        return const Avatar(
          type: AvatarType.aventureiro,
          name: 'Aventureiro',
          description: 'Corajoso e determinado, enfrenta qualquer desafio!',
          assetPath: 'assets/images/avatars/aventureiro.png',
          primaryColor: '#FF6B35', // Laranja vibrante
          secondaryColor: '#FF8E53',
          characteristics: [
            'Adora desafios complexos',
            'Aprende fazendo',
            'Persistente e corajoso',
            'Gosta de competir'
          ],
        );

      case AvatarType.explorador:
        return const Avatar(
          type: AvatarType.explorador,
          name: 'Explorador',
          description:
              'Curioso e investigativo, quer descobrir todos os segredos!',
          assetPath: 'assets/images/avatars/explorador.png',
          primaryColor: '#00C851', // Verde StudyQuest
          secondaryColor: '#00D759',
          characteristics: [
            'Curioso por natureza',
            'Gosta de experimentar',
            'Faz muitas perguntas',
            'Aprende explorando'
          ],
        );

      case AvatarType.estudioso:
        return const Avatar(
          type: AvatarType.estudioso,
          name: 'Estudioso',
          description: 'Organizado e focado, domina a teoria antes da prática!',
          assetPath: 'assets/images/avatars/estudioso.png',
          primaryColor: '#007BFF', // Azul StudyQuest
          secondaryColor: '#339CFF',
          characteristics: [
            'Metódico e organizado',
            'Gosta de teoria',
            'Planeja antes de agir',
            'Foco na precisão'
          ],
        );

      case AvatarType.estrategista:
        return const Avatar(
          type: AvatarType.estrategista,
          name: 'Estrategista',
          description: 'Analítico e inteligente, sempre tem um plano!',
          assetPath: 'assets/images/avatars/estrategista.png',
          primaryColor: '#6F42C1', // Roxo
          secondaryColor: '#8A63D2',
          characteristics: [
            'Pensa antes de agir',
            'Analisa padrões',
            'Resolve problemas complexos',
            'Estratégia é tudo'
          ],
        );
    }
  }

  // Recomendação baseada no perfil do usuário
  static AvatarType recommendForProfile(UserProfile profile) {
    // Algoritmo de recomendação baseado nos dados do onboarding

    // Se tem universidade específica + matemática/tecnologia = Estrategista
    if (profile.targetUniversity != null &&
        profile.preferredTrail == ProfessionalTrail.matematicaTecnologia) {
      return AvatarType.estrategista;
    }

    // Se gosta de ciências natureza = Explorador
    if (profile.preferredTrail == ProfessionalTrail.cienciasNatureza) {
      return AvatarType.explorador;
    }

    // Se tem muitas dificuldades = Estudioso (metódico)
    if (profile.difficulties.length >= 3) {
      return AvatarType.estudioso;
    }

    // Padrão para ENEM ou metas altas = Aventureiro
    if (profile.primaryGoal == StudyGoal.enemPrep ||
        profile.dailyStudyMinutes >= 120) {
      return AvatarType.aventureiro;
    }

    // Fallback padrão
    return AvatarType.explorador;
  }

  // Converte cor hex para Color (para usar no Flutter)
  static int hexToColor(String hex) {
    return int.parse(hex.replaceFirst('#', '0xFF'));
  }
}

// Extensão para UserProfile incluir avatar
extension UserProfileAvatar on UserProfile {
  AvatarType? get selectedAvatar {
    // Por enquanto retorna null, será expandido quando integrarmos
    return null;
  }

  AvatarType get recommendedAvatar {
    return Avatar.recommendForProfile(this);
  }

  Avatar get avatarData {
    final avatarType = selectedAvatar ?? recommendedAvatar;
    return Avatar.fromType(avatarType);
  }
}
