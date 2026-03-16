// lib/features/diario/providers/diary_provider.dart
// ✅ V9.4 - Sprint 9 Fase 3: Revanche para TODOS os erros + Anotação 1:1
// 📅 Atualizado: 27/02/2026
// 🎯 Mudanças:
//    - errosQuestionIds: TODOS os erros (anotados ou não)
//    - anotacoesQuestionIds: só os que têm anotação (para badge Transformador)
//    - Anotação 1:1: editar se já existe

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
  final bool isInitialized;
  final String? error;
  final DiaryStats stats;
  final String? userId;

  // ✅ V9.4: Separação de erros e anotações
  final Set<String> errosQuestionIds; // TODOS os erros (para borda dourada)
  final Set<String>
      anotacoesQuestionIds; // Só com anotação (para badge Transformador)

  // ✅ V9.6: Respostas completas (para gráficos de performance)
  final List<Map<String, dynamic>> userResponses;

  DiaryState({
    this.entries = const [],
    this.emotions = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    DiaryStats? stats,
    this.userId,
    this.errosQuestionIds = const {},
    this.anotacoesQuestionIds = const {},
    this.userResponses = const [],
  }) : stats = stats ?? DiaryStats();

  DiaryState copyWith({
    List<DiaryEntry>? entries,
    List<DiaryEmotion>? emotions,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    DiaryStats? stats,
    String? userId,
    Set<String>? errosQuestionIds,
    Set<String>? anotacoesQuestionIds,
    List<Map<String, dynamic>>? userResponses,
  }) {
    return DiaryState(
      entries: entries ?? this.entries,
      emotions: emotions ?? this.emotions,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      stats: stats ?? this.stats,
      userId: userId ?? this.userId,
      errosQuestionIds: errosQuestionIds ?? this.errosQuestionIds,
      anotacoesQuestionIds: anotacoesQuestionIds ?? this.anotacoesQuestionIds,
      userResponses: userResponses ?? this.userResponses,
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
    if (state.isInitialized && state.userId != null) {
      print('📒 DiaryProvider já inicializado, pulando...');
      return;
    }

    try {
      final user = await FirebaseRestAuth.getCurrentUser();
      if (user != null) {
        state = state.copyWith(userId: user.uid);
        await loadEntriesFromFirebase();
        await _loadErrosFromFirebase(); // ✅ V9.4: Carregar erros
        state = state.copyWith(isInitialized: true);
      }
    } catch (e) {
      print('❌ Erro ao inicializar DiaryProvider: $e');
    }
  }

  /// Método público para garantir inicialização
  Future<void> ensureInitialized() async {
    if (!state.isInitialized || state.userId == null) {
      await _initializeUser();
    } else if (state.entries.isEmpty && state.userId != null) {
      await loadEntriesFromFirebase();
      await _loadErrosFromFirebase();
    }
  }

  /// ✅ V9.4: Carregar TODOS os erros do Firebase (user_responses onde was_correct = false)
  Future<void> _loadErrosFromFirebase() async {
    if (state.userId == null) return;

    try {
      final responses =
          await FirebaseDiaryService.getUserResponses(state.userId!);

      // Filtrar apenas erros
      final erros = responses
          .where((r) => r['was_correct'] == false)
          .map((r) => r['question_id'] as String)
          .toSet();

      state = state.copyWith(errosQuestionIds: erros, userResponses: responses);
      print('📒 Erros carregados: ${erros.length} questões, ${responses.length} respostas totais');

      // 🔍 DEBUG userResponses
      print('[DEBUG userResponses] Total: ${responses.length}');
      if (responses.isEmpty) {
        print('[DEBUG userResponses] ⚠️ VAZIO - coleção user_responses não retornou dados para userId=${state.userId}');
      } else {
        print('[DEBUG userResponses] Chaves disponíveis: ${responses.first.keys.toList()}');
        print('[DEBUG userResponses] Primeira resposta completa: ${responses.first}');
        if (responses.length > 1) {
          print('[DEBUG userResponses] Segunda resposta: ${responses[1]}');
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar erros: $e');
    }
  }

  /// Carregar anotações do Firebase
  Future<void> loadEntriesFromFirebase() async {
    if (state.userId == null) {
      print('⚠️ userId null, tentando obter...');
      final user = await FirebaseRestAuth.getCurrentUser();
      if (user != null) {
        state = state.copyWith(userId: user.uid);
      } else {
        print('❌ Não foi possível obter userId');
        return;
      }
    }

    try {
      state = state.copyWith(isLoading: true);

      final entries =
          await FirebaseDiaryService.getUserDiaryEntries(state.userId!);

      // ✅ V9.4: Separar IDs
      // Anotações = questões que têm entrada no diário E não estão mastered
      final anotacoesIds =
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
        anotacoesQuestionIds: anotacoesIds,
        isLoading: false,
        isInitialized: true,
      );

      print(
          '📒 Diário carregado: ${entries.length} anotações, ${anotacoesIds.length} pendentes');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Erro ao carregar diário: $e');
    }
  }

  // ========================================
  // ✅ V9.4: MÉTODOS DE REVANCHE ATUALIZADOS
  // ========================================

  /// Verificar se uma questão é revanche (usuário ERROU antes - anotou ou não)
  bool isRevanche(String questionId) {
    return state.errosQuestionIds.contains(questionId);
  }

  /// Verificar se uma questão tem anotação (para badge Transformador)
  bool temAnotacao(String questionId) {
    return state.anotacoesQuestionIds.contains(questionId);
  }

  /// ✅ V9.4: Registrar erro (chamado quando usuário erra qualquer questão)
  void registrarErro(String questionId) {
    final novosErros = Set<String>.from(state.errosQuestionIds);
    novosErros.add(questionId);
    state = state.copyWith(errosQuestionIds: novosErros);
    print('📝 Erro registrado: $questionId (total: ${novosErros.length})');
  }

  /// Obter anotação de uma questão (se existir e não estiver mastered)
  DiaryEntry? getAnnotationForQuestion(String questionId) {
    try {
      return state.entries.firstWhere(
        (entry) => entry.questionId == questionId && !entry.mastered,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obter TODAS as anotações de uma questão (incluindo mastered)
  List<DiaryEntry> getAllAnnotationsForQuestion(String questionId) {
    return state.entries
        .where((entry) => entry.questionId == questionId)
        .toList();
  }

  /// Transformar erro (usuário acertou questão que tinha ANOTADO)
  /// Retorna XP bônus ganho
  Future<int> transformarErro(String questionId) async {
    if (state.userId == null) return 0;

    // ✅ V9.4: Só transforma se tinha anotação
    if (!temAnotacao(questionId)) {
      print('ℹ️ Questão $questionId não tinha anotação, não é transformação');
      return 0;
    }

    try {
      final entryIndex = state.entries.indexWhere(
        (entry) => entry.questionId == questionId && !entry.mastered,
      );

      if (entryIndex == -1) return 0;

      final entry = state.entries[entryIndex];
      const xpBonus = 15; // XP por transformar erro

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

        // Remover da lista de anotações pendentes
        final newAnotacoesIds = Set<String>.from(state.anotacoesQuestionIds);
        newAnotacoesIds.remove(questionId);

        // Remover da lista de erros (já dominou)
        final newErrosIds = Set<String>.from(state.errosQuestionIds);
        newErrosIds.remove(questionId);

        // Atualizar stats
        final newStats = state.stats.copyWith(
          totalReviews: state.stats.totalReviews + 1,
          totalTransformations: state.stats.totalTransformations + 1,
        );

        state = state.copyWith(
          entries: newEntries,
          stats: newStats,
          anotacoesQuestionIds: newAnotacoesIds,
          errosQuestionIds: newErrosIds,
        );

        print('🏆 ERRO TRANSFORMADO: $questionId (+$xpBonus XP)');
        print('   Total transformações: ${newStats.totalTransformations}');
        return xpBonus;
      }

      return 0;
    } catch (e) {
      print('❌ Erro ao transformar erro: $e');
      return 0;
    }
  }

  // ========================================
  // 📝 ADICIONAR/EDITAR ANOTAÇÃO (1:1)
  // ========================================

  /// ✅ V9.4: Adicionar OU editar anotação (1 questão = 1 anotação)
  Future<int> addOrUpdateAnnotation(DiaryAnnotation annotation,
      {String? questionId}) async {
    if (state.userId == null) {
      final user = await FirebaseRestAuth.getCurrentUser();
      if (user != null) {
        state = state.copyWith(userId: user.uid);
      } else {
        print('❌ Usuário não autenticado para salvar anotação');
        return 0;
      }
    }

    final finalQuestionId = questionId ?? annotation.questionId;

    // ✅ V9.4: Verificar se já existe anotação para esta questão
    final existingEntry = getAnnotationForQuestion(finalQuestionId);

    if (existingEntry != null) {
      // EDITAR anotação existente
      print('✏️ Anotação já existe para $finalQuestionId, editando...');

      final success = await FirebaseDiaryService.updateEntry(
        existingEntry.id,
        userNote: annotation.learning,
        userStrategy: annotation.strategy,
      );

      if (success) {
        // Atualizar na lista local
        final entryIndex =
            state.entries.indexWhere((e) => e.id == existingEntry.id);
        if (entryIndex != -1) {
          final updatedEntry = existingEntry.copyWith(
            userNote: annotation.learning,
            userStrategy: annotation.strategy,
            difficultyRating: annotation.difficulty,
            emotion: annotation.emotion.emoji,
          );

          final newEntries = [...state.entries];
          newEntries[entryIndex] = updatedEntry;
          state = state.copyWith(entries: newEntries);
        }

        print('✏️ Anotação atualizada: ${existingEntry.id}');
        return 10; // XP menor por edição
      }
      return 0;
    }

    // CRIAR nova anotação
    return await _createNewAnnotation(annotation, finalQuestionId);
  }

  /// Criar nova anotação (método interno)
  Future<int> _createNewAnnotation(
      DiaryAnnotation annotation, String questionId) async {
    try {
      state = state.copyWith(isLoading: true);

      // Salvar no Firebase
      final docId = await FirebaseDiaryService.saveDiaryEntry(
        userId: state.userId!,
        questionId: questionId,
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
        questionId: questionId,
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

      // Adicionar aos IDs de anotações
      final newAnotacoesIds = Set<String>.from(state.anotacoesQuestionIds);
      newAnotacoesIds.add(questionId);

      // Atualizar stats
      final updatedStats = state.stats.copyWith(
        totalEntries: state.stats.totalEntries + 1,
        lastEntryDate: DateTime.now(),
      );

      state = state.copyWith(
        entries: updatedEntries,
        stats: updatedStats,
        anotacoesQuestionIds: newAnotacoesIds,
        isLoading: false,
      );

      print('📝 Nova anotação salva: $docId');
      print('📒 Total anotações: ${updatedEntries.length}');
      return 25; // XP ganho
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Erro ao criar anotação: $e');
      return 0;
    }
  }

  /// ✅ Método de compatibilidade (chama addOrUpdateAnnotation)
  Future<int> addAnnotation(DiaryAnnotation annotation,
      {String? questionId}) async {
    return await addOrUpdateAnnotation(annotation, questionId: questionId);
  }

  // ========================================
  // ✅ V9.3: EDITAR E EXCLUIR ANOTAÇÃO
  // ========================================

  /// Excluir anotação
  Future<bool> deleteAnnotation(String entryId) async {
    if (state.userId == null) return false;

    try {
      final success = await FirebaseDiaryService.deleteEntry(entryId);

      if (success) {
        final entry = state.entries.firstWhere((e) => e.id == entryId);
        final updatedEntries =
            state.entries.where((e) => e.id != entryId).toList();

        // Remover da lista de anotações se não estava mastered
        final newAnotacoesIds = Set<String>.from(state.anotacoesQuestionIds);
        if (!entry.mastered) {
          newAnotacoesIds.remove(entry.questionId);
        }

        final updatedStats = state.stats.copyWith(
          totalEntries: state.stats.totalEntries - 1,
          totalTransformations: entry.mastered
              ? state.stats.totalTransformations - 1
              : state.stats.totalTransformations,
        );

        state = state.copyWith(
          entries: updatedEntries,
          stats: updatedStats,
          anotacoesQuestionIds: newAnotacoesIds,
        );

        print('🗑️ Anotação excluída: $entryId');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Erro ao excluir anotação: $e');
      return false;
    }
  }

  /// Editar anotação (nota e estratégia)
  Future<bool> editAnnotation(
      String entryId, String newNote, String newStrategy) async {
    if (state.userId == null) return false;

    try {
      final success = await FirebaseDiaryService.updateEntry(
        entryId,
        userNote: newNote,
        userStrategy: newStrategy,
      );

      if (success) {
        final entryIndex = state.entries.indexWhere((e) => e.id == entryId);
        if (entryIndex != -1) {
          final updatedEntry = state.entries[entryIndex].copyWith(
            userNote: newNote,
            userStrategy: newStrategy,
          );

          final newEntries = [...state.entries];
          newEntries[entryIndex] = updatedEntry;

          state = state.copyWith(entries: newEntries);
          print('✏️ Anotação editada: $entryId');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Erro ao editar anotação: $e');
      return false;
    }
  }

  // ========================================
  // 📊 EMOÇÕES E SESSÕES
  // ========================================

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

  /// Completar revisão de uma anotação
  /// dominei=true → avança intervalo (+5 XP, +10 bônus se 5/5 completo)
  /// dominei=false → reseta para dia 1 (+3 XP)
  Future<int> completeReview(String entryId, {required bool dominei}) async {
    if (state.userId == null) return 0;

    try {
      final entryIndex = state.entries.indexWhere((e) => e.id == entryId);
      if (entryIndex == -1) return 0;

      final entry = state.entries[entryIndex];
      const intervals = [1, 3, 7, 14, 30];

      int newTimesReviewed;
      bool newMastered;
      DateTime newNextReview;

      if (dominei) {
        newTimesReviewed = entry.timesReviewed + 1;
        newMastered = newTimesReviewed >= 5;
        final days = intervals[newTimesReviewed.clamp(0, intervals.length - 1)];
        newNextReview = DateTime.now().add(Duration(days: days));
      } else {
        newTimesReviewed = 0;
        newMastered = false;
        newNextReview = DateTime.now().add(const Duration(days: 1));
      }

      final success = await FirebaseDiaryService.completeReview(
        entryId: entryId,
        currentTimesReviewed: entry.timesReviewed,
        dominei: dominei,
      );
      if (!success) return 0;

      final updatedEntry = entry.copyWith(
        timesReviewed: newTimesReviewed,
        mastered: newMastered,
        nextReviewDate: newNextReview,
      );

      final newEntries = [...state.entries];
      newEntries[entryIndex] = updatedEntry;

      final newAnotacoesIds = Set<String>.from(state.anotacoesQuestionIds);
      if (newMastered) newAnotacoesIds.remove(entry.questionId);

      final newStats = state.stats.copyWith(
        totalReviews: state.stats.totalReviews + 1,
        totalTransformations: newMastered
            ? state.stats.totalTransformations + 1
            : state.stats.totalTransformations,
      );

      state = state.copyWith(
        entries: newEntries,
        stats: newStats,
        anotacoesQuestionIds: newAnotacoesIds,
      );

      print('✅ Revisão: $entryId (dominei=$dominei, reviews=$newTimesReviewed, mastered=$newMastered)');
      if (!dominei) return 3;
      return newMastered ? 15 : 5; // 5 base + 10 bônus se dominou (5/5)
    } catch (e) {
      print('❌ Erro ao completar revisão: $e');
      return 0;
    }
  }

  Future<List<DiaryEntry>> getPendingReviews() async {
    if (state.userId == null) return [];

    try {
      return await FirebaseDiaryService.getPendingReviews(state.userId!);
    } catch (e) {
      print('❌ Erro ao buscar revisões: $e');
      return [];
    }
  }

  int get pendingReviewsCount {
    final now = DateTime.now();
    return state.entries
        .where((e) => !e.mastered && (e.nextReviewDate?.isBefore(now) ?? false))
        .length;
  }

  // ========================================
  // 🔧 UTILITÁRIOS
  // ========================================

  Future<void> refresh() async {
    print('🔄 Forçando recarga do Diário...');
    await loadEntriesFromFirebase();
    await _loadErrosFromFirebase();
  }

  Future<void> updateUserId(String userId) async {
    state = state.copyWith(userId: userId, isInitialized: false);
    await loadEntriesFromFirebase();
    await _loadErrosFromFirebase();
  }
}

// ========================================
// 📦 PROVIDER
// ========================================

final diaryProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((ref) {
  return DiaryNotifier();
});

// ========================================
// 📦 PROVIDERS AUXILIARES
// ========================================

/// Provider para verificar se questão é revanche
final isRevancheProvider = Provider.family<bool, String>((ref, questionId) {
  return ref.watch(diaryProvider).errosQuestionIds.contains(questionId);
});

/// Provider para verificar se questão tem anotação
final temAnotacaoProvider = Provider.family<bool, String>((ref, questionId) {
  return ref.watch(diaryProvider).anotacoesQuestionIds.contains(questionId);
});

/// Provider para obter anotação de uma questão
final anotacaoQuestaoProvider =
    Provider.family<DiaryEntry?, String>((ref, questionId) {
  final entries = ref.watch(diaryProvider).entries;
  try {
    return entries.firstWhere(
      (entry) => entry.questionId == questionId && !entry.mastered,
    );
  } catch (e) {
    return null;
  }
});
