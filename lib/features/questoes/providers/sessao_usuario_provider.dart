// lib/features/questoes/providers/sessao_usuario_provider.dart
// ✅ V7.1 - Sistema de Sessão do Usuário com XP, Níveis e Persistência

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ===== CONSTANTES DO SISTEMA V7.1 =====
class GameConstants {
  // XP por dificuldade (ACERTO)
  static const int XP_FACIL_ACERTO = 15;
  static const int XP_MEDIO_ACERTO = 25;
  static const int XP_DIFICIL_ACERTO = 40;

  // XP por dificuldade (ERRO) - V7.1: 0 XP sem Diário
  static const int XP_FACIL_ERRO = 0;
  static const int XP_MEDIO_ERRO = 0;
  static const int XP_DIFICIL_ERRO = 0;

  // XP por dificuldade (ERRO COM REFLEXÃO) - Sprint 9 quando Diário existir
  static const int XP_FACIL_REFLEXAO = 5;
  static const int XP_MEDIO_REFLEXAO = 8;
  static const int XP_DIFICIL_REFLEXAO = 12;

  // XP Timeout
  static const int XP_TIMEOUT = 0;

  // Bonus Streaks
  static const int STREAK_3_BONUS = 10;
  static const int STREAK_5_BONUS = 25;
  static const int STREAK_10_BONUS = 50;

  // Multiplicador behavioralAspect
  static const double BEHAVIORAL_MATCH_BONUS = 1.20; // +20%

  // XP Exponencial
  static const double XP_BASE = 100.0;
  static const double XP_GROWTH_RATE = 1.08; // p=1.08

  // Recursos
  static const double RECURSO_INICIAL = 100.0;
  static const double PERDA_ERRO_AGUA = 10.0;
  static const double PERDA_TIMEOUT_ENERGIA = 10.0;
  static const double GANHO_ACERTO = 5.0;

  // Fórmula Saúde
  static const int PESO_AGUA_SAUDE = 14;
  static const int PESO_ENERGIA_SAUDE = 4;

  // Recuperação Saúde
  static const double RECUPERACAO_LEVEL_UP = 15.0;
  static const double RECUPERACAO_STREAK_7 = 10.0;
}

// ===== ESTADO DA SESSÃO DO USUÁRIO =====
class SessaoUsuarioState {
  // === PERSISTENTE (SharedPreferences) ===
  final double saudeGlobal; // Saúde entre sessões (0-100)
  final int xpTotal; // XP acumulado total
  final int nivelAtual; // Nível do usuário (1-51+)
  final int streakDias; // Dias consecutivos jogando

  // === SESSÃO ATUAL (memória) ===
  final int xpInicioSessao; // XP quando começou (para checkpoint)
  final double saudeInicioSessao; // Saúde quando começou
  final int xpGanhoSessao; // XP ganho na sessão atual
  final int questoesRespondidasSessao;
  final int acertosSessao;
  final int errosSessao;
  final int timeoutsSessao;
  final int streakAcertosAtual; // Acertos seguidos na sessão
  final DateTime? inicioSessao;
  final bool sessaoAtiva;

  const SessaoUsuarioState({
    // Persistente
    this.saudeGlobal = 100.0,
    this.xpTotal = 0,
    this.nivelAtual = 1,
    this.streakDias = 0,
    // Sessão
    this.xpInicioSessao = 0,
    this.saudeInicioSessao = 100.0,
    this.xpGanhoSessao = 0,
    this.questoesRespondidasSessao = 0,
    this.acertosSessao = 0,
    this.errosSessao = 0,
    this.timeoutsSessao = 0,
    this.streakAcertosAtual = 0,
    this.inicioSessao,
    this.sessaoAtiva = false,
  });

  SessaoUsuarioState copyWith({
    double? saudeGlobal,
    int? xpTotal,
    int? nivelAtual,
    int? streakDias,
    int? xpInicioSessao,
    double? saudeInicioSessao,
    int? xpGanhoSessao,
    int? questoesRespondidasSessao,
    int? acertosSessao,
    int? errosSessao,
    int? timeoutsSessao,
    int? streakAcertosAtual,
    DateTime? inicioSessao,
    bool? sessaoAtiva,
  }) {
    return SessaoUsuarioState(
      saudeGlobal: saudeGlobal ?? this.saudeGlobal,
      xpTotal: xpTotal ?? this.xpTotal,
      nivelAtual: nivelAtual ?? this.nivelAtual,
      streakDias: streakDias ?? this.streakDias,
      xpInicioSessao: xpInicioSessao ?? this.xpInicioSessao,
      saudeInicioSessao: saudeInicioSessao ?? this.saudeInicioSessao,
      xpGanhoSessao: xpGanhoSessao ?? this.xpGanhoSessao,
      questoesRespondidasSessao:
          questoesRespondidasSessao ?? this.questoesRespondidasSessao,
      acertosSessao: acertosSessao ?? this.acertosSessao,
      errosSessao: errosSessao ?? this.errosSessao,
      timeoutsSessao: timeoutsSessao ?? this.timeoutsSessao,
      streakAcertosAtual: streakAcertosAtual ?? this.streakAcertosAtual,
      inicioSessao: inicioSessao ?? this.inicioSessao,
      sessaoAtiva: sessaoAtiva ?? this.sessaoAtiva,
    );
  }

