// lib/shared/services/firebase_service.dart - CÓDIGO COMPLETO V6.8
// CORREÇÃO: 70% matéria com dificuldade + 30% matéria de interesse

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/models/user_model.dart';
import '../../core/models/question_model.dart';
import '../../core/data/questions_database.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

class CacheEntry {
  final List<QuestionModel> questions;
  final DateTime timestamp;

  CacheEntry(this.questions, this.timestamp);

  bool get isExpired => DateTime.now().difference(timestamp).inHours >= 1;
}

class FirebaseService {
  static const String baseUrl =
      'https://firestore.googleapis.com/v1/projects/studyquest-app-banco/databases/(default)/documents';

  // Cache sistema para performance
  static final Map<String, CacheEntry> _questionsCache = {};

  // ===== MÉTODO PRINCIPAL V6.8 - ALGORITMO CORRIGIDO =====

  /// Buscar questões personalizadas usando dados do onboarding
  static Future<List<QuestionModel>> getPersonalizedQuestionsFromOnboarding({
    required UserModel user,
    NivelHabilidade? nivelConhecimento,
    int limit = 10,
  }) async {
    try {
      print('🎯 INICIANDO ALGORITMO V6.8 CORRIGIDO');
      print('   Usuário: ${user.name} (${user.schoolLevel})');
      print('   Matéria com dificuldade: ${user.mainDifficulty}');
      print('   Área de interesse: ${user.interestArea}');

      // 1. Buscar questões do Firebase com cache
      final allQuestions =
          await _getQuestionsFromFirestoreWithCache(user.schoolLevel);

      if (allQuestions.isEmpty) {
        print('⚠️ Nenhuma questão Firebase. Usando fallback local.');
        return await _getQuestionsFromLocalFallback(user.schoolLevel, limit);
      }

      // 2. Aplicar algoritmo de personalização 70/30 CORRIGIDO
      final personalizedQuestions = _personalizeQuestionsComNivel(
        allQuestions,
        user,
        limit,
        nivelConhecimento,
      );

      print(
          '✅ ${personalizedQuestions.length} questões personalizadas selecionadas');
      return personalizedQuestions;
    } catch (e) {
      print('❌ Erro na personalização: $e');
      return await _getQuestionsFromLocalFallback(user.schoolLevel, limit);
    }
  }

  // ===== ALGORITMO PERSONALIZAÇÃO CORRIGIDO FINAL =====

  static List<QuestionModel> _personalizeQuestionsComNivel(
    List<QuestionModel> allQuestions,
    UserModel user,
    int limit,
    NivelHabilidade? nivelConhecimento,
  ) {
    if (allQuestions.isEmpty) return [];

    List<QuestionModel> selected = [];

    print('🎯 ALGORITMO FINAL CORRIGIDO V6.8:');
    print('   Matéria com dificuldade: ${user.mainDifficulty} (70%)');
    print('   Área de interesse: ${user.interestArea} (30%)');
    print('   Nível do usuário: ${user.userLevel}');

    // 70% - Questões da MATÉRIA com maior dificuldade
    final materiaProblematica = _normalizarNomeMateria(user.mainDifficulty);
    var questoesMateriaDificil = allQuestions
        .where((q) => _isSubjectMatch(q.subject, materiaProblematica))
        .toList();

    int seventyPercent = (limit * 0.7).round();
    questoesMateriaDificil.shuffle();
    selected.addAll(questoesMateriaDificil.take(seventyPercent));

    print(
        '   ✅ Selecionadas ${selected.length}/$seventyPercent questões de $materiaProblematica');

    // 30% - Questões da ÁREA DE INTERESSE (evitando duplicatas)
    var questoesInteresse = allQuestions
        .where((q) => _isSubjectOfInterest(q.subject, user.interestArea))
        .where((q) => !selected.contains(q)) // Evita duplicatas
        .toList();

    int thirtyPercent = limit - selected.length;
    questoesInteresse.shuffle();
    selected.addAll(questoesInteresse.take(thirtyPercent));

    print(
        '   ✅ Selecionadas ${selected.length - seventyPercent}/$thirtyPercent questões de interesse');

    // Completar com questões gerais se necessário
    if (selected.length < limit) {
      var remaining = allQuestions.where((q) => !selected.contains(q)).toList();
      remaining.shuffle();
      final needed = limit - selected.length;
      selected.addAll(remaining.take(needed));

      print(
          '   ✅ Completadas $needed questões gerais para total de ${selected.length}');
    }

    selected.shuffle();
    print('✅ ALGORITMO FINAL: ${selected.length} questões selecionadas');
    return selected.take(limit).toList();
  }

