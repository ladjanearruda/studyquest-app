// lib/features/niveis/services/nivel_persistence.dart
// ✅ Sprint 9 - Sincronização Firebase de XP
// 📅 Atualizado: 08/03/2026

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firebase_rest_auth.dart';

/// Serviço de persistência local para o sistema de níveis
///
/// ⚠️ IMPORTANTE - LIMITAÇÃO MVP:
/// - Dados salvos LOCALMENTE no dispositivo
/// - Se usuário limpar dados do app, perde progresso
/// - Migração para Firebase na Sprint 8 (com Auth)
class NivelPersistence {
  // ===== FIREBASE =====
  static const String _baseUrl =
      'https://firestore.googleapis.com/v1/projects/studyquest-app-banco/databases/(default)/documents';

  /// Salva XP no Firestore (coleção user_xp, doc = userId)
  static Future<bool> salvarXpFirebase(String userId, int xp) async {
    try {
      final url = '$_baseUrl/user_xp/$userId?updateMask.fieldPaths=xp_total';
      final headers = await FirebaseRestAuth.getAuthHeaders();
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          'fields': {
            'xp_total': {'integerValue': xp.toString()},
          }
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Erro ao salvar XP no Firebase: $e');
      return false;
    }
  }

  /// Carrega XP do Firestore. Retorna null se não existir ou falhar.
  static Future<int?> carregarXpFirebase(String userId) async {
    try {
      final url = '$_baseUrl/user_xp/$userId';
      final headers = await FirebaseRestAuth.getAuthHeaders();

      // 🔍 DEBUG
      print('📡 [carregarXpFirebase] URL: $url');
      final authHeader = headers['Authorization'];
      if (authHeader != null) {
        print('📡 [carregarXpFirebase] Authorization: ${authHeader.substring(0, authHeader.length.clamp(0, 27))}... (${authHeader.length} chars)');
      } else {
        print('📡 [carregarXpFirebase] Authorization: AUSENTE ⚠️');
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      // 🔍 DEBUG
      print('📡 [carregarXpFirebase] statusCode: ${response.statusCode}');
      final bodyPreview = response.body.length > 500
          ? '${response.body.substring(0, 500)}...'
          : response.body;
      print('📡 [carregarXpFirebase] body: $bodyPreview');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final fields = data['fields'] as Map<String, dynamic>?;
        final xpField = fields?['xp_total'];
        if (xpField != null) {
          return int.parse(xpField['integerValue'].toString());
        }
      }
      return null;
    } catch (e) {
      print('⚠️ Erro ao carregar XP do Firebase: $e');
      return null;
    }
  }

  // ===== CHAVES DO SHAREDPREFERENCES =====
  static const String _keyXpTotal = 'studyquest_xp_total';
  static const String _keyNivel = 'studyquest_nivel';
  static const String _keyDataPrimeiroAcesso = 'studyquest_primeiro_acesso';
  static const String _keyDataUltimoAcesso = 'studyquest_ultimo_acesso';
  static const String _keySessoesCompletadas = 'studyquest_sessoes_completadas';
  static const String _keyQuestoesRespondidas =
      'studyquest_questoes_respondidas';
  static const String _keyQuestoesCorretas = 'studyquest_questoes_corretas';
  static const String _keyMaiorStreak = 'studyquest_maior_streak';

  // ===== XP E NÍVEL =====

