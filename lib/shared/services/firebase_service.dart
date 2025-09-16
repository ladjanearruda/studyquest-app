// lib/shared/services/firebase_service.dart - CONECTADO AO FIRESTORE REAL
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/models/user_model.dart';
import '../../core/models/question_model.dart';
import '../../core/data/questions_database.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

class FirebaseService {
  // Configuração Firestore REST API
  static const String _projectId = 'studyquest-app-banco';
  static const String _baseUrl = 'https://firestore.googleapis.com/v1';
  static const String _collectionPath =
      'projects/$_projectId/databases/(default)/documents/questions';

  // Cache para performance (1 hora)
  static final Map<String, CacheEntry> _questionsCache = {};
  static final Map<String, UserModel> _userCache = {};

  // ===== MÉTODO PRINCIPAL ATUALIZADO - CONECTA FIRESTORE REAL =====

  static Future<List<QuestionModel>> getPersonalizedQuestions(
    UserModel user, {
    int limit = 10,
    String? specificSubject,
    NivelHabilidade? nivelConhecimento,
  }) async {
    try {
      print('🎯 Buscando questões personalizadas para ${user.name}...');
      print(
          '   Série: ${user.schoolLevel} | Objetivo: ${user.mainGoal} | Interesse: ${user.interestArea}');

      if (nivelConhecimento != null) {
        print('   Nível conhecimento: ${nivelConhecimento.nome}');
      }

      // 1. TENTAR FIREBASE PRIMEIRO
      List<QuestionModel> firebaseQuestions = [];
      try {
        firebaseQuestions =
            await _getQuestionsFromFirestore(user.schoolLevel, limit * 2);
        print('✅ ${firebaseQuestions.length} questões carregadas do Firebase');
      } catch (e) {
        print('⚠️ Erro Firebase: $e - usando fallback local');
      }

      // 2. FALLBACK PARA QUESTÕES LOCAIS SE NECESSÁRIO
      List<QuestionModel> allQuestions = firebaseQuestions;
      if (allQuestions.isEmpty) {
        print('🔄 Usando questões locais como fallback...');
        allQuestions = QuestionsDatabase.getQuestionsByLevel(user.schoolLevel,
            limit: limit * 2);
        print('✅ ${allQuestions.length} questões locais carregadas');
      }

      if (allQuestions.isEmpty) {
        print('❌ Nenhuma questão encontrada para nível ${user.schoolLevel}');
        return [];
      }

      // 3. APLICAR ALGORITMO DE PERSONALIZAÇÃO
      final personalizedQuestions = _personalizeQuestionsComNivel(
        allQuestions,
        user,
        limit,
        nivelConhecimento,
      );

      print(
          '🎯 ${personalizedQuestions.length} questões personalizadas selecionadas');
      return personalizedQuestions;
    } catch (e) {
      print('❌ Erro crítico ao buscar questões: $e');
      // Fallback final - questões locais
      final localQuestions =
          QuestionsDatabase.getQuestionsByLevel(user.schoolLevel, limit: limit);
      return localQuestions.take(limit).toList();
    }
  }

  // ===== NOVO MÉTODO - BUSCAR QUESTÕES DO FIRESTORE =====

