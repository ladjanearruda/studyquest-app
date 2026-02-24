// lib/features/diario/providers/diary_provider.dart
// ✅ V9.2 - Sprint 9 Fase 2: Provider do Diário com Firebase
// 📅 Atualizado: 22/02/2026
// 🎯 Persiste anotações no Firebase + detecta revanche

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_entry_model.dart';
import '../models/diary_emotion_model.dart';
import '../widgets/anotar_erro_modal.dart';
import '../../../core/services/firebase_diary_service.dart';
import '../../../core/services/firebase_rest_auth.dart';

/// Estado do Diário
class DiaryState {
  final List<DiaryEntry> entries;
  final List<DiaryEmotion> emotions;
  final bool isLoading;
  final String? error;
  final DiaryStats stats;
  final String? userId;
  final Set<String> revancheQuestionIds; // IDs de questões que são revanche

  DiaryState({
    this.entries = const [],
    this.emotions = const [],
    this.isLoading = false,
    this.error,
    DiaryStats? stats,
    this.userId,
    this.revancheQuestionIds = const {},
  }) : stats = stats ?? DiaryStats();

  DiaryState copyWith({
    List<DiaryEntry>? entries,
    List<DiaryEmotion>? emotions,
    bool? isLoading,
    String? error,
    DiaryStats? stats,
    String? userId,
    Set<String>? revancheQuestionIds,
  }) {
    return DiaryState(
      entries: entries ?? this.entries,
      emotions: emotions ?? this.emotions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      userId: userId ?? this.userId,
      revancheQuestionIds: revancheQuestionIds ?? this.revancheQuestionIds,
    );
  }
}

/// Estatísticas do Diário
class DiaryStats {
  final int totalEntries;
  final int totalReviews;
  final int totalTransformations;
  final int currentStreak;
  final int longestStreak;
  final int badgesEarned;
  final DateTime? lastEntryDate;

  DiaryStats({
    this.totalEntries = 0,
    this.totalReviews = 0,
    this.totalTransformations = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.badgesEarned = 0,
    this.lastEntryDate,
  });

  DiaryStats copyWith({
    int? totalEntries,
    int? totalReviews,
    int? totalTransformations,
    int? currentStreak,
    int? longestStreak,
    int? badgesEarned,
    DateTime? lastEntryDate,
  }) {
    return DiaryStats(
      totalEntries: totalEntries ?? this.totalEntries,
      totalReviews: totalReviews ?? this.totalReviews,
      totalTransformations: totalTransformations ?? this.totalTransformations,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
    );
  }
}

/// Notifier do Diário
class DiaryNotifier extends StateNotifier<DiaryState> {
  DiaryNotifier() : super(DiaryState()) {
    _initializeUser();
  }

  /// Inicializar usuário e carregar dados
  Future<void> _initializeUser() async {
    try {
      final user = await FirebaseRestAuth.getCurrentUser();
      if (user != null) {
        state = state.copyWith(userId: user.uid);
        await loadEntriesFromFirebase();
      }
    } catch (e) {
      print('❌ Erro ao inicializar DiaryProvider: $e');
    }
  }

  /// Carregar anotações do Firebase
  Future<void> loadEntriesFromFirebase() async {
    if (state.userId == null) return;

    try {
      state = state.copyWith(isLoading: true);

      final entries =
          await FirebaseDiaryService.getUserDiaryEntries(state.userId!);

      // Identificar questões que são revanche (não mastered)
      final revancheIds =
          entries.where((e) => !e.mastered).map((e) => e.questionId).toSet();

      // Calcular stats
      final stats = DiaryStats(
        totalEntries: entries.length,
        totalTransformations: entries.where((e) => e.mastered).length,
        lastEntryDate: entries.isNotEmpty ? entries.first.createdAt : null,
      );

      state = state.copyWith(
        entries: entries,
        stats: stats,
        revancheQuestionIds: revancheIds,
        isLoading: false,
      );

      print(
          '📒 Diário carregado: ${entries.length} anotações, ${revancheIds.length} revanches');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Erro ao carregar diário: $e');
    }
  }