  /// Salva XP total
  static Future<bool> salvarXpTotal(int xp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyXpTotal, xp);
      await _atualizarUltimoAcesso();
      return true;
    } catch (e) {
      print('❌ Erro ao salvar XP: $e');
      return false;
    }
  }

  /// Carrega XP total
  static Future<int> carregarXpTotal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyXpTotal) ?? 0;
    } catch (e) {
      print('❌ Erro ao carregar XP: $e');
      return 0;
    }
  }

  /// Salva nível atual (redundância para verificação)
  static Future<bool> salvarNivel(int nivel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyNivel, nivel);
      return true;
    } catch (e) {
      print('❌ Erro ao salvar nível: $e');
      return false;
    }
  }

  /// Carrega nível
  static Future<int> carregarNivel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyNivel) ?? 1;
    } catch (e) {
      print('❌ Erro ao carregar nível: $e');
      return 1;
    }
  }

  // ===== ESTATÍSTICAS =====

  /// Incrementa sessões completadas
  static Future<void> incrementarSessoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final atual = prefs.getInt(_keySessoesCompletadas) ?? 0;
      await prefs.setInt(_keySessoesCompletadas, atual + 1);
    } catch (e) {
      print('❌ Erro ao incrementar sessões: $e');
    }
  }

  /// Carrega sessões completadas
  static Future<int> carregarSessoesCompletadas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keySessoesCompletadas) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Atualiza estatísticas de questões
  static Future<void> atualizarEstatisticasQuestoes({
    required int respondidas,
    required int corretas,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final respondidasAtual = prefs.getInt(_keyQuestoesRespondidas) ?? 0;
      final corretasAtual = prefs.getInt(_keyQuestoesCorretas) ?? 0;

      await prefs.setInt(
          _keyQuestoesRespondidas, respondidasAtual + respondidas);
      await prefs.setInt(_keyQuestoesCorretas, corretasAtual + corretas);
    } catch (e) {
      print('❌ Erro ao atualizar estatísticas: $e');
    }
  }

  /// Carrega estatísticas de questões
  static Future<Map<String, int>> carregarEstatisticasQuestoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'respondidas': prefs.getInt(_keyQuestoesRespondidas) ?? 0,
        'corretas': prefs.getInt(_keyQuestoesCorretas) ?? 0,
      };
    } catch (e) {
      return {'respondidas': 0, 'corretas': 0};
    }
  }

  /// Atualiza maior streak
  static Future<void> atualizarMaiorStreak(int streak) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maiorAtual = prefs.getInt(_keyMaiorStreak) ?? 0;

      if (streak > maiorAtual) {
        await prefs.setInt(_keyMaiorStreak, streak);
      }
    } catch (e) {
      print('❌ Erro ao atualizar streak: $e');
    }
  }

  /// Carrega maior streak
  static Future<int> carregarMaiorStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyMaiorStreak) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ===== DATAS =====

  /// Registra primeiro acesso (se ainda não existir)
  static Future<void> registrarPrimeiroAcesso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existente = prefs.getString(_keyDataPrimeiroAcesso);

      if (existente == null) {
        await prefs.setString(
          _keyDataPrimeiroAcesso,
          DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      print('❌ Erro ao registrar primeiro acesso: $e');
    }
  }

  /// Atualiza último acesso
  static Future<void> _atualizarUltimoAcesso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyDataUltimoAcesso,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('❌ Erro ao atualizar último acesso: $e');
    }
  }

  /// Carrega data do primeiro acesso
  static Future<DateTime?> carregarPrimeiroAcesso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_keyDataPrimeiroAcesso);
      return data != null ? DateTime.parse(data) : null;
    } catch (e) {
      return null;
    }
  }

  /// Carrega data do último acesso
  static Future<DateTime?> carregarUltimoAcesso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_keyDataUltimoAcesso);
      return data != null ? DateTime.parse(data) : null;
    } catch (e) {
      return null;
    }
  }

  // ===== MIGRAÇÃO (Sprint 8) =====

  /// Verifica se existem dados locais para migrar
  static Future<bool> temDadosParaMigrar() async {
    try {
      final xp = await carregarXpTotal();
      return xp > 0;
    } catch (e) {
      return false;
    }
  }

  /// Exporta todos os dados para migração para Firebase
  static Future<Map<String, dynamic>> exportarParaMigracao() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'xpTotal': prefs.getInt(_keyXpTotal) ?? 0,
        'nivel': prefs.getInt(_keyNivel) ?? 1,
        'primeiroAcesso': prefs.getString(_keyDataPrimeiroAcesso),
        'ultimoAcesso': prefs.getString(_keyDataUltimoAcesso),
        'sessoesCompletadas': prefs.getInt(_keySessoesCompletadas) ?? 0,
        'questoesRespondidas': prefs.getInt(_keyQuestoesRespondidas) ?? 0,
        'questoesCorretas': prefs.getInt(_keyQuestoesCorretas) ?? 0,
        'maiorStreak': prefs.getInt(_keyMaiorStreak) ?? 0,
        'dataExportacao': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Erro ao exportar dados: $e');
      return {};
    }
  }

  /// Limpa todos os dados locais (após migração bem sucedida)
  static Future<bool> limparDados() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyXpTotal);
      await prefs.remove(_keyNivel);
      await prefs.remove(_keyDataPrimeiroAcesso);
      await prefs.remove(_keyDataUltimoAcesso);
      await prefs.remove(_keySessoesCompletadas);
      await prefs.remove(_keyQuestoesRespondidas);
      await prefs.remove(_keyQuestoesCorretas);
      await prefs.remove(_keyMaiorStreak);

      print('🗑️ Dados locais limpos');
      return true;
    } catch (e) {
      print('❌ Erro ao limpar dados: $e');
      return false;
    }
  }

  // ===== DEBUG =====

  /// Imprime todos os dados salvos (para debug)
  static Future<void> debugPrintDados() async {
    try {
      final dados = await exportarParaMigracao();
      print('📊 === DADOS SALVOS ===');
      dados.forEach((key, value) {
        print('   $key: $value');
      });
      print('📊 ====================');
    } catch (e) {
      print('❌ Erro ao imprimir dados: $e');
    }
  }
}