  static Future<List<QuestionModel>> _getQuestionsFromFirestore(
      String schoolLevel, int limit) async {
    final cacheKey = '${schoolLevel}_$limit';

    // Verificar cache primeiro
    if (_questionsCache.containsKey(cacheKey)) {
      final cached = _questionsCache[cacheKey]!;
      if (!cached.isExpired()) {
        print('🔄 Usando questões em cache para $schoolLevel');
        return cached.questions;
      }
    }

    print('🔍 Buscando questões do Firestore para nível: $schoolLevel');

    try {
      // Construir URL da query Firestore
      final url = Uri.parse('$_baseUrl/$_collectionPath');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body);

      if (data['documents'] == null) {
        print('⚠️ Nenhum documento encontrado na collection questions');
        return [];
      }

      final documents = data['documents'] as List;
      print('📊 ${documents.length} documentos encontrados no Firestore');

      // Converter documentos Firestore para QuestionModel
      final questions = <QuestionModel>[];

      for (final doc in documents) {
        try {
          final fields = doc['fields'] as Map<String, dynamic>;
          final docId = (doc['name'] as String).split('/').last;

          // Extrair school_level do documento
          final docSchoolLevel = _extractFirestoreValue(fields['school_level']);

          // Filtrar por nível escolar
          if (docSchoolLevel == schoolLevel) {
            final question = _convertFirestoreToQuestionModel(docId, fields);
            questions.add(question);
          }
        } catch (e) {
          print('⚠️ Erro ao converter documento ${doc['name']}: $e');
          continue;
        }
      }

      print(
          '✅ ${questions.length} questões válidas encontradas para $schoolLevel');

      // Cachear resultado por 1 hora
      _questionsCache[cacheKey] = CacheEntry(questions);

      return questions;
    } catch (e) {
      print('❌ Erro ao buscar questões do Firestore: $e');
      rethrow;
    }
  }

  // ===== CONVERTER DOCUMENTO FIRESTORE PARA QUESTIONMODEL =====

  static QuestionModel _convertFirestoreToQuestionModel(
      String docId, Map<String, dynamic> fields) {
    return QuestionModel.createLocal(
      id: docId,
      subject: _extractFirestoreValue(fields['subject']) ?? 'matematica',
      schoolLevel: _extractFirestoreValue(fields['school_level']) ?? '8ano',
      difficulty: _extractFirestoreValue(fields['difficulty']) ?? 'medio',
      enunciado: _extractFirestoreValue(fields['enunciado']) ??
          'Questão sem enunciado',
      alternativas: _extractFirestoreArray(fields['alternativas']) ??
          ['A', 'B', 'C', 'D'],
      respostaCorreta: _extractFirestoreInt(fields['resposta_correta']) ?? 0,
      explicacao: _extractFirestoreValue(fields['explicacao']) ??
          'Sem explicação disponível',
      aventuraContexto: _extractFirestoreValue(fields['aventura_contexto']) ??
          'contexto_geral',
      personagemSituacao:
          _extractFirestoreValue(fields['personagem_situacao']) ?? 'explorador',
      localFloresta:
          _extractFirestoreValue(fields['local_floresta']) ?? 'floresta',
      aspectoComportamental:
          _extractFirestoreValue(fields['aspecto_comportamental']) ?? 'foco',
      estiloAprendizado:
          _extractFirestoreValue(fields['estilo_aprendizado']) ?? 'visual',
      imagemEspecifica: _extractFirestoreValue(fields['imagem_especifica']),
      tags: _extractFirestoreArray(fields['tags']) ?? [],
      metadata: _extractFirestoreMap(fields['metadata']) ?? {},
    );
  }

  // ===== HELPERS PARA EXTRAIR VALORES FIRESTORE =====

  static String? _extractFirestoreValue(Map<String, dynamic>? field) {
    if (field == null) return null;
    return field['stringValue'] as String?;
  }

  static List<String> _extractFirestoreArray(Map<String, dynamic>? field) {
    if (field == null) return [];
    final arrayValue = field['arrayValue'];
    if (arrayValue == null || arrayValue['values'] == null) return [];

    final values = arrayValue['values'] as List;
    return values
        .map((v) => v['stringValue'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static int _extractFirestoreInt(Map<String, dynamic>? field) {
    if (field == null) return 0;

    if (field.containsKey('integerValue')) {
      return int.tryParse(field['integerValue'].toString()) ?? 0;
    }

    if (field.containsKey('stringValue')) {
      return int.tryParse(field['stringValue'] as String) ?? 0;
    }

    return 0;
  }

  static Map<String, dynamic> _extractFirestoreMap(
      Map<String, dynamic>? field) {
    if (field == null) return {};
    final mapValue = field['mapValue'];
    if (mapValue == null || mapValue['fields'] == null) return {};

    final fields = mapValue['fields'] as Map<String, dynamic>;
    final result = <String, dynamic>{};

    fields.forEach((key, value) {
      if (value['stringValue'] != null) {
        result[key] = value['stringValue'];
      } else if (value['integerValue'] != null) {
        result[key] = int.tryParse(value['integerValue'].toString()) ?? 0;
      }
    });

    return result;
  }

  // ===== ALGORITMO PERSONALIZAÇÃO MANTIDO =====

  static List<QuestionModel> _personalizeQuestionsComNivel(
    List<QuestionModel> allQuestions,
    UserModel user,
    int limit,
    NivelHabilidade? nivelConhecimento,
  ) {
    if (allQuestions.isEmpty) return [];

    List<QuestionModel> selected = [];

    // Dificuldade inteligente baseada em objetivo + nível
    String preferredDifficulty =
        _getPreferredDifficultyComNivel(user, nivelConhecimento);
    print('🎯 Dificuldade selecionada: $preferredDifficulty');

    // 70% - Questões baseadas na dificuldade
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

    // Completar com questões apropriadas para o nível
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

  // ===== MÉTODOS AUXILIARES MANTIDOS =====

  static String _getPreferredDifficultyComNivel(
      UserModel user, NivelHabilidade? nivelConhecimento) {
    if (nivelConhecimento == null) {
      return _getPreferredDifficultyLegacy(user);
    }

    switch (nivelConhecimento) {
      case NivelHabilidade.iniciante:
        return 'facil';
      case NivelHabilidade.intermediario:
        switch (user.mainGoal) {
          case 'enemPrep':
          case 'specificUniversity':
            return 'medio';
          default:
            return 'facil';
        }
      case NivelHabilidade.avancado:
        switch (user.mainGoal) {
          case 'enemPrep':
          case 'specificUniversity':
            return 'dificil';
          default:
            return 'medio';
        }
    }
  }

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

  static bool _isDifficultyAppropriate(
      String difficulty, NivelHabilidade? nivelConhecimento) {
    if (nivelConhecimento == null) return true;

    switch (nivelConhecimento) {
      case NivelHabilidade.iniciante:
        return difficulty == 'facil' || difficulty == 'medio';
      case NivelHabilidade.intermediario:
        return true;
      case NivelHabilidade.avancado:
        return difficulty == 'medio' || difficulty == 'dificil';
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

  // ===== MÉTODO DE INTEGRAÇÃO COM ONBOARDING =====

  static Future<List<QuestionModel>> getPersonalizedQuestionsFromOnboarding({
    required UserModel user,
    required NivelHabilidade? nivelConhecimento,
    int limit = 10,
    String? specificSubject,
  }) async {
    print('🎯 Personalizando questões com dados do onboarding...');
    print('   Usuário: ${user.name} | Série: ${user.schoolLevel}');
    print('   Objetivo: ${user.mainGoal} | Interesse: ${user.interestArea}');
    print(
        '   Nível conhecimento: ${nivelConhecimento?.nome ?? "não definido"}');

    return await getPersonalizedQuestions(
      user,
      limit: limit,
      specificSubject: specificSubject,
      nivelConhecimento: nivelConhecimento,
    );
  }

  // ===== ESTATÍSTICAS E MÉTODOS DE UTILIDADE =====

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
      'algorithm_version': 'v6.5_firebase_real',
      'source': 'firebase_with_local_fallback',
    };
  }

  static Map<String, dynamic> getQuestionsStats() {
    return QuestionsDatabase.getStats();
  }

  static bool validateQuestions() {
    return QuestionsDatabase.validateAllQuestions();
  }

  // ===== USUÁRIO MOCK PARA TESTES =====

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

  // ===== MÉTODO DE TESTE ATUALIZADO =====

  static Future<void> testSystemComNivel({NivelHabilidade? nivelTeste}) async {
    print('🧪 Testando sistema Firebase com Firestore real...');

    final user = await getCurrentUser();
    if (user != null) {
      try {
        final questions = await getPersonalizedQuestionsFromOnboarding(
          user: user,
          nivelConhecimento: nivelTeste ?? NivelHabilidade.intermediario,
          limit: 5,
        );

        print('🎯 Questões obtidas: ${questions.length}');

        final stats = getPersonalizationStats(questions, nivelTeste);
        print('📊 Stats personalização: $stats');

        for (var q in questions.take(2)) {
          print(
              '• ${q.subject} (${q.difficulty}): ${q.enunciado.length > 50 ? q.enunciado.substring(0, 50) + "..." : q.enunciado}');
        }
      } catch (e) {
        print('❌ Erro no teste: $e');
      }
    }

    print('✅ Teste concluído!');
  }

  static Future<void> testSystem() async {
    await testSystemComNivel();
  }

  // ===== MÉTODO PARA COMPATIBILIDADE COM PERSONALIZATION_PROVIDER =====

  /// Registrar resposta do usuário (compatibilidade)
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
      // Log da resposta para debug
      print(
          '📝 Resposta registrada: $questionId -> ${wasCorrect ? "Correto" : "Incorreto"}');
      print('   Usuário: $userId | Tempo: ${timeSpent}s | Matéria: $subject');

      // TODO: Implementar salvamento real no Firestore quando necessário
      // Por enquanto, apenas logging para não quebrar o fluxo

      // Estrutura futura para salvamento:
      // await _saveUserResponse({
      //   'user_id': userId,
      //   'question_id': questionId,
      //   'was_correct': wasCorrect,
      //   'time_spent': timeSpent,
      //   'selected_answer': selectedAnswer,
      //   'difficulty': difficulty,
      //   'subject': subject,
      //   'timestamp': DateTime.now().toIso8601String(),
      // });
    } catch (e) {
      print('⚠️ Erro ao registrar resposta (não crítico): $e');
      // Não fazer throw para não quebrar o fluxo do app
    }
  }
}

// ===== CLASSE PARA CACHE =====

class CacheEntry {
  final List<QuestionModel> questions;
  final DateTime timestamp;

  CacheEntry(this.questions) : timestamp = DateTime.now();

  bool isExpired() {
    return DateTime.now().difference(timestamp).inHours >= 1;
  }
}
