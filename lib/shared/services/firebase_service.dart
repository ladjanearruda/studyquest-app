// lib/shared/services/firebase_service.dart - CORRIGIDO SEM firebase_auth
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
// REMOVIDO: import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_model.dart';
import '../../core/models/question_model.dart';
import '../../core/data/questions_database.dart'; // ADICIONADO para questões locais

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // REMOVIDO: static final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // ===== QUESTÕES PERSONALIZADAS =====

  /// Buscar questões personalizadas usando QuestionsDatabase local
  static Future<List<QuestionModel>> getPersonalizedQuestions(
    UserModel user, {
    int limit = 10,
    String? specificSubject,
  }) async {
    try {
      print('Buscando questões personalizadas para ${user.name}...');

      // Usar questões locais do QuestionsDatabase
      List<QuestionModel> allQuestions = QuestionsDatabase.getQuestionsByLevel(
          user.schoolLevel,
          limit: limit * 2);

      if (allQuestions.isEmpty) {
        print('Nenhuma questão encontrada para nível ${user.schoolLevel}');
        return [];
      }

      // Aplicar personalização baseada no usuário
      final personalizedQuestions =
          _personalizeQuestions(allQuestions, user, limit);

      print(
          '${personalizedQuestions.length} questões personalizadas selecionadas');
      return personalizedQuestions;
    } catch (e) {
      print('Erro ao buscar questões personalizadas: $e');
      return [];
    }
  }

  /// Aplicar algoritmo de personalização 70/30
  static List<QuestionModel> _personalizeQuestions(
    List<QuestionModel> allQuestions,
    UserModel user,
    int limit,
  ) {
    if (allQuestions.isEmpty) return [];

    List<QuestionModel> selected = [];

    // 70% - Questões baseadas no objetivo principal
    String preferredDifficulty = _getPreferredDifficulty(user);
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

    // Completar se necessário
    if (selected.length < limit) {
      var remaining = allQuestions.where((q) => !selected.contains(q)).toList();
      selected.addAll(_selectRandomly(remaining, limit - selected.length));
    }

    selected.shuffle();
    return selected.take(limit).toList();
  }

  static String _getPreferredDifficulty(UserModel user) {
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

  static List<T> _selectRandomly<T>(List<T> list, int count) {
    if (list.isEmpty) return [];
    List<T> shuffled = List.from(list)..shuffle();
    return shuffled.take(count).toList();
  }

  // ===== ESTATÍSTICAS DO BANCO =====

  /// Obter estatísticas das questões disponíveis
  static Map<String, dynamic> getQuestionsStats() {
    return QuestionsDatabase.getStats();
  }

  /// Validar questões
  static bool validateQuestions() {
    return QuestionsDatabase.validateAllQuestions();
  }

  // ===== PROGRESSO DO USUÁRIO (placeholder) =====

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

  // ===== MÉTODOS DE TESTE =====

  /// Teste rápido do sistema
  static Future<void> testSystem() async {
    print('🧪 Testando sistema Firebase...');

    final stats = getQuestionsStats();
    print('📊 Estatísticas: $stats');

    final isValid = validateQuestions();
    print('✅ Questões válidas: $isValid');

    final user = await getCurrentUser();
    if (user != null) {
      final questions = await getPersonalizedQuestions(user, limit: 5);
      print('🎯 Questões personalizadas: ${questions.length}');

      for (var q in questions.take(2)) {
        print(
            '• ${q.subject} (${q.difficulty}): ${q.enunciado.substring(0, 50)}...');
      }
    }

    print('✅ Teste concluído!');
  }
}
