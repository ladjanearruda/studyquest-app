// lib/shared/services/firebase_service.dart
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_model.dart';
import '../../core/models/question_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache para questões (performance)
  static final Map<String, List<QuestionModel>> _questionsCache = {};
  static final Map<String, UserModel> _userCache = {};

  // ===== INICIALIZAÇÃO =====

  /// Criar usuário anônimo e salvar dados do onboarding
  static Future<UserModel?> createUserFromOnboarding(
      Map<String, dynamic> onboardingData) async {
    try {
      // Criar usuário anônimo no Firebase Auth
      final userCredential = await _auth.signInAnonymously();
      final userId = userCredential.user?.uid;

      if (userId == null) {
        throw Exception('Falha ao criar usuário anônimo');
      }

      // Converter dados do onboarding para UserModel
      final user = UserModel.fromOnboardingData(userId, onboardingData);

      // Salvar no Firestore
      await _firestore.collection('users').doc(userId).set(user.toFirestore());

      // Cachear usuário
      _userCache[userId] = user;

      print('✅ Usuário criado e salvo: ${user.name}');
      return user;
    } catch (e) {
      print('❌ Erro ao criar usuário: $e');
      return null;
    }
  }

  // ===== USUÁRIOS =====

  /// Buscar usuário atual
  static Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Verificar cache primeiro
      if (_userCache.containsKey(currentUser.uid)) {
        return _userCache[currentUser.uid];
      }

      final doc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!doc.exists) return null;

      final user = UserModel.fromFirestore(doc);
      _userCache[currentUser.uid] = user; // Cachear

      return user;
    } catch (e) {
      print('❌ Erro ao buscar usuário atual: $e');
      return null;
    }
  }

  /// Atualizar stats do usuário (XP, nível, etc.)
  static Future<void> updateUserStats(
    String userId, {
    int? xpGained,
    int? questionsAnswered,
    int? correctAnswers,
    int? studyTimeMinutes,
    bool? streakIncrement,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      Map<String, dynamic> updates = {};

      if (xpGained != null) {
        updates['stats.total_xp'] = FieldValue.increment(xpGained);
        // Calcular novo nível baseado no XP
        final currentUser = await getCurrentUser();
        if (currentUser != null) {
          final newLevel = _calculateLevel(currentUser.totalXp + xpGained);
          updates['stats.current_level'] = newLevel;
        }
      }

      if (questionsAnswered != null) {
        updates['stats.total_questions'] =
            FieldValue.increment(questionsAnswered);
      }

      if (correctAnswers != null) {
        updates['stats.total_correct'] = FieldValue.increment(correctAnswers);
      }

      if (studyTimeMinutes != null) {
        updates['stats.total_study_time'] =
            FieldValue.increment(studyTimeMinutes);
      }

      if (streakIncrement == true) {
        updates['stats.current_streak'] = FieldValue.increment(1);
      }

      updates['profile.last_login'] = Timestamp.now();

      await userDoc.update(updates);

      // Invalidar cache para forçar reload
      _userCache.remove(userId);

      print('✅ Stats do usuário atualizadas');
    } catch (e) {
      print('❌ Erro ao atualizar stats: $e');
      rethrow;
    }
  }

  static int _calculateLevel(int totalXp) {
    // Fórmula: nível = sqrt(totalXp / 100) + 1
    return (math.sqrt(totalXp / 100) + 1).floor();
  }

  // ===== QUESTÕES PERSONALIZADAS =====

  /// Buscar questões personalizadas para o usuário
  static Future<List<QuestionModel>> getPersonalizedQuestions(
    UserModel user, {
    int limit = 10,
    String? specificSubject,
  }) async {
    try {
      // Para Sprint 6 Sessão 1, vamos usar questões locais primeiro
      // Depois implementaremos busca no Firestore
      return _getLocalPersonalizedQuestions(user,
          limit: limit, specificSubject: specificSubject);
    } catch (e) {
      print('❌ Erro ao buscar questões personalizadas: $e');
      return [];
    }
  }

  /// Questões locais personalizadas (Sprint 6 MVP)
  static List<QuestionModel> _getLocalPersonalizedQuestions(
    UserModel user, {
    required int limit,
    String? specificSubject,
  }) {
    // Questões de exemplo tema Floresta baseadas no usuário
    List<QuestionModel> allQuestions =
        _generateSampleQuestions(user.schoolLevel);

    // Aplicar algoritmo de personalização
    return _personalizeQuestions(allQuestions, user, limit);
  }

  /// Gerar questões de exemplo baseadas no nível escolar
  static List<QuestionModel> _generateSampleQuestions(String schoolLevel) {
    // Por agora, vamos gerar algumas questões de exemplo
    // Na Sprint 6 completa, isso virá do banco de dados

    List<QuestionModel> questions = [];

    // Matemática
    questions.add(QuestionModel.createLocal(
      id: 'mat_${schoolLevel}_001',
      subject: 'matematica',
      schoolLevel: schoolLevel,
      difficulty: 'medio',
      enunciado:
          'Na floresta amazônica, você encontra uma árvore de 45 metros de altura. Uma segunda árvore tem 2/3 da altura da primeira. Qual é a altura da segunda árvore?',
      alternativas: ['25 metros', '30 metros', '35 metros', '40 metros'],
      respostaCorreta: 1,
      explicacao: '2/3 de 45 = (2 × 45) ÷ 3 = 90 ÷ 3 = 30 metros.',
      tags: ['fracao', 'multiplicacao', 'divisao'],
      metadata: {
        'tempo_estimado': 120,
        'conceitos': ['fracoes', 'operacoes_basicas']
      },
    ));

    // Português
    questions.add(QuestionModel.createLocal(
      id: 'port_${schoolLevel}_001',
      subject: 'portugues',
      schoolLevel: schoolLevel,
      difficulty: 'facil',
      enunciado:
          'No texto "O Curupira protege a floresta com seus pés virados para trás", qual é o sujeito da oração?',
      alternativas: ['a floresta', 'O Curupira', 'seus pés', 'para trás'],
      respostaCorreta: 1,
      explicacao:
          'O Curupira é quem pratica a ação de proteger, sendo o sujeito da oração.',
      tags: ['sujeito', 'analise_sintatica'],
      metadata: {
        'tempo_estimado': 90,
        'conceitos': ['sintaxe', 'sujeito']
      },
    ));

    // Física (para níveis mais altos)
    if (schoolLevel.contains('medio') || schoolLevel == 'fundamental9') {
      questions.add(QuestionModel.createLocal(
        id: 'fis_${schoolLevel}_001',
        subject: 'fisica',
        schoolLevel: schoolLevel,
        difficulty: 'dificil',
        enunciado:
            'Na floresta, o som viaja a 340 m/s. Se você ouvir o eco de um grito após 2 segundos, qual a distância até o obstáculo que refletiu o som?',
        alternativas: ['340 metros', '680 metros', '170 metros', '510 metros'],
        respostaCorreta: 0,
        explicacao:
            'O som percorre ida e volta em 2s. Distância = (340 × 2) ÷ 2 = 340 metros.',
        tags: ['velocidade', 'som', 'eco'],
        metadata: {
          'tempo_estimado': 180,
          'conceitos': ['velocidade', 'ondas_sonoras']
        },
      ));
    }

    return questions;
  }

  /// ALGORITMO DE PERSONALIZAÇÃO (70% dificuldade + 30% interesse)
  static List<QuestionModel> _personalizeQuestions(
    List<QuestionModel> allQuestions,
    UserModel user,
    int limit,
  ) {
    if (allQuestions.isEmpty) return [];

    List<QuestionModel> selected = [];

    // 1. Filtrar por nível escolar (obrigatório)
    var questoesNivel =
        allQuestions.where((q) => q.schoolLevel == user.schoolLevel).toList();

    if (questoesNivel.isEmpty) {
      // Fallback: usar questões próximas do nível
      questoesNivel = allQuestions;
    }

    // 2. Determinar dificuldade preferida baseada no objetivo (70%)
    String preferredDifficulty = _getPreferredDifficulty(user);
    var questoesDificuldade = questoesNivel
        .where((q) => q.difficulty == preferredDifficulty)
        .toList();

    int questoesDiff = (limit * 0.7).round();
    selected.addAll(_selectRandomly(questoesDificuldade, questoesDiff));

    // 3. Questões das matérias de interesse (30%)
    var questoesInteresse = questoesNivel
        .where((q) => _isSubjectOfInterest(q.subject, user.interestArea))
        .where((q) => !selected.contains(q))
        .toList();

    int questoesInt = limit - selected.length;
    selected.addAll(_selectRandomly(questoesInteresse, questoesInt));

    // 4. Preencher restante se necessário
    if (selected.length < limit) {
      var remaining =
          questoesNivel.where((q) => !selected.contains(q)).toList();
      selected.addAll(_selectRandomly(remaining, limit - selected.length));
    }

    // 5. Embaralhar ordem final
    selected.shuffle();

    return selected.take(limit).toList();
  }

  static String _getPreferredDifficulty(UserModel user) {
    // Lógica baseada no objetivo do onboarding
    switch (user.mainGoal) {
      case 'enemPrep':
      case 'specificUniversity':
        return 'dificil';
      case 'improveGrades':
        return 'medio';
      case 'exploreAreas':
      case 'undecided':
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

  // ===== PROGRESSO DO USUÁRIO =====

  /// Registrar resposta do usuário (para IA e rankings futuros)
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
      final progressId =
          '${userId}_${questionId}_${DateTime.now().millisecondsSinceEpoch}';

      final progressData = {
        'user_id': userId,
        'question_id': questionId,
        'was_correct': wasCorrect,
        'time_spent': timeSpent,
        'answered_at': Timestamp.now(),
        'selected_answer': selectedAnswer,
        'difficulty': difficulty,
        'subject': subject,
      };

      await _firestore
          .collection('user_progress')
          .doc(progressId)
          .set(progressData);

      // Atualizar stats do usuário
      await updateUserStats(
        userId,
        xpGained: wasCorrect ? 10 : 5, // XP por resposta
        questionsAnswered: 1,
        correctAnswers: wasCorrect ? 1 : 0,
        studyTimeMinutes: (timeSpent / 60).round(),
      );

      print('✅ Progresso registrado: ${wasCorrect ? 'Correto' : 'Incorreto'}');
    } catch (e) {
      print('❌ Erro ao registrar progresso: $e');
      // Não fazer throw para não quebrar o fluxo do usuário
    }
  }

  /// Buscar histórico de performance (para IA comportamental)
  static Future<List<Map<String, dynamic>>> getUserPerformanceHistory(
    String userId, {
    String? subject,
    int? limitDays,
  }) async {
    try {
      Query query = _firestore
          .collection('user_progress')
          .where('user_id', isEqualTo: userId)
          .orderBy('answered_at', descending: true);

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }

      if (limitDays != null) {
        final cutoffDate = DateTime.now().subtract(Duration(days: limitDays));
        query = query.where('answered_at',
            isGreaterThan: Timestamp.fromDate(cutoffDate));
      }

      final querySnapshot = await query.limit(100).get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar histórico: $e');
      return [];
    }
  }

  // ===== DIÁRIO (Preparação para Sessão 2) =====

  /// Criar entrada no diário
  static Future<bool> createDiaryEntry({
    required String userId,
    required String questionId,
    required String subject,
    required String content,
    List<String>? tags,
  }) async {
    try {
      final entryId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      final entryData = {
        'user_id': userId,
        'question_id': questionId,
        'subject': subject,
        'content': content,
        'created_at': Timestamp.now(),
        'is_important': false,
        'tags': tags ?? [],
      };

      await _firestore.collection('diary_entries').doc(entryId).set(entryData);

      print('✅ Entrada do diário salva');
      return true;
    } catch (e) {
      print('❌ Erro ao salvar no diário: $e');
      return false;
    }
  }

  /// Buscar entradas do diário do usuário
  static Future<List<Map<String, dynamic>>> getUserDiaryEntries(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('diary_entries')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar entradas do diário: $e');
      return [];
    }
  }

  // ===== UTILIDADES =====

  /// Limpar cache (útil para testes)
  static void clearCache() {
    _questionsCache.clear();
    _userCache.clear();
    print('✅ Cache limpo');
  }

  /// Verificar conexão com Firebase
  static Future<bool> checkConnection() async {
    try {
      await _firestore.collection('_health_check').limit(1).get();
      return true;
    } catch (e) {
      print('❌ Sem conexão com Firebase: $e');
      return false;
    }
  }

  /// Inicializar dados de teste (Sprint 6 MVP)
  static Future<void> initializeTestData() async {
    try {
      print('🔄 Inicializando dados de teste...');

      // Aqui você pode adicionar questões de exemplo no Firestore
      // Por agora, usamos questões locais no _generateSampleQuestions

      print('✅ Dados de teste inicializados');
    } catch (e) {
      print('❌ Erro ao inicializar dados de teste: $e');
    }
  }
}
