// lib/core/services/firebase_diary_service.dart
// ✅ V9.2 - Sprint 9 Fase 2: Serviço Firebase para Diário
// 📅 Criado: 22/02/2026
// 🎯 Persiste respostas e anotações no Firestore

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/diario/models/diary_entry_model.dart';

class FirebaseDiaryService {
  static const String _baseUrl =
      'https://firestore.googleapis.com/v1/projects/studyquest-app-banco/databases/(default)/documents';

  // ========================================
  // 📝 USER RESPONSES (Histórico de Respostas)
  // ========================================

  /// Salvar resposta do usuário no Firebase
  static Future<bool> saveUserResponse({
    required String userId,
    required String questionId,
    required bool wasCorrect,
    required int selectedAnswer,
    required int timeSpent,
    required String subject,
    required String difficulty,
  }) async {
    try {
      final docId =
          '${userId}_${questionId}_${DateTime.now().millisecondsSinceEpoch}';
      final url = '$_baseUrl/user_responses/$docId';

      final body = {
        'fields': {
          'user_id': {'stringValue': userId},
          'question_id': {'stringValue': questionId},
          'was_correct': {'booleanValue': wasCorrect},
          'selected_answer': {'integerValue': selectedAnswer.toString()},
          'time_spent': {'integerValue': timeSpent.toString()},
          'subject': {'stringValue': subject},
          'difficulty': {'stringValue': difficulty},
          'answered_at': {
            'timestampValue': DateTime.now().toUtc().toIso8601String()
          },
        }
      };

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Resposta salva: $questionId (${wasCorrect ? "✓" : "✗"})');
        return true;
      } else {
        print('❌ Erro ao salvar resposta: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exceção ao salvar resposta: $e');
      return false;
    }
  }