  // ===== MÉTODOS AUXILIARES CORRIGIDOS =====

  /// Normalizar nomes de matérias para comparação
  static String _normalizarNomeMateria(String materia) {
    final normalizado = materia
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');

    const Map<String, String> mapeamento = {
      'portugues e literatura': 'portugues',
      'português e literatura': 'portugues',
      'portugues': 'portugues',
      'português': 'portugues',
      'matematica': 'matematica',
      'matemática': 'matematica',
      'fisica': 'fisica',
      'física': 'fisica',
      'quimica': 'quimica',
      'química': 'quimica',
      'biologia': 'biologia',
      'historia': 'historia',
      'história': 'historia',
      'geografia': 'geografia',
      'ingles': 'ingles',
      'inglês': 'ingles',
    };

    return mapeamento[normalizado] ?? normalizado;
  }

  /// Verificar se uma questão corresponde à matéria específica
  static bool _isSubjectMatch(String questionSubject, String targetSubject) {
    final questionNorm = _normalizarNomeMateria(questionSubject);
    final targetNorm = _normalizarNomeMateria(targetSubject);

    if (questionNorm == targetNorm) return true;

    // Correspondências parciais comuns
    if (targetNorm.contains('portugues') && questionNorm.contains('portugues'))
      return true;
    if (targetNorm.contains('matematica') &&
        questionNorm.contains('matematica')) return true;
    if (targetNorm.contains('fisica') && questionNorm.contains('fisica'))
      return true;
    if (targetNorm.contains('quimica') && questionNorm.contains('quimica'))
      return true;
    if (targetNorm.contains('biologia') && questionNorm.contains('biologia'))
      return true;
    if (targetNorm.contains('historia') && questionNorm.contains('historia'))
      return true;
    if (targetNorm.contains('geografia') && questionNorm.contains('geografia'))
      return true;
    if (targetNorm.contains('ingles') && questionNorm.contains('ingles'))
      return true;

    return false;
  }