  // ========================================
  // ✅ V9.2: MÉTODOS DE REVANCHE
  // ========================================

  /// Verificar se uma questão é revanche (usuário errou e anotou antes)
  bool isRevanche(String questionId) {
    return state.revancheQuestionIds.contains(questionId);
  }

  /// Verificar revanche diretamente no Firebase (para sessão nova)
  Future<bool> checkRevancheFromFirebase(String questionId) async {
    if (state.userId == null) return false;

    try {
      final entry = await FirebaseDiaryService.getAnnotationForQuestion(
        userId: state.userId!,
        questionId: questionId,
      );
      return entry != null;
    } catch (e) {
      return false;
    }
  }

  /// Obter anotação de uma questão (se existir)
  DiaryEntry? getAnnotationForQuestion(String questionId) {
    try {
      return state.entries.firstWhere(
        (entry) => entry.questionId == questionId && !entry.mastered,
      );
    } catch (e) {
      return null;
    }
  }

  /// Transformar erro (usuário acertou questão que tinha errado)
  /// Retorna XP bônus ganho
  Future<int> transformarErro(String questionId) async {
    if (state.userId == null) return 0;

    try {
      // Encontrar a entrada
      final entryIndex = state.entries.indexWhere(
        (entry) => entry.questionId == questionId && !entry.mastered,
      );

      if (entryIndex == -1) return 0;

      final entry = state.entries[entryIndex];
      const xpBonus = 15;

      // Marcar como dominada no Firebase
      final success = await FirebaseDiaryService.markAsMastered(entry.id);

      if (success) {
        // Atualizar estado local
        final updatedEntry = entry.copyWith(
          mastered: true,
          timesReviewed: entry.timesReviewed + 1,
        );

        final newEntries = [...state.entries];
        newEntries[entryIndex] = updatedEntry;

        // Remover da lista de revanches
        final newRevancheIds = Set<String>.from(state.revancheQuestionIds);
        newRevancheIds.remove(questionId);

        // Atualizar stats
        final newStats = state.stats.copyWith(
          totalReviews: state.stats.totalReviews + 1,
          totalTransformations: state.stats.totalTransformations + 1,
        );

        state = state.copyWith(
          entries: newEntries,
          stats: newStats,
          revancheQuestionIds: newRevancheIds,
        );

        print('🏆 ERRO TRANSFORMADO: $questionId (+$xpBonus XP)');
        return xpBonus;
      }

      return 0;
    } catch (e) {
      print('❌ Erro ao transformar erro: $e');
      return 0;
    }
  }

  // ========================================
  // 📝 ADICIONAR ANOTAÇÃO
  // ========================================