  // === GETTERS ÚTEIS ===

  /// XP necessário para o próximo nível (fórmula exponencial p=1.08)
  int get xpParaProximoNivel {
    return (GameConstants.XP_BASE *
            _pow(GameConstants.XP_GROWTH_RATE, nivelAtual))
        .round();
  }

  /// XP atual dentro do nível (progresso parcial)
  int get xpNoNivelAtual {
    int xpAcumuladoAteNivelAnterior = 0;
    for (int i = 1; i < nivelAtual; i++) {
      xpAcumuladoAteNivelAnterior +=
          (GameConstants.XP_BASE * _pow(GameConstants.XP_GROWTH_RATE, i))
              .round();
    }
    return xpTotal - xpAcumuladoAteNivelAnterior;
  }

  /// Progresso percentual no nível atual (0.0 a 1.0)
  double get progressoNivel {
    if (xpParaProximoNivel == 0) return 0.0;
    return (xpNoNivelAtual / xpParaProximoNivel).clamp(0.0, 1.0);
  }

  /// Precisão da sessão atual (0.0 a 1.0)
  double get precisaoSessao {
    if (questoesRespondidasSessao == 0) return 0.0;
    return acertosSessao / questoesRespondidasSessao;
  }

  /// Helper para potência
  static double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Converte para Map (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'saudeGlobal': saudeGlobal,
      'xpTotal': xpTotal,
      'nivelAtual': nivelAtual,
      'streakDias': streakDias,
    };
  }

  /// Cria a partir de Map (para persistência)
  factory SessaoUsuarioState.fromMap(Map<String, dynamic> map) {
    return SessaoUsuarioState(
      saudeGlobal: (map['saudeGlobal'] ?? 100.0).toDouble(),
      xpTotal: map['xpTotal'] ?? 0,
      nivelAtual: map['nivelAtual'] ?? 1,
      streakDias: map['streakDias'] ?? 0,
    );
  }
}

// ===== NOTIFIER DA SESSÃO DO USUÁRIO =====
class SessaoUsuarioNotifier extends StateNotifier<SessaoUsuarioState> {
  SessaoUsuarioNotifier() : super(const SessaoUsuarioState()) {
    _carregarDadosPersistentes();
  }

  // ===== PERSISTÊNCIA =====

  /// Carrega dados do SharedPreferences
  Future<void> _carregarDadosPersistentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saudeGlobal = prefs.getDouble('studyquest_saude') ?? 100.0;
      final xpTotal = prefs.getInt('studyquest_xp_total') ?? 0;
      final nivelAtual = prefs.getInt('studyquest_nivel') ?? 1;
      final streakDias = prefs.getInt('studyquest_streak_dias') ?? 0;

      state = state.copyWith(
        saudeGlobal: saudeGlobal,
        xpTotal: xpTotal,
        nivelAtual: nivelAtual,
        streakDias: streakDias,
      );