  static bool _isSubjectOfInterest(String subject, String interestArea) {
    const Map<String, List<String>> interestMapping = {
      'linguagens': ['portugues', 'ingles', 'literatura'],
      'cienciasNatureza': [
        'matematica',
        'fisica',
        'quimica',
        'biologia',
        'ciencias'
      ],
      'matematicaTecnologia': ['matematica', 'fisica', 'informatica'],
      'humanas': ['historia', 'geografia', 'filosofia', 'sociologia'],
      'negocios': ['matematica', 'portugues', 'historia', 'geografia'],
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

    final subjects = interestMapping[interestArea] ?? [];
    final normalizedSubject = _normalizarNomeMateria(subject);

    return subjects.any((s) => _isSubjectMatch(normalizedSubject, s));
  }

  // ===== INTEGRAÇÃO FIREBASE REAL =====

  static Future<List<QuestionModel>> _getQuestionsFromFirestoreWithCache(
      String schoolLevel) async {
    final cacheKey = 'questions_$schoolLevel';
    final cached = _questionsCache[cacheKey];

    if (cached != null && !cached.isExpired) {
      print(
          '✅ Cache hit para $schoolLevel: ${cached.questions.length} questões');
      return cached.questions;
    }

    try {
      print('🔍 Buscando questões do Firebase para $schoolLevel...');

      final url = '$baseUrl/questions';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>? ?? [];

        final questions = <QuestionModel>[];

        for (final doc in documents) {
          final fields = doc['fields'] as Map<String, dynamic>;
          final questionData =
              _convertFirestoreToQuestionModel(doc['name'], fields);

          if (questionData['schoolLevel'] == schoolLevel) {
            questions.add(QuestionModel.fromMap(questionData));
          }
        }

        _questionsCache[cacheKey] = CacheEntry(questions, DateTime.now());

        print(
            '✅ Firebase: ${questions.length} questões carregadas para $schoolLevel');
        return questions;
      } else {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro Firebase: $e');
      return [];
    }
  }

  static Map<String, dynamic> _convertFirestoreToQuestionModel(
      String docName, Map<String, dynamic> fields) {
    return {
      'id': docName.split('/').last,
      'subject': _getFirestoreStringValue(fields['subject']),
      'schoolLevel': _getFirestoreStringValue(fields['school_level']),
      'difficulty': _getFirestoreStringValue(fields['difficulty']),
      'theme': _getFirestoreStringValue(fields['theme']),
      'enunciado': _getFirestoreStringValue(fields['enunciado']),
      'alternativas': _getFirestoreArrayValue(fields['alternativas']),
      'respostaCorreta': _getFirestoreIntValue(fields['resposta_correta']),
      'explicacao': _getFirestoreStringValue(fields['explicacao']),
      'imagemEspecifica': _getFirestoreStringValue(fields['imagem_especifica']),
      'tags': _getFirestoreArrayValue(fields['tags']),
      'metadata': _getFirestoreMapValue(fields['metadata']),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static String _getFirestoreStringValue(dynamic field) {
    return field?['stringValue'] ?? '';
  }

  static int _getFirestoreIntValue(dynamic field) {
    final value = field?['integerValue'];
    return value != null ? int.tryParse(value.toString()) ?? 0 : 0;
  }

  static List<String> _getFirestoreArrayValue(dynamic field) {
    final values = field?['arrayValue']?['values'] as List<dynamic>? ?? [];
    return values.map((v) => v['stringValue'] ?? '').cast<String>().toList();
  }

  static Map<String, dynamic> _getFirestoreMapValue(dynamic field) {
    return field?['mapValue']?['fields'] as Map<String, dynamic>? ?? {};
  }

  // ===== FALLBACK LOCAL =====

  static Future<List<QuestionModel>> _getQuestionsFromLocalFallback(
      String schoolLevel, int limit) async {
    print('🔄 Usando fallback local para $schoolLevel');

    try {
      final questions =
          QuestionsDatabase.getQuestionsByLevel(schoolLevel, limit: limit);
      return questions;
    } catch (e) {
      print('❌ Erro no fallback local: $e');
      return [];
    }
  }

  // ===== MÉTODOS AUXILIARES EXISTENTES =====

  static Future<UserModel?> getCurrentUser() async {
    try {
      return UserModel(
        id: 'test_user_firebase',
        name: 'Explorador Firebase',
        schoolLevel: 'EM2',
        mainGoal: 'enemPrep',
        interestArea: 'cienciasNatureza',
        dreamUniversity: 'USP',
        studyTime: '30-60 min',
        mainDifficulty: 'fisica',
        behavioralAspect: 'foco_concentracao',
        studyStyle: 'pratico',
        userLevel: 'medio',
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

  static Map<String, dynamic> getPersonalizationStats(
    List<QuestionModel> questions,
    NivelHabilidade? nivelConhecimento,
  ) {
    if (questions.isEmpty) return {};

    final subjectCount = <String, int>{};

    for (final question in questions) {
      subjectCount[question.subject] =
          (subjectCount[question.subject] ?? 0) + 1;
    }

    return {
      'total_questions': questions.length,
      'user_level': nivelConhecimento?.nome ?? 'perfil usuário',
      'subject_distribution': subjectCount,
      'algorithm_version': 'v6.8_materia_problema_final',
      'source': 'firebase_com_algoritmo_materia_problema',
      'correction': '70_percent_problem_subject_30_percent_interest',
      'logic': '70% matéria com dificuldade + 30% área de interesse',
    };
  }

  // Métodos placeholder para compatibilidade
  static Future<String> createUser(Map<String, dynamic> userData) async {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<void> recordUserAnswer({
    required String userId,
    required String questionId,
    required bool wasCorrect,
    required int timeSpent,
    required String selectedAnswer,
    required String difficulty,
    required String subject,
  }) async {
    print('📝 Resposta registrada: $questionId - ${wasCorrect ? "✅" : "❌"}');
  }

  // Métodos para compatibilidade com personalization_provider
  static Future<List<QuestionModel>> getPersonalizedQuestions(
    UserModel user, {
    int limit = 20,
  }) async {
    return getPersonalizedQuestionsFromOnboarding(
      user: user,
      nivelConhecimento: null,
      limit: limit,
    );
  }
}
