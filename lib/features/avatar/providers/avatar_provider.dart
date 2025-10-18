// lib/features/avatar/providers/avatar_provider.dart - Sistema V6.9.3
// ✅ ATUALIZADO: Gerenciamento de 3 estados emocionais

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/avatar.dart';
import '../../../core/models/user_profile.dart';

// Estado do avatar V6.9.3 com emoções
class AvatarState {
  final AvatarType? selectedAvatarType;
  final AvatarGender? selectedAvatarGender;
  final AvatarEmotion currentEmotion; // ✅ NOVO
  final AvatarType recommendedAvatarType;
  final bool isLoading;
  final String? error;

  const AvatarState({
    this.selectedAvatarType,
    this.selectedAvatarGender,
    this.currentEmotion = AvatarEmotion.neutro, // ✅ Default neutro
    required this.recommendedAvatarType,
    this.isLoading = false,
    this.error,
  });

  AvatarState copyWith({
    AvatarType? selectedAvatarType,
    AvatarGender? selectedAvatarGender,
    AvatarEmotion? currentEmotion,
    AvatarType? recommendedAvatarType,
    bool? isLoading,
    String? error,
  }) {
    return AvatarState(
      selectedAvatarType: selectedAvatarType ?? this.selectedAvatarType,
      selectedAvatarGender: selectedAvatarGender ?? this.selectedAvatarGender,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      recommendedAvatarType:
          recommendedAvatarType ?? this.recommendedAvatarType,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Verificar se tem avatar completo selecionado
  bool get hasCompleteSelection =>
      selectedAvatarType != null && selectedAvatarGender != null;

  // Avatar ativo (selecionado ou recomendado)
  Avatar get activeAvatar {
    if (hasCompleteSelection) {
      return Avatar.fromTypeAndGender(
          selectedAvatarType!, selectedAvatarGender!);
    }
    return Avatar.fromTypeAndGender(
        recommendedAvatarType, AvatarGender.masculino);
  }

  // ✅ NOVO: Obter path da imagem atual baseado na emoção
  String get currentAvatarPath {
    return activeAvatar.getPath(currentEmotion);
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

// Provider do Avatar V6.9.3
class AvatarNotifier extends StateNotifier<AvatarState> {
  final UserProfile userProfile;

  AvatarNotifier(this.userProfile)
      : super(
          AvatarState(
            recommendedAvatarType: Avatar.recommendForProfile(userProfile),
            selectedAvatarType: userProfile.selectedAvatarType,
            selectedAvatarGender: userProfile.selectedAvatarGender,
            currentEmotion: AvatarEmotion.neutro, // ✅ Inicia neutro
          ),
        );

  // Selecionar avatar completo (tipo + gênero)
  void selectAvatar(AvatarType type, AvatarGender gender) {
    state = state.copyWith(
      selectedAvatarType: type,
      selectedAvatarGender: gender,
    );
  }

  // Selecionar apenas tipo (mantém gênero atual)
  void selectAvatarType(AvatarType type) {
    final gender = state.selectedAvatarGender ?? AvatarGender.masculino;
    selectAvatar(type, gender);
  }

  // Selecionar apenas gênero (mantém tipo atual)
  void selectAvatarGender(AvatarGender gender) {
    final type = state.selectedAvatarType ?? state.recommendedAvatarType;
    selectAvatar(type, gender);
  }

  // ========================================
  // ✅ NOVOS MÉTODOS - GESTÃO DE EMOÇÕES
  // ========================================

  // Mudar emoção do avatar
  void setEmotion(AvatarEmotion emotion) {
    state = state.copyWith(currentEmotion: emotion);
  }

  // Resetar para neutro (estado padrão)
  void resetToNeutral() {
    state = state.copyWith(currentEmotion: AvatarEmotion.neutro);
  }

  // Mostrar feliz (acertos, conquistas)
  void showHappy() {
    state = state.copyWith(currentEmotion: AvatarEmotion.feliz);
  }

  // Mostrar determinado (erros, desafios)
  void showDetermined() {
    state = state.copyWith(currentEmotion: AvatarEmotion.determinado);
  }

  // Mostrar emoção temporária e voltar ao neutro
  Future<void> showEmotionTemporary(
    AvatarEmotion emotion, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    setEmotion(emotion);
    await Future.delayed(duration);
    if (mounted) {
      resetToNeutral();
    }
  }

  // Reagir a resposta de questão
  Future<void> reactToAnswer(bool isCorrect, {bool isTimeout = false}) async {
    if (isTimeout) {
      // Timeout: determinado por 2 segundos
      await showEmotionTemporary(
        AvatarEmotion.determinado,
        duration: const Duration(seconds: 2),
      );
    } else if (isCorrect) {
      // Acerto: feliz por 3 segundos
      await showEmotionTemporary(
        AvatarEmotion.feliz,
        duration: const Duration(seconds: 3),
      );
    } else {
      // Erro: determinado por 2 segundos (motivacional)
      await showEmotionTemporary(
        AvatarEmotion.determinado,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ========================================
  // MÉTODOS EXISTENTES MANTIDOS
  // ========================================

  // Resetar para recomendação
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

  // Verificar se tipo está selecionado
  bool isTypeSelected(AvatarType type) {
    return state.selectedAvatarType == type;
  }

  // Verificar se gênero está selecionado
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

  // Obter todos os avatares de um tipo
  List<Avatar> getAvatarsByType(AvatarType type) {
    return Avatar.getAvatarsByType(type);
  }

  // Obter avatar ativo com nome do usuário
  String getActiveAvatarName() {
    return state.activeAvatar.getFullName(userProfile.name);
  }

  // Obter nome de avatar específico
  String getAvatarName(AvatarType type, AvatarGender gender) {
    final avatar = Avatar.fromTypeAndGender(type, gender);
    return avatar.getFullName(userProfile.name);
  }

  // Obter opções recomendadas
  List<Avatar> getRecommendedOptions() {
    return Avatar.getAvatarsByType(state.recommendedAvatarType);
  }

  // Salvar seleção
  Future<void> saveSelection() async {
    if (!state.hasCompleteSelection) {
      state = state.copyWith(error: 'Selecione tipo e gênero do avatar');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // TODO: Integrar com sistema de persistência
      await Future.delayed(const Duration(milliseconds: 500));
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

  // Analytics
  Map<String, dynamic> getSelectionAnalytics() {
    return {
      'selected_type': state.selectedAvatarType?.name,
      'selected_gender': state.selectedAvatarGender?.name,
      'current_emotion': state.currentEmotion.name, // ✅ NOVO
      'recommended_type': state.recommendedAvatarType.name,
      'has_complete_selection': state.hasCompleteSelection,
      'user_name': userProfile.name,
      'active_avatar_name': getActiveAvatarName(),
      'is_using_recommendation': !state.hasCompleteSelection,
    };
  }
}

// ========================================
// PROVIDERS
// ========================================

// Provider factory - precisa do UserProfile
final avatarProvider =
    StateNotifierProvider.family<AvatarNotifier, AvatarState, UserProfile>(
  (ref, userProfile) => AvatarNotifier(userProfile),
);

// Provider para lista de todos os avatares (8 total)
final allAvatarsProvider = Provider<List<Avatar>>((ref) {
  return Avatar.getAllAvatars();
});

// Provider para avatares agrupados por tipo
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

// ✅ NOVO: Provider para emoções disponíveis
final avatarEmotionsProvider = Provider<List<AvatarEmotion>>((ref) {
  return AvatarEmotion.values;
});

// Provider para verificar se tem avatar configurado
final hasConfiguredAvatarProvider =
    Provider.family<bool, UserProfile>((ref, userProfile) {
  return ref.watch(avatarProvider(userProfile)).hasCompleteSelection;
});

// Provider para nome do avatar ativo
final activeAvatarNameProvider =
    Provider.family<String, UserProfile>((ref, userProfile) {
  final avatarNotifier = ref.watch(avatarProvider(userProfile).notifier);
  return avatarNotifier.getActiveAvatarName();
});

// ✅ NOVO: Provider para path atual do avatar (com emoção)
final currentAvatarPathProvider =
    Provider.family<String, UserProfile>((ref, userProfile) {
  return ref.watch(avatarProvider(userProfile)).currentAvatarPath;
});

// ✅ NOVO: Provider para emoção atual
final currentEmotionProvider =
    Provider.family<AvatarEmotion, UserProfile>((ref, userProfile) {
  return ref.watch(avatarProvider(userProfile)).currentEmotion;
});
