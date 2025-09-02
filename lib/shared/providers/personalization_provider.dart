// lib/shared/providers/personalization_provider.dart - CORRIGIDO
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_model.dart';
import '../../core/models/question_model.dart';
import '../services/firebase_service.dart';

// ===== ESTADO DA PERSONALIZAÇÃO =====
class PersonalizationState {
  final bool isLoading;
  final List<QuestionModel> personalizedQuestions;
  final List<QuestionModel> currentSession;
  final int currentQuestionIndex;
  final UserModel? currentUser;
  final String? error;
  final Map<String, dynamic> sessionStats;
  final bool isSessionActive;

  const PersonalizationState({
    this.isLoading = false,
    this.personalizedQuestions = const [],
    this.currentSession = const [],
    this.currentQuestionIndex = 0,
    this.currentUser,
    this.error,
    this.sessionStats = const {},
    this.isSessionActive = false,
  });

  PersonalizationState copyWith({
    bool? isLoading,
    List<QuestionModel>? personalizedQuestions,
    List<QuestionModel>? currentSession,
    int? currentQuestionIndex,
    UserModel? currentUser,
    String? error,
    Map<String, dynamic>? sessionStats,
    bool? isSessionActive,
  }) {
    return PersonalizationState(
      isLoading: isLoading ?? this.isLoading,
      personalizedQuestions:
          personalizedQuestions ?? this.personalizedQuestions,
      currentSession: currentSession ?? this.currentSession,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentUser: currentUser ?? this.currentUser,
      error: error ?? this.error,
      sessionStats: sessionStats ?? this.sessionStats,
      isSessionActive: isSessionActive ?? this.isSessionActive,
    );
  }
}

// ===== PROVIDER DE PERSONALIZAÇÃO =====
class PersonalizationNotifier extends StateNotifier<PersonalizationState> {
  PersonalizationNotifier() : super(const PersonalizationState());

  // ===== INICIALIZAÇÃO SIMPLES (SEM ONBOARDING) =====

  /// Inicializar com usuário padrão para testes
  Future<void> initializeForTesting() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Buscar usuário atual (mock para testes)
      final user = await FirebaseService.getCurrentUser();
      if (user == null) {
        throw Exception('Não foi possível criar usuário de teste');
      }

      // Gerar questões personalizadas
      final personalizedQuestions =
          await FirebaseService.getPersonalizedQuestions(
        user,
        limit: 20,
      );

      if (personalizedQuestions.isEmpty) {
        throw Exception('Nenhuma questão disponível no momento');
      }

      // Atualizar estado
      state = state.copyWith(
        isLoading: false,
        currentUser: user,
        personalizedQuestions: personalizedQuestions,
        sessionStats: _initializeSessionStats(),
      );