      print('✅ Dados carregados: Saúde=$saudeGlobal, XP=$xpTotal, Nível=$nivelAtual');
    } catch (e) {
      print('⚠️ Erro ao carregar dados: $e');
    }
  }

  /// Salva dados no SharedPreferences
  Future<void> _salvarDadosPersistentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('studyquest_saude', state.saudeGlobal);
      await prefs.setInt('studyquest_xp_total', state.xpTotal);
      await prefs.setInt('studyquest_nivel', state.nivelAtual);
      await prefs.setInt('studyquest_streak_dias', state.streakDias);

      print('💾 Dados salvos: Saúde=${state.saudeGlobal}, XP=${state.xpTotal}');
    } catch (e) {
      print('⚠️ Erro ao salvar dados: $e');
    }
  }

  // ===== CONTROLE DE SESSÃO =====

  /// Inicia uma nova sessão de questões
  void iniciarSessao() {
    state = state.copyWith(
      xpInicioSessao: state.xpTotal,
      saudeInicioSessao: state.saudeGlobal,
      xpGanhoSessao: 0,
      questoesRespondidasSessao: 0,
      acertosSessao: 0,
      errosSessao: 0,
      timeoutsSessao: 0,
      streakAcertosAtual: 0,
      inicioSessao: DateTime.now(),
      sessaoAtiva: true,
    );

    print('🎯 Sessão iniciada: XP inicial=${state.xpInicioSessao}, Saúde inicial=${state.saudeInicioSessao}');
  }

  /// Finaliza a sessão atual
  Future<void> finalizarSessao() async {
    state = state.copyWith(sessaoAtiva: false);
    await _salvarDadosPersistentes();

    print('📊 Sessão finalizada:');
    print('   Questões: ${state.questoesRespondidasSessao}');
    print('   Acertos: ${state.acertosSessao}');
    print('   Erros: ${state.errosSessao}');
    print('   Timeouts: ${state.timeoutsSessao}');
    print('   XP ganho: ${state.xpGanhoSessao}');
    print('   Precisão: ${(state.precisaoSessao * 100).toStringAsFixed(1)}%');
  }

  // ===== SISTEMA DE XP =====

  /// Calcula XP por acerto baseado na dificuldade
  int calcularXpAcerto(String dificuldade, {bool behavioralMatch = false}) {
    int xpBase;
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        xpBase = GameConstants.XP_FACIL_ACERTO;
        break;
      case 'medio':
        xpBase = GameConstants.XP_MEDIO_ACERTO;
        break;
      case 'dificil':
        xpBase = GameConstants.XP_DIFICIL_ACERTO;
        break;
      default:
        xpBase = GameConstants.XP_MEDIO_ACERTO;
    }

    // Aplicar bonus behavioral se houver match
    if (behavioralMatch) {
      xpBase = (xpBase * GameConstants.BEHAVIORAL_MATCH_BONUS).round();
    }

    return xpBase;
  }

  /// Calcula XP por erro (V7.1: 0 XP sem Diário)
  int calcularXpErro(String dificuldade, {bool comReflexao = false}) {
    // V7.1: Sem Diário ainda, erro = 0 XP
    // Quando Diário existir (Sprint 9), comReflexao = true dará XP
    if (!comReflexao) {
      return 0;
    }

    // Com reflexão (futuro Sprint 9)
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        return GameConstants.XP_FACIL_REFLEXAO;
      case 'medio':
        return GameConstants.XP_MEDIO_REFLEXAO;
      case 'dificil':
        return GameConstants.XP_DIFICIL_REFLEXAO;
      default:
        return GameConstants.XP_MEDIO_REFLEXAO;
    }
  }

  /// Calcula bonus de streak
  int calcularBonusStreak(int streakAtual) {
    if (streakAtual >= 10) {
      return GameConstants.STREAK_10_BONUS;
    } else if (streakAtual >= 5) {
      return GameConstants.STREAK_5_BONUS;
    } else if (streakAtual >= 3) {
      return GameConstants.STREAK_3_BONUS;
    }
    return 0;
  }

  /// Registra um ACERTO
  void registrarAcerto(String dificuldade, {bool behavioralMatch = false}) {
    final novoStreak = state.streakAcertosAtual + 1;
    final xpQuestao = calcularXpAcerto(dificuldade, behavioralMatch: behavioralMatch);
    final xpBonus = calcularBonusStreak(novoStreak);
    final xpTotal = xpQuestao + xpBonus;

    state = state.copyWith(
      questoesRespondidasSessao: state.questoesRespondidasSessao + 1,
      acertosSessao: state.acertosSessao + 1,
      streakAcertosAtual: novoStreak,
      xpGanhoSessao: state.xpGanhoSessao + xpTotal,
      xpTotal: state.xpTotal + xpTotal,
    );

    // Verificar level up
    _verificarLevelUp();

    print('✅ ACERTO: +$xpQuestao XP ${xpBonus > 0 ? "(+$xpBonus streak bonus)" : ""} | Streak: $novoStreak');
  }

  /// Registra um ERRO
  void registrarErro(String dificuldade, {bool comReflexao = false}) {
    final xpGanho = calcularXpErro(dificuldade, comReflexao: comReflexao);

    state = state.copyWith(
      questoesRespondidasSessao: state.questoesRespondidasSessao + 1,
      errosSessao: state.errosSessao + 1,
      streakAcertosAtual: 0, // Reset streak
      xpGanhoSessao: state.xpGanhoSessao + xpGanho,
      xpTotal: state.xpTotal + xpGanho,
    );

    print('❌ ERRO: +$xpGanho XP | Streak resetado');
  }

  /// Registra um TIMEOUT
  void registrarTimeout() {
    state = state.copyWith(
      questoesRespondidasSessao: state.questoesRespondidasSessao + 1,
      timeoutsSessao: state.timeoutsSessao + 1,
      streakAcertosAtual: 0, // Reset streak
      // Timeout = 0 XP
    );

    print('⏰ TIMEOUT: +0 XP | Streak resetado');
  }

  // ===== SISTEMA DE NÍVEIS =====

  /// Verifica e aplica level up se necessário
  void _verificarLevelUp() {
    while (state.xpNoNivelAtual >= state.xpParaProximoNivel) {
      final novoNivel = state.nivelAtual + 1;

      // Bonus de level up: +15% saúde
      final novaSaude = (state.saudeGlobal + GameConstants.RECUPERACAO_LEVEL_UP)
          .clamp(0.0, 100.0);

      state = state.copyWith(
        nivelAtual: novoNivel,
        saudeGlobal: novaSaude,
      );

      print('🎉 LEVEL UP! Nível $novoNivel | Saúde +${GameConstants.RECUPERACAO_LEVEL_UP}% → $novaSaude%');
    }
  }

  // ===== SISTEMA DE SAÚDE =====

  /// Atualiza saúde global (usado pelo RecursosProvider)
  void atualizarSaude(double novaSaude) {
    state = state.copyWith(
      saudeGlobal: novaSaude.clamp(0.0, 100.0),
    );
    _salvarDadosPersistentes();
  }

  /// Recupera saúde (level up, streak, quests, etc)
  void recuperarSaude(double quantidade) {
    final novaSaude = (state.saudeGlobal + quantidade).clamp(0.0, 100.0);
    state = state.copyWith(saudeGlobal: novaSaude);
    _salvarDadosPersistentes();

    print('💚 Saúde recuperada: +$quantidade% → $novaSaude%');
  }

  // ===== CHECKPOINT =====

  /// Aplica checkpoint (quando água OU energia = 0)
  /// Volta XP para início da sessão, mantém saúde
  void aplicarCheckpoint() {
    final xpPerdido = state.xpTotal - state.xpInicioSessao;

    state = state.copyWith(
      xpTotal: state.xpInicioSessao,
      xpGanhoSessao: 0,
      questoesRespondidasSessao: 0,
      acertosSessao: 0,
      errosSessao: 0,
      timeoutsSessao: 0,
      streakAcertosAtual: 0,
      // Saúde MANTÉM o valor atual
    );

    print('⚠️ CHECKPOINT: XP voltou para ${state.xpInicioSessao} (-$xpPerdido XP perdido)');
  }

  // ===== GAME OVER =====

  /// Aplica game over (quando saúde = 0)
  /// Volta para início do nível atual
  void aplicarGameOver() {
    // Calcular XP do início do nível atual
    int xpInicioNivel = 0;
    for (int i = 1; i < state.nivelAtual; i++) {
      xpInicioNivel +=
          (GameConstants.XP_BASE * SessaoUsuarioState._pow(GameConstants.XP_GROWTH_RATE, i))
              .round();
    }

    state = state.copyWith(
      xpTotal: xpInicioNivel,
      saudeGlobal: 100.0, // Reset saúde
      xpGanhoSessao: 0,
      questoesRespondidasSessao: 0,
      acertosSessao: 0,
      errosSessao: 0,
      timeoutsSessao: 0,
      streakAcertosAtual: 0,
      sessaoAtiva: false,
    );

    _salvarDadosPersistentes();

    print('💀 GAME OVER: Voltou para início do nível ${state.nivelAtual} (XP=$xpInicioNivel)');
  }

  // ===== RESET (para testes) =====

  /// Reset completo (apenas para desenvolvimento/testes)
  Future<void> resetCompleto() async {
    state = const SessaoUsuarioState();
    await _salvarDadosPersistentes();
    print('🔄 Reset completo realizado');
  }
}