  /// Adicionar anotação a partir do modal
  Future<int> addAnnotation(DiaryAnnotation annotation,
      {String? questionId}) async {
    // ✅ DEBUG
    print('🔍 DEBUG addAnnotation INICIOU');
    print('🔍 DEBUG userId atual: ${state.userId}');

    if (state.userId == null) {
      print('🔍 DEBUG userId null, tentando inicializar...');

      // Tentar inicializar
      await _initializeUser();

      print('🔍 DEBUG após init, userId: ${state.userId}');

      if (state.userId == null) {
        print('❌ Usuário não autenticado para salvar anotação');
        return 0;
      }
    }

    try {
      state = state.copyWith(isLoading: true);

      // Gerar questionId se não foi passado
      final finalQuestionId =
          questionId ?? annotation.questionText.hashCode.toString();

      // Salvar no Firebase
      final docId = await FirebaseDiaryService.saveDiaryEntry(
        userId: state.userId!,
        questionId: finalQuestionId,
        questionText: annotation.questionText,
        correctAnswer: annotation.correctAnswer,
        userAnswer: annotation.userAnswer,
        userNote: annotation.learning,
        userStrategy: annotation.strategy,
        difficultyRating: annotation.difficulty,
        emotion: annotation.emotion.emoji,
        subject: annotation.subject,
      );

      if (docId == null) {
        state = state.copyWith(isLoading: false, error: 'Falha ao salvar');
        return 0;
      }

      // Criar entrada local
      final entry = DiaryEntry(
        id: docId,
        userId: state.userId!,
        questionId: finalQuestionId,
        questionText: annotation.questionText,
        correctAnswer: annotation.correctAnswer,
        userAnswer: annotation.userAnswer,
        userNote: annotation.learning,
        userStrategy: annotation.strategy,
        difficultyRating: annotation.difficulty,
        emotion: annotation.emotion.emoji,
        subject: annotation.subject,
        createdAt: DateTime.now(),
        nextReviewDate: DateTime.now().add(const Duration(days: 1)),
        xpEarned: 25,
      );

      // Adicionar à lista local
      final updatedEntries = [entry, ...state.entries];

      // Adicionar aos IDs de revanche
      final newRevancheIds = Set<String>.from(state.revancheQuestionIds);
      newRevancheIds.add(finalQuestionId);

      // Atualizar stats
      final updatedStats = state.stats.copyWith(
        totalEntries: state.stats.totalEntries + 1,
        lastEntryDate: DateTime.now(),
      );

      state = state.copyWith(
        entries: updatedEntries,
        stats: updatedStats,
        revancheQuestionIds: newRevancheIds,
        isLoading: false,
      );

      print('📝 Anotação salva no Firebase: $docId');
      return 25; // XP ganho
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Erro ao adicionar anotação: $e');
      return 0;
    }
  }

  // ========================================
  // 📊 EMOÇÕES E SESSÕES
  // ========================================

  /// Adicionar emoção de sessão
  Future<void> addSessionEmotion(
      EmotionLevel emotion, double accuracy, int questionsAnswered) async {
    try {
      final diaryEmotion = DiaryEmotion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: state.userId ?? 'local_user',
        sessionId: DateTime.now().toIso8601String(),
        emotion: emotion,
        accuracy: accuracy,
        questionsAnswered: questionsAnswered,
        sessionDuration: const Duration(minutes: 5),
        timestamp: DateTime.now(),
      );

      final updatedEmotions = [...state.emotions, diaryEmotion];
      state = state.copyWith(emotions: updatedEmotions);

      print('😊 Emoção de sessão registrada: ${emotion.emoji}');
    } catch (e) {
      print('❌ Erro ao adicionar emoção: $e');
    }
  }

  // ========================================
  // 📅 REVISÕES
  // ========================================

  /// Buscar revisões pendentes
  Future<List<DiaryEntry>> getPendingReviews() async {
    if (state.userId == null) return [];

    try {
      return await FirebaseDiaryService.getPendingReviews(state.userId!);
    } catch (e) {
      print('❌ Erro ao buscar revisões: $e');
      return [];
    }
  }

  /// Contar revisões pendentes (para badge na tab)
  int get pendingReviewsCount {
    final now = DateTime.now();
    return state.entries
        .where((e) => !e.mastered && (e.nextReviewDate?.isBefore(now) ?? false))
        .length;
  }

  // ========================================
  // 🔧 UTILITÁRIOS
  // ========================================

  /// Recarregar dados do Firebase
  Future<void> refresh() async {
    await loadEntriesFromFirebase();
  }

  /// Atualizar userId (quando usuário faz login)
  Future<void> updateUserId(String userId) async {
    state = state.copyWith(userId: userId);
    await loadEntriesFromFirebase();
  }
}

// ========================================
// 📦 PROVIDER
// ========================================

final diaryProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((ref) {
  return DiaryNotifier();
});
