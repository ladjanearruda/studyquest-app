// lib/features/avatar/providers/avatar_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/avatar.dart';
import '../../../core/models/user_profile.dart';

// Estado do avatar
class AvatarState {
  final AvatarType? selectedAvatar;
  final AvatarType recommendedAvatar;
  final bool isLoading;
  final String? error;

  const AvatarState({
    this.selectedAvatar,
    required this.recommendedAvatar,
    this.isLoading = false,
    this.error,
  });

  AvatarState copyWith({
    AvatarType? selectedAvatar,
    AvatarType? recommendedAvatar,
    bool? isLoading,
    String? error,
  }) {
    return AvatarState(
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      recommendedAvatar: recommendedAvatar ?? this.recommendedAvatar,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Avatar ativo (selecionado ou recomendado)
  AvatarType get activeAvatar => selectedAvatar ?? recommendedAvatar;

  // Dados completos do avatar ativo
  Avatar get activeAvatarData => Avatar.fromType(activeAvatar);
}

// Provider do Avatar
class AvatarNotifier extends StateNotifier<AvatarState> {
  final UserProfile userProfile;

  AvatarNotifier(this.userProfile)
      : super(
          AvatarState(
            recommendedAvatar: Avatar.recommendForProfile(userProfile),
          ),
        );

  // Selecionar avatar
  void selectAvatar(AvatarType avatarType) {
    state = state.copyWith(selectedAvatar: avatarType);
  }

  // Resetar para recomendação
  void useRecommended() {
    state = state.copyWith(selectedAvatar: null);
  }

  // Verificar se avatar está selecionado
  bool isSelected(AvatarType avatarType) {
    return state.selectedAvatar == avatarType;
  }

  // Verificar se é o recomendado
  bool isRecommended(AvatarType avatarType) {
    return state.recommendedAvatar == avatarType;
  }

  // Obter dados de um avatar específico
  Avatar getAvatarData(AvatarType type) {
    return Avatar.fromType(type);
  }

  // Salvar seleção (aqui você integraria com seu sistema de persistência)
  Future<void> saveSelection() async {
    state = state.copyWith(isLoading: true);

    try {
      // TODO: Integrar com seu sistema de persistência
      // Exemplo: await userRepository.updateAvatar(userProfile.id, state.selectedAvatar);

      await Future.delayed(const Duration(milliseconds: 500)); // Simula save

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao salvar avatar: $e',
      );
    }
  }
}

// Provider factory - precisa do UserProfile
final avatarProvider =
    StateNotifierProvider.family<AvatarNotifier, AvatarState, UserProfile>(
  (ref, userProfile) => AvatarNotifier(userProfile),
);

// Provider para lista de todos os avatares disponíveis
final allAvatarsProvider = Provider<List<Avatar>>((ref) {
  return AvatarType.values.map((type) => Avatar.fromType(type)).toList();
});
