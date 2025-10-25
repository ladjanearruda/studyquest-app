// lib/features/observatorio/providers/ranking_provider.dart
// Provider para gerenciar Rankings do Observatório Educacional
// Sprint 7 - Dia 1-2

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyquest_app/core/models/user_model.dart';
import 'package:studyquest_app/core/models/user_score_model.dart';
import 'package:studyquest_app/core/models/ranking_data_model.dart';
import 'package:studyquest_app/core/services/firebase_rest_auth.dart';
import 'package:studyquest_app/features/observatorio/services/ranking_service.dart';
import 'package:studyquest_app/features/observatorio/services/scoring_service.dart';
import 'package:studyquest_app/shared/services/firebase_service.dart';

// ===== ESTADO DO RANKING =====
class RankingState {
  final bool isLoading;
  final RankingData? rankingData;
  final UserScore? currentUserScore;
  final String? error;
  final DateTime? lastUpdated;

  const RankingState({
    this.isLoading = false,
    this.rankingData,
    this.currentUserScore,
    this.error,
    this.lastUpdated,
  });

  RankingState copyWith({
    bool? isLoading,
    RankingData? rankingData,
    UserScore? currentUserScore,
    String? error,
    DateTime? lastUpdated,
  }) {
    return RankingState(
      isLoading: isLoading ?? this.isLoading,
      rankingData: rankingData ?? this.rankingData,
      currentUserScore: currentUserScore ?? this.currentUserScore,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasData => rankingData != null && rankingData!.hasData;
  bool get isEmpty => rankingData == null || rankingData!.isEmpty;
}

// ===== NOTIFIER DO RANKING =====
class RankingNotifier extends StateNotifier<RankingState> {
  final Ref ref;
  final RankingService _rankingService = RankingService();

  RankingNotifier(this.ref) : super(const RankingState());

  /// Carrega rankings completos do usuário
  Future<void> loadRankings() async {
    // Pegar usuário Firebase autenticado
    final firebaseUser = ref.read(firebaseUserProvider);

    if (firebaseUser == null) {
      state = state.copyWith(
        error: 'Usuário não autenticado',
        isLoading: false,
      );
      print('❌ Erro: Usuário não autenticado');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      print('📊 Carregando rankings para userId: ${firebaseUser.uid}');

      // 1. Buscar UserModel do Firebase
      final userModel = await FirebaseService.getCurrentUser();

      if (userModel == null) {
        throw Exception('Usuário não encontrado no Firestore');
      }

      print('✅ UserModel carregado: ${userModel.name}');

      // 2. Criar UserScore a partir do UserModel
      final userScore = _createUserScoreFromModel(userModel);

      print('📊 UserScore criado:');
      print('   └─ Score: ${userScore.score}');
      print('   └─ Questões: ${userScore.totalQuestions}');
      print('   └─ Acertos: ${userScore.correctAnswers}');
      print('   └─ XP: ${userScore.xpTotal}');
      print('   └─ Streak: ${userScore.streakDays}');

      // 3. Atualizar score no Firebase (antes de buscar rankings)
      await _rankingService.updateUserScore(userScore);
      print('✅ Score atualizado no Firebase');

      // 4. Buscar dados completos dos rankings
      final rankingData = await _rankingService.getRankingData(
        userModel.id,
        userScore,
      );

      print('✅ Rankings carregados:');
      print('   └─ Posição: ${rankingData.userPosition.position}º');
      print('   └─ Top 10 geral: ${rankingData.top10Geral.length}');
      print('   └─ Top 10 série: ${rankingData.top10Serie.length}');
      print('   └─ Top 10 estado: ${rankingData.top10Estado.length}');

      // 5. Atualizar estado
      state = state.copyWith(
        isLoading: false,
        rankingData: rankingData,
        currentUserScore: userScore,
        lastUpdated: DateTime.now(),
        error: null,
      );

      print('🎉 Rankings carregados com sucesso!');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('❌ Erro ao carregar rankings: $e');
    }
  }

  /// Cria UserScore a partir do UserModel
  UserScore _createUserScoreFromModel(UserModel userModel) {
    // Calcular score
    final score = ScoringService.calculateScore(
      correctAnswers: userModel.totalCorrect,
      xpTotal: userModel.totalXp,
      streakDays: userModel.currentStreak,
    );

    // Calcular accuracy
    final accuracy = ScoringService.calculateAccuracy(
      correctAnswers: userModel.totalCorrect,
      totalQuestions: userModel.totalQuestions,
    );

    // Converter avatarType (pegar do UserModel se tiver, senão usar padrão)
    // TODO: Integrar com sistema de avatares quando disponível
    final avatarType = 'equilibrado_masculino'; // Temporário

    return UserScore(
      userId: userModel.id,
      name: userModel.name,
      avatarType: avatarType,
      score: score,
      position: 0, // Será atualizado pelo RankingService
      schoolLevel: userModel.schoolLevel,
      state: 'DF', // ⚠️ Temporário até coletar dados reais
      totalQuestions: userModel.totalQuestions,
      correctAnswers: userModel.totalCorrect,
      xpTotal: userModel.totalXp,
      streakDays: userModel.currentStreak,
      accuracy: accuracy,
      updatedAt: DateTime.now(),
    );
  }

  /// Atualiza score após responder questão
  Future<void> updateScoreAfterQuestion({
    required bool wasCorrect,
    required int xpGained,
  }) async {
    if (state.currentUserScore == null) {
      print('⚠️ Sem UserScore para atualizar');
      return;
    }

    try {
      print('📊 Atualizando score após questão...');

      // Atualizar valores
      final newCorrectAnswers = wasCorrect
          ? state.currentUserScore!.correctAnswers + 1
          : state.currentUserScore!.correctAnswers;

      final newTotalQuestions = state.currentUserScore!.totalQuestions + 1;
      final newXpTotal = state.currentUserScore!.xpTotal + xpGained;

      // Recalcular score
      final newScore = ScoringService.calculateScore(
        correctAnswers: newCorrectAnswers,
        xpTotal: newXpTotal,
        streakDays: state.currentUserScore!.streakDays,
      );

      // Recalcular accuracy
      final newAccuracy = ScoringService.calculateAccuracy(
        correctAnswers: newCorrectAnswers,
        totalQuestions: newTotalQuestions,
      );

      // Atualizar UserScore
      final updatedUserScore = state.currentUserScore!.copyWith(
        score: newScore,
        totalQuestions: newTotalQuestions,
        correctAnswers: newCorrectAnswers,
        xpTotal: newXpTotal,
        accuracy: newAccuracy,
        updatedAt: DateTime.now(),
      );

      // Salvar no Firebase
      await _rankingService.updateUserScore(updatedUserScore);

      // Atualizar estado local
      state = state.copyWith(
        currentUserScore: updatedUserScore,
      );

      print('✅ Score atualizado: ${updatedUserScore.score}');
    } catch (e) {
      print('❌ Erro ao atualizar score: $e');
    }
  }

  /// Atualiza streak do usuário
  Future<void> updateStreak(int newStreak) async {
    if (state.currentUserScore == null) return;

    try {
      print('🔥 Atualizando streak: $newStreak dias');

      // Recalcular score com novo streak
      final newScore = ScoringService.calculateScore(
        correctAnswers: state.currentUserScore!.correctAnswers,
        xpTotal: state.currentUserScore!.xpTotal,
        streakDays: newStreak,
      );

      // Atualizar UserScore
      final updatedUserScore = state.currentUserScore!.copyWith(
        streakDays: newStreak,
        score: newScore,
        updatedAt: DateTime.now(),
      );

      // Salvar no Firebase
      await _rankingService.updateUserScore(updatedUserScore);

      // Atualizar estado local
      state = state.copyWith(
        currentUserScore: updatedUserScore,
      );

      print('✅ Streak atualizado: $newStreak dias');
    } catch (e) {
      print('❌ Erro ao atualizar streak: $e');
    }
  }

  /// Recarrega rankings (força atualização)
  Future<void> refreshRankings() async {
    print('🔄 Recarregando rankings...');
    await loadRankings();
  }

  /// Reseta estado
  void reset() {
    state = const RankingState();
  }
}

// ===== PROVIDERS RIVERPOD =====

/// Provider principal do ranking
final rankingProvider =
    StateNotifierProvider<RankingNotifier, RankingState>((ref) {
  return RankingNotifier(ref);
});

/// Provider para dados do ranking (somente leitura)
final rankingDataProvider = Provider<RankingData?>((ref) {
  return ref.watch(rankingProvider).rankingData;
});

/// Provider para score do usuário atual
final currentUserScoreProvider = Provider<UserScore?>((ref) {
  return ref.watch(rankingProvider).currentUserScore;
});

/// Provider para posição do usuário
final userPositionProvider = Provider<int>((ref) {
  final rankingData = ref.watch(rankingDataProvider);
  return rankingData?.userPosition.position ?? 0;
});

/// Provider para pontos até próxima posição
final pointsToNextProvider = Provider<int>((ref) {
  final rankingData = ref.watch(rankingDataProvider);
  return rankingData?.pointsToNextPosition ?? 0;
});

/// Provider para verificar se está carregando
final isLoadingRankingProvider = Provider<bool>((ref) {
  return ref.watch(rankingProvider).isLoading;
});

/// Provider para erro
final rankingErrorProvider = Provider<String?>((ref) {
  return ref.watch(rankingProvider).error;
});
