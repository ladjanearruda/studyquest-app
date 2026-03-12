// lib/features/niveis/providers/nivel_provider.dart
// ✅ V7.2.1 - ADICIONADO: método voltarInicioNivel para Game Over
// 📅 Atualizado: 10/02/2026

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nivel_model.dart';
import '../services/nivel_persistence.dart';
import '../../../core/services/firebase_rest_auth.dart';

/// Provider principal de níveis
final nivelProvider = StateNotifierProvider<NivelNotifier, NivelUsuario>((ref) {
  final notifier = NivelNotifier(ref);

  // Recarregar XP do Firebase sempre que o usuário logar/deslogar
  ref.listen<AuthState>(authProvider, (previous, next) {
    final uid = next.user?.uid;
    final prevUid = previous?.user?.uid;
    if (uid != null && uid != prevUid) {
      notifier.carregarDoFirebase(uid);
    }
  });

  return notifier;
});

/// Provider para verificar se uma feature está desbloqueada
final featureDesbloqueadaProvider =
    Provider.family<bool, String>((ref, feature) {
  final nivel = ref.watch(nivelProvider);
  return NivelSystem.featureDesbloqueada(nivel.nivel, feature);
});

/// Provider para próximos desbloqueios
final proximosDesbloqueiosProvider = Provider<List<Desbloqueio>>((ref) {
  final nivel = ref.watch(nivelProvider);
  return NivelSystem.proximosDesbloqueios(nivel.nivel, limite: 3);
});

/// Notifier que gerencia o estado dos níveis
class NivelNotifier extends StateNotifier<NivelUsuario> {
  final Ref _ref;

  NivelNotifier(this._ref) : super(NivelUsuario.inicial()) {
    _carregarDados();
  }

  // ===== PERSISTÊNCIA =====

  /// Carrega XP na inicialização (usa API unificada do NivelPersistence)
  Future<void> _carregarDados() async {
    try {
      final user = _ref.read(authProvider).user;
      final isAnonymous = user == null || user.isAnonymous;
      final userId = user?.uid ?? 'anon';

      final xp = await NivelPersistence.carregarXp(userId, isAnonymous: isAnonymous);
      if (xp > 0) {
        state = NivelUsuario.fromXpTotal(xp);
        print('📊 Nível carregado: ${state.nivel} (${state.xpTotal} XP) [${isAnonymous ? "local" : "Firebase"}]');
      }
    } catch (e) {
      print('⚠️ Erro ao carregar nível: $e');
    }
  }

  /// Chamado pelo ref.listen quando um novo usuário loga
  Future<void> carregarDoFirebase(String userId) async {
    try {
      final xp = await NivelPersistence.carregarXp(userId, isAnonymous: false);
      if (xp > state.xpTotal) {
        state = NivelUsuario.fromXpTotal(xp);
        print('☁️ XP restaurado do Firebase: ${state.nivel} (${state.xpTotal} XP)');
      }
    } catch (e) {
      print('⚠️ Erro ao carregar XP do Firebase: $e');
    }
  }

  /// Salva XP (usa API unificada: local para anônimo, Firebase para logado)
  Future<void> _salvarDados() async {
    try {
      final user = _ref.read(authProvider).user;
      final isAnonymous = user == null || user.isAnonymous;
      final userId = user?.uid ?? 'anon';

      await NivelPersistence.salvarNivel(state.nivel);
      unawaited(NivelPersistence.salvarXp(userId, state.xpTotal, isAnonymous: isAnonymous));

      print('💾 Nível salvo: ${state.nivel} (${state.xpTotal} XP) [${isAnonymous ? "local" : "Firebase"}]');
    } catch (e) {
      print('⚠️ Erro ao salvar nível: $e');
    }
  }

  // ===== AÇÕES PRINCIPAIS =====

  /// Adiciona XP e retorna informações sobre level up
  /// Retorna: {subiuNivel: bool, nivelAnterior: int, novoNivel: int, desbloqueios: List}
  Future<Map<String, dynamic>> adicionarXp(int xpGanho) async {
    if (xpGanho <= 0) {
      return {
        'subiuNivel': false,
        'nivelAnterior': state.nivel,
        'novoNivel': state.nivel,
        'desbloqueios': <Desbloqueio>[],
        'xpGanho': 0,
      };
    }

    final estadoAnterior = state;
    state = state.ganharXp(xpGanho);

    // Salvar no SharedPreferences
    await _salvarDados();

    // Verificar se subiu de nível
    final subiuNivel = state.subiuDeNivel(estadoAnterior);
    final mudouTier = state.mudouDeTier(estadoAnterior);
    final novosDesbloqueios = state.novosDesbloqueios(estadoAnterior);

    // Log
    print('⭐ +$xpGanho XP | Total: ${state.xpTotal} | Nível: ${state.nivel}');
    if (subiuNivel) {
      print('🎉 LEVEL UP! ${estadoAnterior.nivel} → ${state.nivel}');
      if (mudouTier) {
        print('🏆 NOVO TIER: ${state.tier.nome} ${state.tier.emoji}');
      }
      if (novosDesbloqueios.isNotEmpty) {
        print(
            '🔓 Desbloqueios: ${novosDesbloqueios.map((d) => d.titulo).join(', ')}');
      }
    }

    return {
      'subiuNivel': subiuNivel,
      'mudouTier': mudouTier,
      'nivelAnterior': estadoAnterior.nivel,
      'novoNivel': state.nivel,
      'tierAnterior': estadoAnterior.tier,
      'novoTier': state.tier,
      'desbloqueios': novosDesbloqueios,
      'xpGanho': xpGanho,
      'xpTotal': state.xpTotal,
      'mensagem': subiuNivel ? NivelSystem.mensagemLevelUp(state.nivel) : null,
    };
  }