      print(
          '✅ Personalização inicializada: ${personalizedQuestions.length} questões');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('❌ Erro na inicialização: $e');
    }
  }

  Map<String, dynamic> _initializeSessionStats() {
    return {
      'session_start': DateTime.now(),
      'questions_answered': 0,
      'correct_answers': 0,
      'total_time_spent': 0,
      'subjects_studied': <String>{},
      'difficulty_distribution': {'facil': 0, 'medio': 0, 'dificil': 0},
      'errors_by_subject': <String, int>{},
      'performance_trend': <String, double>{},
    };
  }

  // ===== SESSÃO DE QUESTÕES =====

  /// Iniciar sessão de questões
  Future<void> startQuestionSession({
    String? specificSubject,
    String? specificDifficulty,
    int questionsCount = 5,
  }) async {
    if (state.currentUser == null) {
      await initializeForTesting();
      if (state.currentUser == null) {
        state = state.copyWith(error: 'Não foi possível inicializar usuário');
        return;
      }
    }

    try {
      List<QuestionModel> sessionQuestions = _selectSessionQuestions(
        specificSubject: specificSubject,
        specificDifficulty: specificDifficulty,
        count: questionsCount,
      );

      if (sessionQuestions.isEmpty) {
        throw Exception('Não foi possível encontrar questões para esta sessão');
      }

      state = state.copyWith(
        currentSession: sessionQuestions,
        currentQuestionIndex: 0,
        isSessionActive: true,
        sessionStats: _initializeSessionStats(),
        error: null,
      );

      print('🎯 Sessão iniciada: ${sessionQuestions.length} questões');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      print('❌ Erro ao iniciar sessão: $e');
    }
  }

  List<QuestionModel> _selectSessionQuestions({
    String? specificSubject,
    String? specificDifficulty,
    required int count,
  }) {
    var available = List<QuestionModel>.from(state.personalizedQuestions);

    if (specificSubject != null) {
      available = available.where((q) => q.subject == specificSubject).toList();
    }

    if (specificDifficulty != null) {
      available =
          available.where((q) => q.difficulty == specificDifficulty).toList();
    }

    available.shuffle();
    return available.take(count).toList();
  }

  // ===== RESPONDER QUESTÕES =====

  Future<bool> answerCurrentQuestion({
    required int selectedAnswerIndex,
    required int timeSpentSeconds,
  }) async {
    if (!state.isSessionActive ||
        state.currentQuestionIndex >= state.currentSession.length ||
        state.currentUser == null) {
      return false;
    }

    final currentQuestion = state.currentSession[state.currentQuestionIndex];
    final isCorrect = selectedAnswerIndex == currentQuestion.respostaCorreta;

    try {
      // Registrar resposta
      await FirebaseService.recordUserAnswer(
        userId: state.currentUser!.id,
        questionId: currentQuestion.id,
        wasCorrect: isCorrect,
        timeSpent: timeSpentSeconds,
        selectedAnswer: currentQuestion.alternativas[selectedAnswerIndex],
        difficulty: currentQuestion.difficulty,
        subject: currentQuestion.subject,
      );

      // Atualizar stats
      _updateSessionStats(currentQuestion, isCorrect, timeSpentSeconds);

      print('📝 Resposta: ${isCorrect ? '✅ Correto' : '❌ Incorreto'}');
      return isCorrect;
    } catch (e) {
      print('❌ Erro ao registrar resposta: $e');
      _updateSessionStats(currentQuestion, isCorrect, timeSpentSeconds);
      return isCorrect;
    }
  }

  void _updateSessionStats(
      QuestionModel question, bool isCorrect, int timeSpent) {
    final currentStats = Map<String, dynamic>.from(state.sessionStats);

    currentStats['questions_answered'] =
        (currentStats['questions_answered'] ?? 0) + 1;
    if (isCorrect) {
      currentStats['correct_answers'] =
          (currentStats['correct_answers'] ?? 0) + 1;
    }
    currentStats['total_time_spent'] =
        (currentStats['total_time_spent'] ?? 0) + timeSpent;

    final subjects =
        Set<String>.from(currentStats['subjects_studied'] ?? <String>{});
    subjects.add(question.subject);
    currentStats['subjects_studied'] = subjects;

    state = state.copyWith(sessionStats: currentStats);
  }

  // ===== NAVEGAÇÃO =====

  void nextQuestion() {
    if (state.isSessionActive &&
        state.currentQuestionIndex < state.currentSession.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  bool get isSessionComplete =>
      state.isSessionActive &&
      state.currentQuestionIndex >= state.currentSession.length - 1;

  Future<void> endSession() async {
    if (!state.isSessionActive) return;

    final stats = state.sessionStats;
    final answered = stats['questions_answered'] ?? 0;
    final correct = stats['correct_answers'] ?? 0;
    final accuracy = answered > 0 ? correct / answered : 0.0;

    print('📊 Sessão finalizada:');
    print('   Questões: $answered');
    print('   Acertos: $correct');
    print('   Precisão: ${(accuracy * 100).toStringAsFixed(1)}%');

    state = state.copyWith(
      isSessionActive: false,
      currentQuestionIndex: 0,
      currentSession: [],
    );
  }

  // ===== HELPERS =====

  QuestionModel? get currentQuestion {
    if (!state.isSessionActive ||
        state.currentQuestionIndex >= state.currentSession.length) {
      return null;
    }
    return state.currentSession[state.currentQuestionIndex];
  }

  double get sessionProgress {
    if (!state.isSessionActive || state.currentSession.isEmpty) {
      return 0.0;
    }
    return (state.currentQuestionIndex + 1) / state.currentSession.length;
  }

  Map<String, dynamic> get simpleStats {
    final stats = state.sessionStats;
    final answered = stats['questions_answered'] ?? 0;
    final correct = stats['correct_answers'] ?? 0;

    return {
      'accuracy': answered > 0 ? correct / answered : 0.0,
      'total_questions': answered,
      'correct_answers': correct,
      'subjects_count': (stats['subjects_studied'] as Set?)?.length ?? 0,
    };
  }

  void reset() {
    state = const PersonalizationState();
  }
}

// ===== PROVIDERS RIVERPOD =====

final personalizationProvider =
    StateNotifierProvider<PersonalizationNotifier, PersonalizationState>((ref) {
  return PersonalizationNotifier();
});

final currentQuestionProvider = Provider<QuestionModel?>((ref) {
  return ref.read(personalizationProvider.notifier).currentQuestion;
});

final sessionProgressProvider = Provider<double>((ref) {
  return ref.read(personalizationProvider.notifier).sessionProgress;
});

final simpleStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(personalizationProvider.notifier).simpleStats;
});