// ===== PROVIDER RIVERPOD =====
final sessaoUsuarioProvider =
    StateNotifierProvider<SessaoUsuarioNotifier, SessaoUsuarioState>((ref) {
  return SessaoUsuarioNotifier();
});

// ===== PROVIDERS DERIVADOS =====

/// Provider para XP total
final xpTotalProvider = Provider<int>((ref) {
  return ref.watch(sessaoUsuarioProvider).xpTotal;
});

/// Provider para nível atual
final nivelAtualProvider = Provider<int>((ref) {
  return ref.watch(sessaoUsuarioProvider).nivelAtual;
});

/// Provider para saúde global
final saudeGlobalProvider = Provider<double>((ref) {
  return ref.watch(sessaoUsuarioProvider).saudeGlobal;
});

/// Provider para progresso no nível (0.0 a 1.0)
final progressoNivelProvider = Provider<double>((ref) {
  return ref.watch(sessaoUsuarioProvider).progressoNivel;
});

/// Provider para precisão da sessão
final precisaoSessaoProvider = Provider<double>((ref) {
  return ref.watch(sessaoUsuarioProvider).precisaoSessao;
});

/// Provider para verificar se está em sessão ativa
final sessaoAtivaProvider = Provider<bool>((ref) {
  return ref.watch(sessaoUsuarioProvider).sessaoAtiva;
});