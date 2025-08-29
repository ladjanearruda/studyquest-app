// lib/shared/providers/personalization_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_model.dart';
import '../../core/models/question_model.dart';
import '../services/firebase_service.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

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

  // ===== INICIALIZAÇÃO COM DADOS DO ONBOARDING =====

  /// Inicializar sistema com dados do onboarding
  Future<void> initializeFromOnboarding(OnboardingData onboardingData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Converter OnboardingData para Map para o Firebase
      final onboardingMap = {
        'name': onboardingData.name,
        'educationLevel': onboardingData.educationLevel,
        'studyGoal': onboardingData.studyGoal,
        'interestArea': onboardingData.interestArea,
        'dreamUniversity': onboardingData.dreamUniversity,
        'studyTime': onboardingData.studyTime,
        'mainDifficulty': onboardingData.mainDifficulty,
        'studyStyle': onboardingData.studyStyle,
      };

      // Criar usuário no Firebase baseado no onboarding
      final user =
          await FirebaseService.createUserFromOnboarding(onboardingMap);
      if (user == null) {
        throw Exception('Falha ao criar usuário. Tente novamente.');
      }

      // Gerar questões personalizadas baseadas no perfil
      final personalizedQuestions =
          await FirebaseService.getPersonalizedQuestions(
        user,
        limit: 50, // Banco inicial robusto
      );

      if (personalizedQuestions.isEmpty) {
        throw Exception(
            'Nenhuma questão disponível para seu perfil no momento.');
      }

      // Atualizar estado
      state = state.copyWith(
        isLoading: false,
        currentUser: user,
        personalizedQuestions: personalizedQuestions,
        sessionStats: _initializeSessionStats(),
      );

      print(
          '✅ Personalização inicializada: ${personalizedQuestions.length} questões para ${user.name}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('❌ Erro na inicialização: $e');
    }
  }

  /// Inicializar para usuário existente
  Future<void> initializeExistingUser() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Buscar usuário atual do Firebase
      final user = await FirebaseService.getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não encontrado. Faça o onboarding novamente.');
      }

      // Gerar questões personalizadas
      final personalizedQuestions =
          await FirebaseService.getPersonalizedQuestions(
        user,
        limit: 50,
      );

      if (personalizedQuestions.isEmpty) {
        throw Exception('Nenhuma questão encontrada para seu perfil.');
      }

      // Atualizar estado
      state = state.copyWith(
        isLoading: false,
        currentUser: user,
        personalizedQuestions: personalizedQuestions,
        sessionStats: _initializeSessionStats(),
      );

      print('✅ Personalização carregada para usuário existente: ${user.name}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('❌ Erro ao carregar usuário existente: $e');
    }
  }

  Map<String, dynamic> _initializeSessionStats() {
    return {
      'session_start': DateTime.now(),
      'questions_answered': 0,
      'correct_answers': 0,
      'total_time_spent': 0, // em segundos
      'subjects_studied': <String>{},
      'difficulty_distribution': {'facil': 0, 'medio': 0, 'dificil': 0},
      'errors_by_subject': <String, int>{},
      'performance_trend': <String, double>{}, // accuracy por matéria
    };
  }

  // ===== SESSÃO DE QUESTÕES =====

  /// Iniciar uma nova sessão de questões
  Future<void> startQuestionSession({
    String? specificSubject,
    String? specificDifficulty,
    int questionsCount = 10,
  }) async {
    if (state.currentUser == null) {
      state = state.copyWith(
          error: 'Usuário não inicializado. Refaça o onboarding.');
      return;
    }

    try {
      // Filtrar questões baseadas nos parâmetros
      List<QuestionModel> sessionQuestions = _selectSessionQuestions(
        specificSubject: specificSubject,
        specificDifficulty: specificDifficulty,
        count: questionsCount,
      );

      if (sessionQuestions.isEmpty) {
        throw Exception(
            'Não foi possível encontrar questões para esta sessão.');
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

    // Filtrar por matéria se especificada
    if (specificSubject != null) {
      available = available.where((q) => q.subject == specificSubject).toList();
    }

    // Filtrar por dificuldade se especificada
    if (specificDifficulty != null) {
      available =
          available.where((q) => q.difficulty == specificDifficulty).toList();
    }

    // Se não há filtros específicos, aplicar personalização avançada
    if (specificSubject == null && specificDifficulty == null) {
      available = _applyAdvancedPersonalization(available, count);
    }

    // Embaralhar e selecionar quantidade desejada
    available.shuffle();
    return available.take(count).toList();
  }

  List<QuestionModel> _applyAdvancedPersonalization(
    List<QuestionModel> questions,
    int count,
  ) {
    if (state.currentUser == null) return questions;

    final user = state.currentUser!;
    List<QuestionModel> selected = [];

    // 50% questões da dificuldade preferida do usuário
    String preferredDifficulty = _getUserPreferredDifficulty(user);
    var preferredQuestions = questions
        .where((q) => q.difficulty == preferredDifficulty)
        .toList()
      ..shuffle();
    selected.addAll(preferredQuestions.take((count * 0.5).round()));

    // 30% questões das matérias de interesse
    var interestQuestions = questions
        .where((q) => _isSubjectOfInterest(q.subject, user.interestArea))
        .where((q) => !selected.contains(q))
        .toList()
      ..shuffle();
    selected.addAll(interestQuestions.take((count * 0.3).round()));

    // 20% questões balanceamento (outras matérias/dificuldades)
    var remainingQuestions =
        questions.where((q) => !selected.contains(q)).toList()..shuffle();
    selected.addAll(remainingQuestions.take(count - selected.length));

    return selected;
  }

  String _getUserPreferredDifficulty(UserModel user) {
    switch (user.mainGoal) {
      case 'enemPrep':
      case 'specificUniversity':
        return 'dificil';
      case 'improveGrades':
        return 'medio';
      default:
        return 'facil';
    }
  }

  bool _isSubjectOfInterest(String subject, String interestArea) {
    const Map<String, List<String>> interestMapping = {
      'linguagens': ['portugues', 'ingles'],
      'cienciasNatureza': ['matematica', 'fisica', 'quimica', 'biologia'],
      'matematicaTecnologia': ['matematica', 'fisica'],
      'humanas': ['historia', 'geografia', 'portugues'],
      'negocios': ['matematica', 'portugues', 'historia'],
      'descobrindo': [
        'matematica',
        'portugues',
        'fisica',
        'quimica',
        'biologia',
        'historia',
        'geografia',
        'ingles'
      ],
    };

    return interestMapping[interestArea]?.contains(subject) ?? false;
  }

  // ===== RESPONDER QUESTÕES =====

  /// Registrar resposta do usuário
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
      // Registrar no Firebase para IA e rankings futuros
      await FirebaseService.recordUserAnswer(
        userId: state.currentUser!.id,
        questionId: currentQuestion.id,
        wasCorrect: isCorrect,
        timeSpent: timeSpentSeconds,
        selectedAnswer: currentQuestion.alternativas[selectedAnswerIndex],
        difficulty: currentQuestion.difficulty,
        subject: currentQuestion.subject,
      );

      // Atualizar estatísticas da sessão
      _updateSessionStats(currentQuestion, isCorrect, timeSpentSeconds);

      print(
          '📝 Resposta registrada: ${isCorrect ? '✅ Correto' : '❌ Incorreto'}');

      return isCorrect;
    } catch (e) {
      print('❌ Erro ao registrar resposta: $e');
      // Ainda atualiza as stats locais mesmo com erro no Firebase
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
    } else {
      // Registrar erro por matéria
      final errors =
          Map<String, int>.from(currentStats['errors_by_subject'] ?? {});
      errors[question.subject] = (errors[question.subject] ?? 0) + 1;
      currentStats['errors_by_subject'] = errors;
    }

    currentStats['total_time_spent'] =
        (currentStats['total_time_spent'] ?? 0) + timeSpent;

    // Registrar matéria estudada
    final subjects =
        Set<String>.from(currentStats['subjects_studied'] ?? <String>{});
    subjects.add(question.subject);
    currentStats['subjects_studied'] = subjects;

    // Atualizar distribuição de dificuldade
    final difficulty =
        Map<String, int>.from(currentStats['difficulty_distribution'] ?? {});
    difficulty[question.difficulty] =
        (difficulty[question.difficulty] ?? 0) + 1;
    currentStats['difficulty_distribution'] = difficulty;

    // Calcular performance por matéria
    _updatePerformanceTrend(currentStats, question.subject, isCorrect);

    state = state.copyWith(sessionStats: currentStats);
  }

  void _updatePerformanceTrend(
      Map<String, dynamic> stats, String subject, bool isCorrect) {
    final performance =
        Map<String, double>.from(stats['performance_trend'] ?? {});

    // Calcular accuracy da matéria (média móvel simples)
    double currentAccuracy = performance[subject] ?? 0.5; // Start at 50%
    double newAccuracy = isCorrect
        ? (currentAccuracy + 1.0) / 2 // Increase if correct
        : (currentAccuracy + 0.0) / 2; // Decrease if incorrect

    performance[subject] = newAccuracy.clamp(0.0, 1.0);
    stats['performance_trend'] = performance;
  }

  // ===== NAVEGAÇÃO NAS QUESTÕES =====

  /// Ir para próxima questão
  void nextQuestion() {
    if (state.isSessionActive &&
        state.currentQuestionIndex < state.currentSession.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// Verificar se sessão terminou
  bool get isSessionComplete =>
      state.isSessionActive &&
      state.currentQuestionIndex >= state.currentSession.length - 1;

  /// Finalizar sessão atual
  Future<void> endSession() async {
    if (!state.isSessionActive) return;

    // Calcular estatísticas finais
    final stats = state.sessionStats;
    final accuracy =
        (stats['correct_answers'] ?? 0) / (stats['questions_answered'] ?? 1);
    final avgTimePerQuestion =
        (stats['total_time_spent'] ?? 0) / (stats['questions_answered'] ?? 1);

    print('📊 Sessão finalizada:');
    print('   Questões: ${stats['questions_answered']}');
    print('   Acertos: ${stats['correct_answers']}');
    print('   Precisão: ${(accuracy * 100).toStringAsFixed(1)}%');
    print('   Tempo médio: ${avgTimePerQuestion.toStringAsFixed(1)}s');

    state = state.copyWith(
      isSessionActive: false,
      currentQuestionIndex: 0,
      currentSession: [],
    );
  }

  // ===== HELPERS PARA UI =====

  /// Questão atual
  QuestionModel? get currentQuestion {
    if (!state.isSessionActive ||
        state.currentQuestionIndex >= state.currentSession.length) {
      return null;
    }
    return state.currentSession[state.currentQuestionIndex];
  }

  /// Progresso da sessão (0.0 a 1.0)
  double get sessionProgress {
    if (!state.isSessionActive || state.currentSession.isEmpty) {
      return 0.0;
    }
    return (state.currentQuestionIndex + 1) / state.currentSession.length;
  }

  /// Estatísticas simplificadas para UI
  Map<String, dynamic> get simpleStats {
    final stats = state.sessionStats;
    final answered = stats['questions_answered'] ?? 0;
    final correct = stats['correct_answers'] ?? 0;

    return {
      'accuracy': answered > 0 ? correct / answered : 0.0,
      'total_questions': answered,
      'correct_answers': correct,
      'subjects_count': (stats['subjects_studied'] as Set?)?.length ?? 0,
      'avg_time':
          answered > 0 ? (stats['total_time_spent'] ?? 0) / answered : 0.0,
    };
  }

  /// Verificar se deve mostrar trigger do diário
  bool shouldShowDiaryTrigger(bool wasLastAnswerIncorrect) {
    // Trigger do diário aparece após erro + algumas condições
    if (!wasLastAnswerIncorrect) return false;

    final stats = state.sessionStats;
    final answered = stats['questions_answered'] ?? 0;

    // Mostrar após pelo menos 2 questões e se accuracy < 80%
    if (answered >= 2) {
      final accuracy = (stats['correct_answers'] ?? 0) / answered;
      return accuracy < 0.8;
    }

    return false;
  }

  /// Resetar estado (útil para logout)
  void reset() {
    state = const PersonalizationState();
  }

  /// Buscar questão rápida para modo descoberta
  Future<QuestionModel?> getQuickDiscoveryQuestion(String subject) async {
    try {
      if (state.personalizedQuestions.isEmpty && state.currentUser != null) {
        // Se não tem questões carregadas, buscar algumas
        final questions = await FirebaseService.getPersonalizedQuestions(
          state.currentUser!,
          limit: 20,
          specificSubject: subject,
        );
        state = state.copyWith(personalizedQuestions: questions);
      }

      final questions = state.personalizedQuestions
          .where((q) => q.subject == subject)
          .toList()
        ..shuffle();

      return questions.isNotEmpty ? questions.first : null;
    } catch (e) {
      print('❌ Erro ao buscar questão rápida: $e');
      return null;
    }
  }
}

// ===== PROVIDER RIVERPOD =====

final personalizationProvider =
    StateNotifierProvider<PersonalizationNotifier, PersonalizationState>((ref) {
  return PersonalizationNotifier();
});

// ===== PROVIDERS DERIVADOS PARA UI =====

/// Provider para questão atual
final currentQuestionProvider = Provider<QuestionModel?>((ref) {
  final state = ref.watch(personalizationProvider);
  return ref.read(personalizationProvider.notifier).currentQuestion;
});

/// Provider para progresso da sessão
final sessionProgressProvider = Provider<double>((ref) {
  return ref.read(personalizationProvider.notifier).sessionProgress;
});

/// Provider para estatísticas simples
final simpleStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.read(personalizationProvider.notifier).simpleStats;
});

/// Provider para verificar se deve mostrar trigger do diário
final shouldShowDiaryTriggerProvider =
    Provider.family<bool, bool>((ref, wasIncorrect) {
  return ref
      .read(personalizationProvider.notifier)
      .shouldShowDiaryTrigger(wasIncorrect);
});
