// lib/features/avatar/providers/avatar_provider.dart - Sistema V4.1

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/avatar.dart';
import '../../../core/models/user_profile.dart';

// Estado do avatar V4.1
class AvatarState {
  final AvatarType? selectedAvatarType;
  final AvatarGender? selectedAvatarGender;
  final AvatarType recommendedAvatarType;
  final bool isLoading;
  final String? error;

  const AvatarState({
    this.selectedAvatarType,
    this.selectedAvatarGender,
    required this.recommendedAvatarType,
    this.isLoading = false,
    this.error,
  });

  AvatarState copyWith({
    AvatarType? selectedAvatarType,
    AvatarGender? selectedAvatarGender,
    AvatarType? recommendedAvatarType,
    bool? isLoading,
    String? error,
  }) {
    return AvatarState(
      selectedAvatarType: selectedAvatarType ?? this.selectedAvatarType,
      selectedAvatarGender: selectedAvatarGender ?? this.selectedAvatarGender,
      recommendedAvatarType:
          recommendedAvatarType ?? this.recommendedAvatarType,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Verificar se tem avatar completo selecionado
  bool get hasCompleteSelection =>
      selectedAvatarType != null && selectedAvatarGender != null;

  // Avatar ativo (selecionado ou recomendado com gênero padrão masculino)
  Avatar get activeAvatar {
    if (hasCompleteSelection) {
      return Avatar.fromTypeAndGender(
          selectedAvatarType!, selectedAvatarGender!);
    }
    // Se não tem seleção completa, usar recomendado masculino como padrão
    return Avatar.fromTypeAndGender(
        recommendedAvatarType, AvatarGender.masculino);
  }

  // Obter avatar com gênero específico
  Avatar getAvatarWithGender(AvatarGender gender) {
    final type = selectedAvatarType ?? recommendedAvatarType;
    return Avatar.fromTypeAndGender(type, gender);
  }

  // Compatibilidade com código existente
  AvatarType get activeAvatarType =>
      selectedAvatarType ?? recommendedAvatarType;
  Avatar get activeAvatarData => activeAvatar;
}

// Provider do Avatar V4.1
class AvatarNotifier extends StateNotifier<AvatarState> {
  final UserProfile userProfile;

  AvatarNotifier(this.userProfile)
      : super(
          AvatarState(
            recommendedAvatarType: Avatar.recommendForProfile(userProfile),
            selectedAvatarType: userProfile.selectedAvatarType,
            selectedAvatarGender: userProfile.selectedAvatarGender,
          ),
        );

  // Selecionar avatar completo (tipo + gênero)
  void selectAvatar(AvatarType type, AvatarGender gender) {
    state = state.copyWith(
      selectedAvatarType: type,
      selectedAvatarGender: gender,
    );
  }

  // Selecionar apenas tipo (mantém gênero atual ou padrão)
  void selectAvatarType(AvatarType type) {
    final gender = state.selectedAvatarGender ?? AvatarGender.masculino;
    selectAvatar(type, gender);
  }

  // Selecionar apenas gênero (mantém tipo atual ou recomendado)
  void selectAvatarGender(AvatarGender gender) {
    final type = state.selectedAvatarType ?? state.recommendedAvatarType;
    selectAvatar(type, gender);
  }

  // Resetar para recomendação (limpar seleção)
  void useRecommended() {
    state = state.copyWith(
      selectedAvatarType: null,
      selectedAvatarGender: null,
    );
  }

  // Verificar se avatar específico está selecionado
  bool isAvatarSelected(AvatarType type, AvatarGender gender) {
    return state.selectedAvatarType == type &&
        state.selectedAvatarGender == gender;
  }

  // Verificar se tipo está selecionado (qualquer gênero)
  bool isTypeSelected(AvatarType type) {
    return state.selectedAvatarType == type;
  }

  // Verificar se gênero está selecionado (qualquer tipo)
  bool isGenderSelected(AvatarGender gender) {
    return state.selectedAvatarGender == gender;
  }

  // Verificar se é o tipo recomendado
  bool isRecommendedType(AvatarType type) {
    return state.recommendedAvatarType == type;
  }

  // Obter dados de um avatar específico
  Avatar getAvatarData(AvatarType type, AvatarGender gender) {
    return Avatar.fromTypeAndGender(type, gender);
  }

  // Obter todos os avatares de um tipo (masculino + feminino)
  List<Avatar> getAvatarsByType(AvatarType type) {
    return Avatar.getAvatarsByType(type);
  }

  // Obter avatar ativo com nome do usuário
  String getActiveAvatarName() {
    return state.activeAvatar.getFullName(userProfile.name);
  }

  // Obter nome de avatar específico com nome do usuário
  String getAvatarName(AvatarType type, AvatarGender gender) {
    final avatar = Avatar.fromTypeAndGender(type, gender);
    return avatar.getFullName(userProfile.name);
  }

  // Obter opções recomendadas (masculino + feminino do tipo recomendado)
  List<Avatar> getRecommendedOptions() {
    return Avatar.getAvatarsByType(state.recommendedAvatarType);
  }

  // Salvar seleção (integrar com sistema de persistência)
  Future<void> saveSelection() async {
    if (!state.hasCompleteSelection) {
      state = state.copyWith(error: 'Selecione tipo e gênero do avatar');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // TODO: Integrar com sistema de persistência
      // Exemplo: await userRepository.updateAvatar(
      //   userProfile.id,
      //   state.selectedAvatarType!,
      //   state.selectedAvatarGender!
      // );

      await Future.delayed(const Duration(milliseconds: 500)); // Simula save

      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao salvar avatar: $e',
      );
    }
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Analytics - obter dados da seleção atual
  Map<String, dynamic> getSelectionAnalytics() {
    return {
      'selected_type': state.selectedAvatarType?.name,
      'selected_gender': state.selectedAvatarGender?.name,
      'recommended_type': state.recommendedAvatarType.name,
      'has_complete_selection': state.hasCompleteSelection,
      'user_name': userProfile.name,
      'active_avatar_name': getActiveAvatarName(),
      'is_using_recommendation': !state.hasCompleteSelection,
    };
  }
}

// Provider factory - precisa do UserProfile
final avatarProvider =
    StateNotifierProvider.family<AvatarNotifier, AvatarState, UserProfile>(
  (ref, userProfile) => AvatarNotifier(userProfile),
);

// Provider para lista de todos os avatares disponíveis (8 total)
final allAvatarsProvider = Provider<List<Avatar>>((ref) {
  return Avatar.getAllAvatars();
});

// Provider para avatares agrupados por tipo (para UI)
final avatarsGroupedByTypeProvider =
    Provider<Map<AvatarType, List<Avatar>>>((ref) {
  final Map<AvatarType, List<Avatar>> grouped = {};

  for (final type in AvatarType.values) {
    grouped[type] = Avatar.getAvatarsByType(type);
  }

  return grouped;
});

// Provider para tipos de avatar disponíveis
final avatarTypesProvider = Provider<List<AvatarType>>((ref) {
  return AvatarType.values;
});

// Provider para gêneros disponíveis
final avatarGendersProvider = Provider<List<AvatarGender>>((ref) {
  return AvatarGender.values;
});

// Provider para verificar se usuário tem avatar configurado
final hasConfiguredAvatarProvider =
    Provider.family<bool, UserProfile>((ref, userProfile) {
  final avatarNotifier = ref.watch(avatarProvider(userProfile).notifier);
  return ref.watch(avatarProvider(userProfile)).hasCompleteSelection;
});

// Provider para nome do avatar ativo
final activeAvatarNameProvider =
    Provider.family<String, UserProfile>((ref, userProfile) {
  final avatarNotifier = ref.watch(avatarProvider(userProfile).notifier);
  return avatarNotifier.getActiveAvatarName();
});
