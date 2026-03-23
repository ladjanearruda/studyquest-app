// lib/core/services/firebase_user_service.dart
// ✅ Sprint 10 - Persistência de perfil do usuário no Firebase (REST API)
// 📅 Criado: 18/03/2026

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firebase_rest_auth.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

class FirebaseUserService {
  static const String _baseUrl =
      'https://firestore.googleapis.com/v1/projects/studyquest-app-banco/databases/(default)/documents';

  // ========================================
  // 💾 SALVAR PERFIL
  // ========================================

  /// Salva perfil completo em users/{userId}.
  /// Também denormaliza nome/avatar em user_xp/{userId} para rankings eficientes
  /// (evita N+1 queries ao montar a lista de ranking).
  static Future<bool> saveUserProfile({
    required String userId,
    required OnboardingData onboardingData,
    String? email,
  }) async {
    try {
      final headers = await FirebaseRestAuth.getAuthHeaders();
      final now = DateTime.now().toUtc().toIso8601String();

      // ── 1. Perfil completo em users/{userId} ─────────────────────────
      final profileUrl = '$_baseUrl/users/$userId';
      final profileBody = {
        'fields': {
          'name': {'stringValue': onboardingData.name ?? ''},
          'email': {'stringValue': email ?? ''},
          'avatar_type': {
            'stringValue': onboardingData.selectedAvatarType?.name ?? 'explorador'
          },
          'avatar_gender': {
            'stringValue': onboardingData.selectedAvatarGender?.name ?? 'masculino'
          },
          'education_level': {
            'stringValue': onboardingData.educationLevel?.name ?? ''
          },
          'study_goal': {'stringValue': onboardingData.studyGoal?.name ?? ''},
          'interest_area': {
            'stringValue': onboardingData.interestArea?.name ?? ''
          },
          'dream_university': {'stringValue': onboardingData.dreamUniversity ?? ''},
          'study_time': {'stringValue': onboardingData.studyTime ?? ''},
          'created_at': {'timestampValue': now},
          'updated_at': {'timestampValue': now},
        }
      };

      final profileResponse = await http.patch(
        Uri.parse(profileUrl),
        headers: headers,
        body: json.encode(profileBody),
      );

      // ── 2. Denormalização em user_xp/{userId} para rankings ──────────
      // Usa updateMask para não sobrescrever xp_total existente
      final xpMaskUrl = '$_baseUrl/user_xp/$userId'
          '?updateMask.fieldPaths=name'
          '&updateMask.fieldPaths=avatar_type'
          '&updateMask.fieldPaths=avatar_gender'
          '&updateMask.fieldPaths=education_level';

      await http.patch(
        Uri.parse(xpMaskUrl),
        headers: headers,
        body: json.encode({
          'fields': {
            'name': {
              'stringValue':
                  onboardingData.name?.isNotEmpty == true ? onboardingData.name! : 'Explorador'
            },
            'avatar_type': {
              'stringValue': onboardingData.selectedAvatarType?.name ?? 'explorador'
            },
            'avatar_gender': {
              'stringValue': onboardingData.selectedAvatarGender?.name ?? 'masculino'
            },
            'education_level': {
              'stringValue': onboardingData.educationLevel?.name ?? ''
            },
          }
        }),
      );

      return profileResponse.statusCode == 200;
    } catch (e) {
      print('❌ Exceção ao salvar perfil: $e');
      return false;
    }
  }

  // ========================================
  // 📖 CARREGAR PERFIL
  // ========================================

  /// Carrega o perfil completo do usuário de users/{userId}
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final url = '$_baseUrl/users/$userId';
      final headers = await FirebaseRestAuth.getAuthHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fields = data['fields'] as Map<String, dynamic>?;
        if (fields == null) return null;
        return {
          'name': _str(fields['name']),
          'email': _str(fields['email']),
          'avatar_type': _str(fields['avatar_type']),
          'avatar_gender': _str(fields['avatar_gender']),
          'education_level': _str(fields['education_level']),
          'study_goal': _str(fields['study_goal']),
          'interest_area': _str(fields['interest_area']),
          'dream_university': _str(fields['dream_university']),
        };
      }

      return null;
    } catch (e) {
      print('❌ Exceção ao carregar perfil: $e');
      return null;
    }
  }

  // ========================================
  // 🏆 RANKING
  // ========================================

  /// Busca top usuários ordenados por XP (ranking geral)
  /// Os campos name/avatar_type/avatar_gender já estão denormalizados em user_xp.
  static Future<List<Map<String, dynamic>>> getTopByXp({int limit = 30}) async {
    try {
      final url = '$_baseUrl:runQuery';
      final body = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'user_xp'}
          ],
          'orderBy': [
            {
              'field': {'fieldPath': 'xp_total'},
              'direction': 'DESCENDING'
            }
          ],
          'limit': limit,
        }
      };

      final headers = await FirebaseRestAuth.getAuthHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final result = <Map<String, dynamic>>[];
        int position = 1;

        for (final item in data) {
          if (item['document'] == null) continue;
          final fields = item['document']['fields'] as Map<String, dynamic>;
          final docName = item['document']['name'] as String;
          final userId = docName.split('/').last;
          final xp = _int(fields['xp_total']);
          if (xp == 0) continue; // Ignorar usuários sem XP

          final name = _str(fields['name']);
          result.add({
            'userId': userId,
            'name': name.isNotEmpty ? name : 'Explorador',
            'avatar_type': _strOr(fields['avatar_type'], 'explorador'),
            'avatar_gender': _strOr(fields['avatar_gender'], 'masculino'),
            'education_level': _str(fields['education_level']),
            'xp_total': xp,
            'position': position++,
          });
        }

        return result;
      }

      return [];
    } catch (e) {
      print('❌ Exceção ao buscar ranking: $e');
      return [];
    }
  }

  // ========================================
  // 🔧 HELPERS
  // ========================================

  static String _str(dynamic f) => f?['stringValue'] ?? '';
  static String _strOr(dynamic f, String fallback) {
    final v = f?['stringValue'] as String?;
    return (v != null && v.isNotEmpty) ? v : fallback;
  }

  static int _int(dynamic f) {
    final v = f?['integerValue'];
    return v != null ? int.tryParse(v.toString()) ?? 0 : 0;
  }
}