  /// Buscar histórico de respostas do usuário
  static Future<List<Map<String, dynamic>>> getUserResponses(
      String userId) async {
    try {
      // Query estruturada para filtrar por user_id
      final url = '$_baseUrl:runQuery';

      final body = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'user_responses'}
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': 'user_id'},
              'op': 'EQUAL',
              'value': {'stringValue': userId}
            }
          },
          'orderBy': [
            {
              'field': {'fieldPath': 'answered_at'},
              'direction': 'DESCENDING'
            }
          ],
          'limit': 500
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final responses = <Map<String, dynamic>>[];

        for (final item in data) {
          if (item['document'] != null) {
            final fields = item['document']['fields'] as Map<String, dynamic>;
            responses.add(_parseResponseFields(fields));
          }
        }

        print('📊 ${responses.length} respostas carregadas para $userId');
        return responses;
      }

      return [];
    } catch (e) {
      print('❌ Erro ao buscar respostas: $e');
      return [];
    }
  }

  /// Verificar se usuário já respondeu uma questão (e se errou)
  static Future<Map<String, dynamic>?> getQuestionHistory({
    required String userId,
    required String questionId,
  }) async {
    try {
      final url = '$_baseUrl:runQuery';

      final body = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'user_responses'}
          ],
          'where': {
            'compositeFilter': {
              'op': 'AND',
              'filters': [
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'user_id'},
                    'op': 'EQUAL',
                    'value': {'stringValue': userId}
                  }
                },
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'question_id'},
                    'op': 'EQUAL',
                    'value': {'stringValue': questionId}
                  }
                }
              ]
            }
          },
          'orderBy': [
            {
              'field': {'fieldPath': 'answered_at'},
              'direction': 'DESCENDING'
            }
          ],
          'limit': 1
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty && data[0]['document'] != null) {
          final fields = data[0]['document']['fields'] as Map<String, dynamic>;
          return _parseResponseFields(fields);
        }
      }

      return null;
    } catch (e) {
      print('❌ Erro ao verificar histórico: $e');
      return null;
    }
  }

  // ========================================
  // 📒 DIARY ENTRIES (Anotações do Diário)
  // ========================================

  /// Salvar anotação no Diário
  static Future<String?> saveDiaryEntry({
    required String userId,
    required String questionId,
    required String questionText,
    required String correctAnswer,
    required String userAnswer,
    required String userNote,
    required String userStrategy,
    required int difficultyRating,
    required String emotion,
    required String subject,
  }) async {
    try {
      final docId =
          '${userId}_${questionId}_${DateTime.now().millisecondsSinceEpoch}';
      final url = '$_baseUrl/diary_entries/$docId';

      final nextReview = DateTime.now().add(const Duration(days: 1));

      final body = {
        'fields': {
          'user_id': {'stringValue': userId},
          'question_id': {'stringValue': questionId},
          'question_text': {'stringValue': questionText},
          'correct_answer': {'stringValue': correctAnswer},
          'user_answer': {'stringValue': userAnswer},
          'user_note': {'stringValue': userNote},
          'user_strategy': {'stringValue': userStrategy},
          'difficulty_rating': {'integerValue': difficultyRating.toString()},
          'emotion': {'stringValue': emotion},
          'subject': {'stringValue': subject},
          'created_at': {
            'timestampValue': DateTime.now().toUtc().toIso8601String()
          },
          'next_review_date': {
            'timestampValue': nextReview.toUtc().toIso8601String()
          },
          'times_reviewed': {'integerValue': '0'},
          'mastered': {'booleanValue': false},
          'xp_earned': {'integerValue': '25'},
        }
      };

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Anotação salva: $docId');
        return docId;
      } else {
        print('❌ Erro ao salvar anotação: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exceção ao salvar anotação: $e');
      return null;
    }
  }

  /// Buscar todas as anotações do usuário
  static Future<List<DiaryEntry>> getUserDiaryEntries(String userId) async {
    try {
      final url = '$_baseUrl:runQuery';

      final body = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'diary_entries'}
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': 'user_id'},
              'op': 'EQUAL',
              'value': {'stringValue': userId}
            }
          },
          'orderBy': [
            {
              'field': {'fieldPath': 'created_at'},
              'direction': 'DESCENDING'
            }
          ],
          'limit': 200
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final entries = <DiaryEntry>[];

        for (final item in data) {
          if (item['document'] != null) {
            final docName = item['document']['name'] as String;
            final docId = docName.split('/').last;
            final fields = item['document']['fields'] as Map<String, dynamic>;
            entries.add(_parseDiaryEntry(docId, fields));
          }
        }

        print('📒 ${entries.length} anotações carregadas para $userId');
        return entries;
      }

      return [];
    } catch (e) {
      print('❌ Erro ao buscar anotações: $e');
      return [];
    }
  }

  /// Verificar se existe anotação para uma questão (não mastered = revanche!)
  static Future<DiaryEntry?> getAnnotationForQuestion({
    required String userId,
    required String questionId,
  }) async {
    try {
      final url = '$_baseUrl:runQuery';

      final body = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'diary_entries'}
          ],
          'where': {
            'compositeFilter': {
              'op': 'AND',
              'filters': [
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'user_id'},
                    'op': 'EQUAL',
                    'value': {'stringValue': userId}
                  }
                },
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'question_id'},
                    'op': 'EQUAL',
                    'value': {'stringValue': questionId}
                  }
                },
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'mastered'},
                    'op': 'EQUAL',
                    'value': {'booleanValue': false}
                  }
                }
              ]
            }
          },
          'limit': 1
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty && data[0]['document'] != null) {
          final docName = data[0]['document']['name'] as String;
          final docId = docName.split('/').last;
          final fields = data[0]['document']['fields'] as Map<String, dynamic>;
          print('🔄 REVANCHE detectada para questão: $questionId');
          return _parseDiaryEntry(docId, fields);
        }
      }

      return null;
    } catch (e) {
      print('❌ Erro ao verificar revanche: $e');
      return null;
    }
  }

  /// Marcar anotação como dominada (mastered)
  static Future<bool> markAsMastered(String entryId) async {
    try {
      final url =
          '$_baseUrl/diary_entries/$entryId?updateMask.fieldPaths=mastered&updateMask.fieldPaths=times_reviewed';

      // Primeiro, buscar o documento atual para pegar times_reviewed
      final getResponse =
          await http.get(Uri.parse('$_baseUrl/diary_entries/$entryId'));

      int currentReviews = 0;
      if (getResponse.statusCode == 200) {
        final data = json.decode(getResponse.body);
        final fields = data['fields'] as Map<String, dynamic>?;
        if (fields != null && fields['times_reviewed'] != null) {
          currentReviews =
              int.tryParse(fields['times_reviewed']['integerValue'] ?? '0') ??
                  0;
        }
      }

      final body = {
        'fields': {
          'mastered': {'booleanValue': true},
          'times_reviewed': {'integerValue': (currentReviews + 1).toString()},
        }
      };

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('🏆 Anotação marcada como dominada: $entryId');
        return true;
      } else {
        print('❌ Erro ao marcar como dominada: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exceção ao marcar como dominada: $e');
      return false;
    }
  }

  /// Buscar anotações pendentes de revisão
  static Future<List<DiaryEntry>> getPendingReviews(String userId) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final url = '$_baseUrl:runQuery';

      final body = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'diary_entries'}
          ],
          'where': {
            'compositeFilter': {
              'op': 'AND',
              'filters': [
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'user_id'},
                    'op': 'EQUAL',
                    'value': {'stringValue': userId}
                  }
                },
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'mastered'},
                    'op': 'EQUAL',
                    'value': {'booleanValue': false}
                  }
                },
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'next_review_date'},
                    'op': 'LESS_THAN_OR_EQUAL',
                    'value': {'timestampValue': now}
                  }
                }
              ]
            }
          },
          'orderBy': [
            {
              'field': {'fieldPath': 'next_review_date'},
              'direction': 'ASCENDING'
            }
          ],
          'limit': 50
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final entries = <DiaryEntry>[];

        for (final item in data) {
          if (item['document'] != null) {
            final docName = item['document']['name'] as String;
            final docId = docName.split('/').last;
            final fields = item['document']['fields'] as Map<String, dynamic>;
            entries.add(_parseDiaryEntry(docId, fields));
          }
        }

        print('📅 ${entries.length} revisões pendentes para $userId');
        return entries;
      }

      return [];
    } catch (e) {
      print('❌ Erro ao buscar revisões pendentes: $e');
      return [];
    }
  }

  // ========================================
  // 🔧 HELPERS
  // ========================================

  static Map<String, dynamic> _parseResponseFields(
      Map<String, dynamic> fields) {
    return {
      'user_id': _getString(fields['user_id']),
      'question_id': _getString(fields['question_id']),
      'was_correct': _getBool(fields['was_correct']),
      'selected_answer': _getInt(fields['selected_answer']),
      'time_spent': _getInt(fields['time_spent']),
      'subject': _getString(fields['subject']),
      'difficulty': _getString(fields['difficulty']),
      'answered_at': _getTimestamp(fields['answered_at']),
    };
  }

  static DiaryEntry _parseDiaryEntry(String id, Map<String, dynamic> fields) {
    return DiaryEntry(
      id: id,
      userId: _getString(fields['user_id']),
      questionId: _getString(fields['question_id']),
      questionText: _getString(fields['question_text']),
      correctAnswer: _getString(fields['correct_answer']),
      userAnswer: _getString(fields['user_answer']),
      userNote: _getString(fields['user_note']),
      userStrategy: _getString(fields['user_strategy']),
      difficultyRating: _getInt(fields['difficulty_rating']),
      emotion: _getString(fields['emotion']),
      subject: _getString(fields['subject']),
      createdAt: _getTimestamp(fields['created_at']),
      nextReviewDate: _getTimestamp(fields['next_review_date']),
      timesReviewed: _getInt(fields['times_reviewed']),
      mastered: _getBool(fields['mastered']),
      xpEarned: _getInt(fields['xp_earned']),
    );
  }

  static String _getString(dynamic field) {
    return field?['stringValue'] ?? '';
  }

  static int _getInt(dynamic field) {
    final value = field?['integerValue'];
    return value != null ? int.tryParse(value.toString()) ?? 0 : 0;
  }

  static bool _getBool(dynamic field) {
    return field?['booleanValue'] ?? false;
  }

  static DateTime _getTimestamp(dynamic field) {
    final value = field?['timestampValue'];
    if (value != null) {
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
