// lib/shared/services/firebase_service.dart - V7.1 RETROCOMPATÍVEL
// ✅ Algoritmo Híbrido Inteligente com 5 Layers de Personalização
// ✅ CORREÇÃO CRÍTICA: Código retrocompatível PT/EN implementado

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

  // ===== MÉTODO PRINCIPAL V7.0 - ALGORITMO MULTI-LAYER =====

  static Future<List<QuestionModel>> getPersonalizedQuestionsFromOnboarding({
    required UserModel user,
    NivelHabilidade? nivelConhecimento,
    int limit = 10,
  }) async {
    try {
      print('🎯 INICIANDO ALGORITMO V7.0 MULTI-LAYER');
      print('   Usuário: ${user.name} (${user.schoolLevel})');
      print('   Matéria com dificuldade: ${user.mainDifficulty}');
      print('   Área de interesse: ${user.interestArea}');
      print('   Nível do usuário: ${user.userLevel}');

      // 1. Buscar questões do Firebase (nível exato)
      final allQuestions =
          await _getQuestionsFromFirestoreWithCache(user.schoolLevel);

      if (allQuestions.isEmpty) {
        print('⚠️ Nenhuma questão Firebase. Usando fallback local completo.');
        return await _getQuestionsFromLocalFallback(user.schoolLevel, limit);
      }

      print('✅ Firebase: ${allQuestions.length} questões disponíveis');

      // 2. Aplicar algoritmo Multi-Layer
      final personalizedQuestions = await _multiLayerPersonalization(
        allQuestions,
        user,
        limit,
        nivelConhecimento,
      );

      print(
          '✅ ${personalizedQuestions.length} questões selecionadas (Multi-Layer)');
      return personalizedQuestions;
    } catch (e) {
      print('❌ Erro na personalização: $e');
      return await _getQuestionsFromLocalFallback(user.schoolLevel, limit);
    }
  }

  // ===== ALGORITMO MULTI-LAYER V7.0 =====

  static Future<List<QuestionModel>> _multiLayerPersonalization(
    List<QuestionModel> baseQuestions,
    UserModel user,
    int limit,
    NivelHabilidade? nivelConhecimento,
  ) async {
    print('\n🧠 ALGORITMO MULTI-LAYER V7.0');

    List<QuestionModel> selected = [];
    // Set de IDs para deduplicação O(1) — evita repetir questão
    // mesmo quando objetos vêm de caches diferentes (Layers 3+)
    final Set<String> selectedIds = {};
    final targetDifficulty = user.userLevel;
    final materiaProblematica = _normalizarNomeMateria(user.mainDifficulty);

    // ===== LAYER 1: BUSCA PRIMÁRIA (70/30 IDEAL) =====
    print('\n📍 LAYER 1 - Busca Primária (70% matéria + 30% interesse)');

    // 70% matéria com dificuldade
    var questoesMateria = baseQuestions
        .where((q) => _isSubjectMatch(q.subject, materiaProblematica))
        .where((q) => q.difficulty == targetDifficulty)
        .toList();

    if (questoesMateria.isEmpty) {
      // Aceitar outras dificuldades da mesma matéria
      questoesMateria = baseQuestions
          .where((q) => _isSubjectMatch(q.subject, materiaProblematica))
          .toList();
    }

    int seventyPercent = (limit * 0.7).round();
    questoesMateria.shuffle();
    final materiaChosen = questoesMateria.take(seventyPercent).toList();
    selected.addAll(materiaChosen);
    selectedIds.addAll(materiaChosen.map((q) => q.id));

    print(
        '   ✅ Matéria (${materiaProblematica}): ${selected.length}/$seventyPercent');

    // 30% área de interesse
    var questoesInteresse = baseQuestions
        .where((q) => _isSubjectOfInterest(q.subject, user.interestArea))
        .where((q) => q.difficulty == targetDifficulty)
        .where((q) => !selectedIds.contains(q.id))
        .toList();

    if (questoesInteresse.isEmpty) {
      questoesInteresse = baseQuestions
          .where((q) => _isSubjectOfInterest(q.subject, user.interestArea))
          .where((q) => !selectedIds.contains(q.id))
          .toList();
    }

    int thirtyPercent = (limit * 0.3).round();
    questoesInteresse.shuffle();
    final interesseChosen = questoesInteresse.take(thirtyPercent).toList();
    selected.addAll(interesseChosen);
    selectedIds.addAll(interesseChosen.map((q) => q.id));

    print(
        '   ✅ Interesse: ${selected.length}/${seventyPercent + thirtyPercent}');

    // ===== LAYER 2: EXPANSÃO INTELIGENTE (Cross-Subject) =====
    if (selected.length < limit) {
      print('\n📍 LAYER 2 - Expansão Inteligente (matérias relacionadas)');

      final needed = limit - selected.length;
      var related = baseQuestions
          .where((q) => !selectedIds.contains(q.id))
          .where((q) => _isRelatedSubject(
              q.subject, materiaProblematica, user.interestArea))
          .toList();

      related.shuffle();
      final relatedChosen = related.take(needed).toList();
      selected.addAll(relatedChosen);
      selectedIds.addAll(relatedChosen.map((q) => q.id));

      print('   ✅ Relacionadas: +${related.take(needed).length} questões');
    }

    // ===== LAYER 3: POOL EXPANDIDO (Níveis Adjacentes) =====
    if (selected.length < limit) {
      print('\n📍 LAYER 3 - Pool Expandido (níveis ±1)');

      final adjacentLevels = _getAdjacentLevels(user.schoolLevel);
      List<QuestionModel> expandedPool = [];

      for (final level in adjacentLevels) {
        final adjacentQuestions =
            await _getQuestionsFromFirestoreWithCache(level);
        expandedPool.addAll(adjacentQuestions);
      }

      print('   📦 Pool expandido: +${expandedPool.length} questões');

      if (expandedPool.isNotEmpty) {
        final needed = limit - selected.length;

        // Priorizar mesma matéria e dificuldade
        var priorityQuestions = expandedPool
            .where((q) => !selectedIds.contains(q.id))
            .where((q) =>
                _isSubjectMatch(q.subject, materiaProblematica) ||
                _isSubjectOfInterest(q.subject, user.interestArea))
            .where((q) => q.difficulty == targetDifficulty)
            .toList();

        if (priorityQuestions.isEmpty) {
          // Aceitar qualquer matéria relevante
          priorityQuestions =
              expandedPool.where((q) => !selectedIds.contains(q.id)).toList();
        }

        priorityQuestions.shuffle();
        final layer3Chosen = priorityQuestions.take(needed).toList();
        selected.addAll(layer3Chosen);
        selectedIds.addAll(layer3Chosen.map((q) => q.id));

        print(
            '   ✅ Níveis adjacentes: +${priorityQuestions.take(needed).length} questões');
      }
    }

    // ===== LAYER 4: ADAPTAÇÃO PROPORCIONAL (Qualquer Firebase) =====
    if (selected.length < limit) {
      print('\n📍 LAYER 4 - Adaptação Proporcional (maximize Firebase)');

      final needed = limit - selected.length;
      var remaining =
          baseQuestions.where((q) => !selectedIds.contains(q.id)).toList();

      remaining.shuffle();
      final layer4Chosen = remaining.take(needed).toList();
      selected.addAll(layer4Chosen);
      selectedIds.addAll(layer4Chosen.map((q) => q.id));

      print(
          '   ✅ Outras matérias Firebase: +${remaining.take(needed).length} questões');
    }

    // ===== LAYER 5: FALLBACK LOCAL (Último Recurso) =====
    if (selected.length < limit) {
      print('\n📍 LAYER 5 - Fallback Local (último recurso)');

      final needed = limit - selected.length;
      final fallbackQuestions = await _getQuestionsFromLocalFallback(
        user.schoolLevel,
        needed,
      );

      // Evitar duplicatas
      final fallbackFiltered = fallbackQuestions
          .where((q) => !selectedIds.contains(q.id))
          .toList();

      selected.addAll(fallbackFiltered);

      print('   ✅ Fallback local: +${fallbackFiltered.length} questões');
    }

    // Embaralhar resultado final
    selected.shuffle();

    // ===== ESTATÍSTICAS FINAIS =====
    print('\n📊 ESTATÍSTICAS FINAIS:');
    print('   Total selecionado: ${selected.length}/$limit');

    final distribuicao = <String, int>{};
    final porMateria = <String, int>{};

    for (final q in selected) {
      distribuicao[q.difficulty] = (distribuicao[q.difficulty] ?? 0) + 1;
      porMateria[q.subject] = (porMateria[q.subject] ?? 0) + 1;
    }

    print('   Por dificuldade: $distribuicao');
    print('   Por matéria: $porMateria');

    return selected.take(limit).toList();
  }

  // ===== MÉTODOS AUXILIARES MULTI-LAYER =====

  /// Verifica se matéria é relacionada (mesma área de conhecimento)
  static bool _isRelatedSubject(
      String subject, String mainSubject, String interestArea) {
    final subjectNorm = _normalizarNomeMateria(subject);
    final mainNorm = _normalizarNomeMateria(mainSubject);

    // Já é a matéria principal ou de interesse
    if (subjectNorm == mainNorm) return false;
    if (_isSubjectOfInterest(subject, interestArea)) return false;

    // Matérias relacionadas por área
    const Map<String, List<String>> relatedAreas = {
      'cienciasNatureza': [
        'matematica',
        'fisica',
        'quimica',
        'biologia',
        'ciencias'
      ],
      'matematicaTecnologia': ['matematica', 'fisica', 'informatica'],
      'linguagens': ['portugues', 'ingles', 'literatura', 'redacao'],
      'humanas': ['historia', 'geografia', 'filosofia', 'sociologia'],
    };

    for (final area in relatedAreas.entries) {
      if (area.value.contains(mainNorm) && area.value.contains(subjectNorm)) {
        return true;
      }
    }

    return false;
  }

  /// Retorna níveis escolares adjacentes (±1)
  static List<String> _getAdjacentLevels(String currentLevel) {
    const levelSequence = [
      'fundamental6',
      '6ano',
      'fundamental7',
      '7ano',
      'fundamental8',
      '8ano',
      'fundamental9',
      '9ano',
      'medio1',
      'EM1',
      'medio2',
      'EM2',
      'medio3',
      'EM3',
    ];

    final currentIndex = levelSequence.indexOf(currentLevel);
    if (currentIndex == -1) return [];

    List<String> adjacent = [];

    // Nível anterior
    if (currentIndex > 0) {
      adjacent.add(levelSequence[currentIndex - 1]);
    }

    // Nível seguinte
    if (currentIndex < levelSequence.length - 1) {
      adjacent.add(levelSequence[currentIndex + 1]);
    }

    return adjacent;
  }

  // ===== MÉTODOS AUXILIARES EXISTENTES (mantidos) =====

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

  static bool _isSubjectMatch(String questionSubject, String targetSubject) {
    final questionNorm = _normalizarNomeMateria(questionSubject);
    final targetNorm = _normalizarNomeMateria(targetSubject);

    if (questionNorm == targetNorm) return true;

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

  // ===== INTEGRAÇÃO FIREBASE (mantida) =====

  static Future<List<QuestionModel>> _getQuestionsFromFirestoreWithCache(
      String schoolLevel) async {
    final cacheKey = 'questions_$schoolLevel';
    final cached = _questionsCache[cacheKey];

    if (cached != null && !cached.isExpired) {
      return cached.questions;
    }

    try {
      // Filtro no servidor via runQuery: só traz questões do schoolLevel do
      // usuário. Paginação de 200 docs por request — sem limite silencioso.
      final questions = <QuestionModel>[];
      const pageSize = 200;
      int offset = 0;
      bool hasMore = true;

      while (hasMore) {
        final response = await http.post(
          Uri.parse('$baseUrl:runQuery'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'structuredQuery': {
              'from': [
                {'collectionId': 'questions'}
              ],
              'where': {
                'fieldFilter': {
                  'field': {'fieldPath': 'school_level'},
                  'op': 'EQUAL',
                  'value': {'stringValue': schoolLevel},
                },
              },
              'limit': pageSize,
              'offset': offset,
            },
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Erro HTTP: ${response.statusCode}');
        }

        final data = jsonDecode(response.body) as List<dynamic>;
        int docsInPage = 0;

        for (final item in data) {
          if (item['document'] == null) continue;
          final doc = item['document'] as Map<String, dynamic>;
          final fields = doc['fields'] as Map<String, dynamic>;
          final questionData =
              _convertFirestoreToQuestionModel(doc['name'], fields);
          questions.add(QuestionModel.fromMap(questionData));
          docsInPage++;
        }

        // Se retornou menos que pageSize, não há mais páginas
        hasMore = docsInPage == pageSize;
        offset += docsInPage;
      }

      _questionsCache[cacheKey] = CacheEntry(questions, DateTime.now());
      return questions;
    } catch (e) {
      print('   ❌ Erro Firebase: $e');
      return [];
    }
  }

  // ===== ✅ CONVERSÃO FIREBASE → MODEL (RETROCOMPATÍVEL V7.1) =====
  static Map<String, dynamic> _convertFirestoreToQuestionModel(
      String docName, Map<String, dynamic> fields) {
    return {
      'id': docName.split('/').last,
      'subject': _getFirestoreStringValue(fields['subject']),
      'schoolLevel': _getFirestoreStringValue(fields['school_level']),
      'difficulty': _getFirestoreStringValue(fields['difficulty']),
      'theme': _getFirestoreStringValue(fields['theme']),

      // ✅ RETROCOMPATÍVEL PT/EN:
      'enunciado': _getFirestoreStringValueWithFallback(
          fields, ['enunciado', 'question']),
      'alternativas': _getFirestoreArrayValueWithFallback(
          fields, ['alternativas', 'options']),
      'respostaCorreta': _getFirestoreIntValueWithFallback(
          fields, ['resposta_correta', 'correct_answer']),

      'explicacao': _getFirestoreStringValue(fields['explicacao']),
      // imagem_url é o campo principal nas questões ENEM; imagem_especifica é legado
      'imagemEspecifica': _getFirestoreStringValueWithFallback(
          fields, ['imagem_url', 'imagem_especifica']),
      'tags': _getFirestoreArrayValue(fields['tags']),
      'metadata': _getFirestoreMapValue(fields['metadata']),
      'createdAt': DateTime.now().toIso8601String(),

      // Campos opcionais — questões ENEM/vestibular
      'vestibular': fields['vestibular']?['stringValue'],
      'fonte': fields['fonte']?['stringValue'],
      'fonteAdaptada': fields['fonte_adaptada']?['booleanValue'] ?? false,

      // Campos opcionais — alternativas com imagem
      'alternativasTipo': fields['alternativas_tipo']?['stringValue'],
      'alternativasImagens': fields['alternativas_imagens']?['arrayValue']
                  ?['values'] != null
              ? (fields['alternativas_imagens']['arrayValue']['values']
                      as List<dynamic>)
                  .map((v) => v['stringValue'] as String? ?? '')
                  .toList()
              : null,
    };
  }

  // ===== HELPERS BÁSICOS (mantidos) =====

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

  // ===== ✅ HELPERS RETROCOMPATÍVEIS (NOVOS V7.1) =====

  /// Busca string com fallback para múltiplos campos
  /// Aceita nomenclatura PT e EN
  static String _getFirestoreStringValueWithFallback(
      Map<String, dynamic> fields, List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      final value = _getFirestoreStringValue(fields[fieldName]);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  /// Busca array com fallback para múltiplos campos
  /// Aceita nomenclatura PT e EN
  static List<String> _getFirestoreArrayValueWithFallback(
      Map<String, dynamic> fields, List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      final value = _getFirestoreArrayValue(fields[fieldName]);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return [];
  }

  /// Busca int com fallback para múltiplos campos
  /// Aceita nomenclatura PT e EN
  static int _getFirestoreIntValueWithFallback(
      Map<String, dynamic> fields, List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      final field = fields[fieldName];
      if (field != null) {
        final value = _getFirestoreIntValue(field);
        return value;
      }
    }
    return 0;
  }

  // ===== FALLBACK LOCAL =====

  static Future<List<QuestionModel>> _getQuestionsFromLocalFallback(
      String schoolLevel, int limit) async {
    print('   🔄 Fallback local: $schoolLevel ($limit questões)');

    try {
      final questions =
          QuestionsDatabase.getQuestionsByLevel(schoolLevel, limit: limit);
      return questions;
    } catch (e) {
      print('   ❌ Erro fallback: $e');
      return [];
    }
  }

  // ===== MÉTODOS AUXILIARES EXISTENTES (mantidos) =====

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
    final difficultyCount = <String, int>{};

    for (final question in questions) {
      subjectCount[question.subject] =
          (subjectCount[question.subject] ?? 0) + 1;
      difficultyCount[question.difficulty] =
          (difficultyCount[question.difficulty] ?? 0) + 1;
    }

    return {
      'total_questions': questions.length,
      'user_level': nivelConhecimento?.nome ?? 'perfil usuário',
      'subject_distribution': subjectCount,
      'difficulty_distribution': difficultyCount,
      'algorithm_version': 'v7.1_multi_layer_retrocompativel',
      'source': 'firebase_multi_layer_intelligent',
      'logic': '5 layers: primária → expansão → pool → adaptação → fallback',
      'compatibility': 'PT + EN nomenclature supported',
    };
  }

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