  /// Adiciona XP de uma questão respondida
  Future<Map<String, dynamic>> adicionarXpQuestao({
    required bool acertou,
    required String dificuldade,
    int streakAtual = 0,
  }) async {
    if (!acertou) {
      return {
        'subiuNivel': false,
        'xpGanho': 0,
        'novoNivel': state.nivel,
        'desbloqueios': <Desbloqueio>[],
      };
    }

    // XP base por dificuldade
    int xpBase;
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        xpBase = 15;
        break;
      case 'dificil':
        xpBase = 40;
        break;
      case 'medio':
      default:
        xpBase = 25;
        break;
    }

    // Bonus de streak
    int xpBonus = 0;
    if (streakAtual >= 10) {
      xpBonus = 50;
    } else if (streakAtual >= 5) {
      xpBonus = 25;
    } else if (streakAtual >= 3) {
      xpBonus = 10;
    }

    final xpTotal = xpBase + xpBonus;
    return adicionarXp(xpTotal);
  }

  /// Adiciona XP por anotação no diário (futuro)
  Future<Map<String, dynamic>> adicionarXpDiario() async {
    return adicionarXp(25); // +25 XP por anotação
  }

  /// Adiciona XP por revisão de flashcard (futuro)
  Future<Map<String, dynamic>> adicionarXpRevisao() async {
    return adicionarXp(15); // +15 XP por revisão
  }

  // ===== GAME OVER =====

  /// ✅ V7.2.1: Volta o XP para o início do nível atual (usado no Game Over)
  /// Mantém o nível, mas perde todo o XP acumulado NESTE nível
  Future<void> voltarInicioNivel() async {
    final nivelAtual = state.nivel;

    // Calcula XP necessário para chegar ao nível atual (soma de todos os níveis anteriores)
    int xpInicioNivel = 0;
    for (int i = 1; i < nivelAtual; i++) {
      xpInicioNivel += NivelSystem.xpParaProximoNivel(i);
    }

    // Define o XP para o início do nível (usuário mantém o nível mas perde progresso)
    state = NivelUsuario.fromXpTotal(xpInicioNivel);

    // Salva no SharedPreferences
    await _salvarDados();

    print(
        '💀 GAME OVER: XP voltou para $xpInicioNivel (início do nível $nivelAtual)');
    print('   Nível mantido: $nivelAtual | XP no nível: 0');
  }

  // ===== CONSULTAS =====

  /// Retorna XP faltando para o próximo nível
  int get xpFaltando => state.xpFaltando;

  /// Retorna progresso percentual (0-100)
  int get progressoPorcentagem => (state.progresso * 100).round();

  /// Retorna descrição do nível atual
  String get descricaoNivel => state.descricaoCompleta;

  /// Verifica se feature está desbloqueada
  bool featureDesbloqueada(String titulo) {
    return NivelSystem.featureDesbloqueada(state.nivel, titulo);
  }

  /// Retorna estimativa de sessões para um nível
  int sessoesParaNivel(int nivelAlvo) {
    return NivelSystem.sessoesParaNivel(
      nivelAlvo,
      nivelAtual: state.nivel,
      xpAtual: state.xpTotal,
    );
  }

  // ===== RESET (para testes/debug) =====

  /// Reseta para o estado inicial
  Future<void> resetar() async {
    state = NivelUsuario.inicial();
    await NivelPersistence.limparDados();
    print('🔄 Nível resetado para inicial');
  }

  /// Define XP manualmente (para testes)
  Future<void> definirXp(int xp) async {
    state = NivelUsuario.fromXpTotal(xp);
    await _salvarDados();
    print('🔧 XP definido manualmente: $xp');
  }
}

/// Provider para o resultado de level up (usado nos modais)
final levelUpResultProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider que observa quando há um level up pendente
final temLevelUpPendenteProvider = Provider<bool>((ref) {
  final result = ref.watch(levelUpResultProvider);
  return result != null && result['subiuNivel'] == true;
});
