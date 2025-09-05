// lib/shared/services/firebase_service.dart - CORRIGIDO COM NÍVEL DE CONHECIMENTO
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';
import '../../core/models/question_model.dart';
import '../../core/data/questions_database.dart';
import '../../features/onboarding/screens/onboarding_screen.dart'; // Para acessar NivelHabilidade

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache para questões (performance)
  static final Map<String, List<QuestionModel>> _questionsCache = {};
  static final Map<String, UserModel> _userCache = {};

  // ===== USUÁRIO ATUAL (Usando firebase_rest_auth) =====

  /// Buscar usuário atual via REST API (não SDK)
  static Future<UserModel?> getCurrentUser() async {
    try {
      // Usar firebase_rest_auth.dart em vez de FirebaseAuth SDK
      // Por enquanto, retornar usuário mock para testes
      return UserModel(
        id: 'test_user_123',
        name: 'Explorador Teste',
        schoolLevel: '8ano',
        mainGoal: 'melhorar_notas',
        interestArea: 'matematicaTecnologia',
        dreamUniversity: 'USP',
        studyTime: '30-60 min',
        mainDifficulty: 'matematica',
        behavioralAspect: 'foco_concentracao',
        studyStyle: 'pratico',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        totalXp: 100,
        currentLevel: 2,
        totalQuestions: 15,
        totalCorrect: 12,
        totalStudyTime: 45,
        longestStreak: 5,
        currentStreak: 3,
      );
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  // ===== QUESTÕES PERSONALIZADAS ATUALIZADO =====

  /// Buscar questões personalizadas considerando NÍVEL DE CONHECIMENTO
  static Future<List<QuestionModel>> getPersonalizedQuestions(
    UserModel user, {
    int limit = 10,
    String? specificSubject,
    NivelHabilidade? nivelConhecimento, // NOVO PARÂMETRO
  }) async {
    try {
      print('🎯 Buscando questões personalizadas para ${user.name}...');
      if (nivelConhecimento != null) {
        print('📊 Nível de conhecimento: ${nivelConhecimento.nome}');
      }

      // Usar questões locais do QuestionsDatabase
      List<QuestionModel> allQuestions = QuestionsDatabase.getQuestionsByLevel(
          user.schoolLevel,
          limit: limit * 2);

      if (allQuestions.isEmpty) {
        print('Nenhuma questão encontrada para nível ${user.schoolLevel}');
        return [];
      }

      // ALGORITMO ATUALIZADO: considera nível de conhecimento
      final personalizedQuestions = _personalizeQuestionsComNivel(
        allQuestions,
        user,
        limit,
        nivelConhecimento, // NOVO PARÂMETRO
      );

      print(
          '✅ ${personalizedQuestions.length} questões personalizadas selecionadas');
      return personalizedQuestions;
    } catch (e) {
      print('❌ Erro ao buscar questões personalizadas: $e');
      return [];
    }
  }

  /// ALGORITMO CORRIGIDO: Aplicar personalização 70/30 + NÍVEL DE CONHECIMENTO
  static List<QuestionModel> _personalizeQuestionsComNivel(
    List<QuestionModel> allQuestions,
    UserModel user,
    int limit,
    NivelHabilidade? nivelConhecimento, // NOVO PARÂMETRO
  ) {
    if (allQuestions.isEmpty) return [];

    List<QuestionModel> selected = [];

    // 🎯 DIFICULDADE INTELIGENTE: objetivo + nível de conhecimento
    String preferredDifficulty = _getPreferredDifficultyComNivel(
      user,
      nivelConhecimento,
    );

    print(
        '🎯 Dificuldade selecionada: $preferredDifficulty (objetivo: ${user.mainGoal}, nível: ${nivelConhecimento?.nome ?? "não informado"})');

    // 70% - Questões baseadas na dificuldade inteligente
    var difficultyQuestions =
        allQuestions.where((q) => q.difficulty == preferredDifficulty).toList();

    int seventyPercent = (limit * 0.7).round();
    selected.addAll(_selectRandomly(difficultyQuestions, seventyPercent));

    // 30% - Questões da área de interesse
    var interestQuestions = allQuestions
        .where((q) => _isSubjectOfInterest(q.subject, user.interestArea))
        .where((q) => !selected.contains(q))
        .toList();

    int thirtyPercent = limit - selected.length;
    selected.addAll(_selectRandomly(interestQuestions, thirtyPercent));

    // 🎯 COMPLETAR COM NÍVEL ADEQUADO se necessário
    if (selected.length < limit) {
      var remaining = allQuestions
          .where((q) => !selected.contains(q))
          .where(
              (q) => _isDifficultyAppropriate(q.difficulty, nivelConhecimento))
          .toList();
      selected.addAll(_selectRandomly(remaining, limit - selected.length));
    }

    selected.shuffle();
    return selected.take(limit).toList();
  }

  /// 🎯 MÉTODO CORRIGIDO: Dificuldade baseada em objetivo + nível de conhecimento
  static String _getPreferredDifficultyComNivel(
    UserModel user,
    NivelHabilidade? nivelConhecimento,
  ) {
    // Se não tem nível definido, usar lógica antiga
    if (nivelConhecimento == null) {
      return _getPreferredDifficultyLegacy(user);
    }

    // 🧠 LÓGICA INTELIGENTE: Nível de conhecimento SEMPRE tem prioridade
    switch (nivelConhecimento) {
      case NivelHabilidade.iniciante:
        // Iniciante sempre começa com fácil, independente do objetivo
        return 'facil';

      case NivelHabilidade.intermediario:
        // Intermediário usa objetivo como base, mas limitado
        switch (user.mainGoal) {
          case 'enemPrep':
          case 'specificUniversity':
            return 'medio'; // Não vai direto para difícil
          case 'improveGrades':
            return 'medio';
          default:
            return 'facil';
        }

      case NivelHabilidade.avancado:
        // Avançado pode usar dificuldade baseada no objetivo
        switch (user.mainGoal) {
          case 'enemPrep':
          case 'specificUniversity':
            return 'dificil';
          case 'improveGrades':
            return 'medio';
          default:
            return 'medio'; // Avançado raramente precisa de fácil
        }
    }
  }

  /// Método legacy para compatibilidade
  static String _getPreferredDifficultyLegacy(UserModel user) {
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

  /// 🎯 NOVO: Verificar se dificuldade é apropriada para o nível
  static bool _isDifficultyAppropriate(
    String difficulty,
    NivelHabilidade? nivelConhecimento,
  ) {
    if (nivelConhecimento == null) return true;

    switch (nivelConhecimento) {
      case NivelHabilidade.iniciante:
        // Iniciante: só fácil e médio
        return difficulty == 'facil' || difficulty == 'medio';

      case NivelHabilidade.intermediario:
        // Intermediário: todas as dificuldades
        return true;

      case NivelHabilidade.avancado:
        // Avançado: prefere médio e difícil
        return difficulty == 'medio' || difficulty == 'dificil';
    }
  }

  /// Método mantido sem alterações
  static bool _isSubjectOfInterest(String subject, String interestArea) {
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
    return interestMapping[interestArea]?.contains(subject) ?? true;
  }

  /// Método mantido sem alterações
  static List<T> _selectRandomly<T>(List<T> list, int count) {
    if (list.isEmpty) return [];
    List<T> shuffled = List.from(list)..shuffle();
    return shuffled.take(count).toList();
  }

  // ===== MÉTODOS AUXILIARES PARA INTEGRAÇÃO COM ONBOARDING =====

  /// 🎯 NOVO: Método helper para usar com dados do onboarding
  static Future<List<QuestionModel>> getPersonalizedQuestionsFromOnboarding({
    required UserModel user,
    required NivelHabilidade? nivelConhecimento,
    int limit = 10,
    String? specificSubject,
  }) async {
    print('🎯 Personalizando questões com dados completos do onboarding...');
    print('   Usuário: ${user.name}');
    print('   Série: ${user.schoolLevel}');
    print('   Objetivo: ${user.mainGoal}');
    print('   Interesse: ${user.interestArea}');
    print(
        '   Nível conhecimento: ${nivelConhecimento?.nome ?? "não definido"}');

    return await getPersonalizedQuestions(
      user,
      limit: limit,
      specificSubject: specificSubject,
      nivelConhecimento: nivelConhecimento,
    );
  }

  /// 🎯 NOVO: Estatísticas do algoritmo de personalização
  static Map<String, dynamic> getPersonalizationStats(
    List<QuestionModel> questions,
    NivelHabilidade? nivelConhecimento,
  ) {
    if (questions.isEmpty) return {};

    final difficultyCount = <String, int>{};
    final subjectCount = <String, int>{};

    for (final question in questions) {
      difficultyCount[question.difficulty] =
          (difficultyCount[question.difficulty] ?? 0) + 1;
      subjectCount[question.subject] =
          (subjectCount[question.subject] ?? 0) + 1;
    }

    return {
      'total_questions': questions.length,
      'user_level': nivelConhecimento?.nome ?? 'não definido',
      'difficulty_distribution': difficultyCount,
      'subject_distribution': subjectCount,
      'algorithm_version': 'v6.2_com_nivel_conhecimento',
    };
  }

  // ===== ESTATÍSTICAS DO BANCO (mantido) =====

  /// Obter estatísticas das questões disponíveis
  static Map<String, dynamic> getQuestionsStats() {
    return QuestionsDatabase.getStats();
  }

  /// Validar questões
  static bool validateQuestions() {
    return QuestionsDatabase.validateAllQuestions();
  }

  // ===== PROGRESSO DO USUÁRIO (placeholder mantido) =====

  /// Registrar resposta do usuário
  static Future<void> recordUserAnswer({
    required String userId,
    required String questionId,
    required bool wasCorrect,
    required int timeSpent,
    required String selectedAnswer,
    required String difficulty,
    required String subject,
  }) async {
    try {
      // Por enquanto, apenas log
      print(
          'Resposta registrada: $questionId -> ${wasCorrect ? "Correto" : "Incorreto"}');
      // TODO: Implementar salvamento no Firestore quando necessário
    } catch (e) {
      print('Erro ao registrar resposta: $e');
    }
  }

  // ===== MÉTODOS DE TESTE ATUALIZADOS =====

  /// Teste rápido do sistema com nível de conhecimento
  static Future<void> testSystemComNivel({
    NivelHabilidade? nivelTeste,
  }) async {
    print('🧪 Testando sistema Firebase com nível de conhecimento...');

    final stats = getQuestionsStats();
    print('📊 Estatísticas gerais: $stats');

    final isValid = validateQuestions();
    print('✅ Questões válidas: $isValid');

    final user = await getCurrentUser();
    if (user != null) {
      // Teste com nível específico
      final questions = await getPersonalizedQuestionsFromOnboarding(
        user: user,
        nivelConhecimento: nivelTeste ?? NivelHabilidade.intermediario,
        limit: 5,
      );

      print('🎯 Questões personalizadas: ${questions.length}');

      final personalizationStats =
          getPersonalizationStats(questions, nivelTeste);
      print('📊 Stats personalização: $personalizationStats');

      for (var q in questions.take(2)) {
        print(
            '• ${q.subject} (${q.difficulty}): ${q.enunciado.substring(0, 50)}...');
      }
    }

    print('✅ Teste concluído!');
  }

  /// Teste legado mantido
  static Future<void> testSystem() async {
    await testSystemComNivel();
  }
}
