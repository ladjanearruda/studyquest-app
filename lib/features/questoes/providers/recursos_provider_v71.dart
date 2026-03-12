// lib/features/questoes/providers/recursos_provider_v71.dart
// ✅ V7.3 - Sistema de Recursos ATUALIZADO
// 📅 Atualizado: 10/02/2026
//
// ============================================
// MUDANÇAS V7.3:
// - Penalidade aumentada de -10% para -20%
// - Checkpoint agora acontece com 5 erros (em vez de 10)
// - Balanceamento para sessões de 10 questões
// ============================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sessao_usuario_provider.dart';

// ===== CONSTANTES DO JOGO V7.3 =====
// ✅ Renomeado para evitar conflito com sessao_usuario_provider.dart
class RecursosConstants {
  // ✅ V7.3: PENALIDADES AUMENTADAS
  static const double PERDA_ERRO_AGUA = 20.0; // Era 10.0 → Agora 20.0
  static const double PERDA_TIMEOUT_ENERGIA = 20.0; // Era 10.0 → Agora 20.0

  // Ganhos (mantidos)
  static const double GANHO_ACERTO = 5.0; // +5% água e energia

  // Pesos para cálculo de saúde (mantidos)
  static const double PESO_AGUA_SAUDE = 14.0;
  static const double PESO_ENERGIA_SAUDE = 4.0;

  // XP por dificuldade (mantidos)
  static const int XP_FACIL_ACERTO = 15;
  static const int XP_MEDIO_ACERTO = 25;
  static const int XP_DIFICIL_ACERTO = 40;

  // ============================================
  // DOCUMENTAÇÃO V7.3 - SISTEMA DE RECURSOS
  // ============================================
  //
  // RECURSOS TEMPORÁRIOS (resetam por sessão):
  // - Energia: 100% inicial, -20% por timeout, +5% por acerto
  // - Água: 100% inicial, -20% por erro, +5% por acerto
  //
  // RECURSO PERSISTENTE (entre sessões):
  // - Saúde: Calculada pela fórmula abaixo
  //
  // FÓRMULA DA SAÚDE:
  // Saúde_perdida = (Água_perdida × 14 + Energia_perdida × 4) / 100
  //
  // EVENTOS:
  // ┌─────────────────────────────────────────────────────────┐
  // │ CHECKPOINT (Água OU Energia = 0)                        │
  // ├─────────────────────────────────────────────────────────┤
  // │ • Trigger: 5 erros (água) OU 5 timeouts (energia)       │
  // │ • Água/Energia: Resetam para 100%                       │
  // │ • Saúde: MANTÉM valor atual                             │
  // │ • XP: Perde XP da sessão                                │
  // │ • Nível: MANTÉM                                         │
  // │ • Questões: REPETE as mesmas da sessão (volta questão 1)│
  // └─────────────────────────────────────────────────────────┘
  //
  // ┌─────────────────────────────────────────────────────────┐
  // │ GAME OVER (Saúde = 0)                                   │
  // ├─────────────────────────────────────────────────────────┤
  // │ • Trigger: Acumulou muitos erros/timeouts ao longo      │
  // │            de várias sessões                            │
  // │ • Todos recursos: Resetam para 100%                     │
  // │ • XP: Volta ao início do NÍVEL atual                    │
  // │ • Nível: MANTÉM (não perde nível)                       │
  // │ • Questões: Busca NOVAS questões                        │
  // └─────────────────────────────────────────────────────────┘
  //
  // BALANCEAMENTO V7.3:
  // - Sessão de 10 questões
  // - 5 erros → Checkpoint (água zera)
  // - 5 timeouts → Checkpoint (energia zera)
  // - ~5-7 checkpoints → Game Over (saúde zera)
  // - Game Over é evento RARO (muitos erros acumulados)
  //
  // ============================================
}

// ===== ESTADO DOS RECURSOS V7.3 =====
class RecursosState {
  // Recursos TEMPORÁRIOS (resetam por sessão)
  final double energia; // 0-100
  final double agua; // 0-100

  // Tracking de perdas na sessão (para calcular saúde)
  final double energiaPerdidaSessao; // Total perdido na sessão
  final double aguaPerdidaSessao; // Total perdido na sessão

  // Saúde inicial da sessão (para cálculo correto)
  final double saudeInicioSessao;

  const RecursosState({
    this.energia = 100.0,
    this.agua = 100.0,
    this.energiaPerdidaSessao = 0.0,
    this.aguaPerdidaSessao = 0.0,
    this.saudeInicioSessao = 100.0,
  });

  RecursosState copyWith({
    double? energia,
    double? agua,
    double? energiaPerdidaSessao,
    double? aguaPerdidaSessao,
    double? saudeInicioSessao,
  }) {
    return RecursosState(
      energia: energia ?? this.energia,
      agua: agua ?? this.agua,
      energiaPerdidaSessao: energiaPerdidaSessao ?? this.energiaPerdidaSessao,
      aguaPerdidaSessao: aguaPerdidaSessao ?? this.aguaPerdidaSessao,
      saudeInicioSessao: saudeInicioSessao ?? this.saudeInicioSessao,
    );
  }

  /// Calcula saúde atual baseado na fórmula V7.1
  /// Fórmula: Saúde_perdida = (Água_perdida × 14 + Energia_perdida × 4) / 100
  double calcularSaudeAtual() {
    final saudePerdida =
        (aguaPerdidaSessao * RecursosConstants.PESO_AGUA_SAUDE +
                energiaPerdidaSessao * RecursosConstants.PESO_ENERGIA_SAUDE) /
            100;

    return (saudeInicioSessao - saudePerdida).clamp(0.0, 100.0);
  }

  /// Verifica se deve ativar CHECKPOINT (água OU energia = 0)
  bool get deveAtivarCheckpoint => energia <= 0 || agua <= 0;

  /// Verifica se deve ativar GAME OVER (saúde = 0)
  bool get deveAtivarGameOver => calcularSaudeAtual() <= 0;

  /// Verifica se está vivo (para compatibilidade)
  bool get estaVivo => !deveAtivarGameOver;

  /// Converte para Map (compatibilidade com UI atual)
  Map<String, double> toMap() {
    return {
      'energia': energia,
      'agua': agua,
      'saude': calcularSaudeAtual(),
    };
  }

  @override
  String toString() {
    return 'Recursos(E: ${energia.toStringAsFixed(1)}%, A: ${agua.toStringAsFixed(1)}%, S: ${calcularSaudeAtual().toStringAsFixed(1)}%)';
  }
}

// ===== NOTIFIER DOS RECURSOS V7.3 =====
class RecursosNotifier extends StateNotifier<RecursosState> {
  final Ref ref;

  RecursosNotifier(this.ref) : super(const RecursosState());

  // ===== INICIALIZAÇÃO =====

  /// Inicializa recursos para nova sessão
  void iniciarSessao(double saudeAtual) {
    state = RecursosState(
      energia: 100.0,
      agua: 100.0,
      energiaPerdidaSessao: 0.0,
      aguaPerdidaSessao: 0.0,
      saudeInicioSessao: saudeAtual,
    );

    print(
        '🎮 Recursos iniciados: E=100%, A=100%, S=${saudeAtual.toStringAsFixed(1)}%');
  }

  // ===== AÇÕES V7.3 =====

  /// Registra um ACERTO
  /// V7.3: +5% Água e +5% Energia (se < 100%)
  void registrarAcerto() {
    final novaEnergia =
        (state.energia + RecursosConstants.GANHO_ACERTO).clamp(0.0, 100.0);
    final novaAgua =
        (state.agua + RecursosConstants.GANHO_ACERTO).clamp(0.0, 100.0);

    state = state.copyWith(
      energia: novaEnergia,
      agua: novaAgua,
    );

    print(
        '✅ Acerto: E=${novaEnergia.toStringAsFixed(0)}% A=${novaAgua.toStringAsFixed(0)}% S=${state.calcularSaudeAtual().toStringAsFixed(1)}%');
  }

  /// Registra um ERRO
  /// ✅ V7.3: -20% Água (era -10%)
  void registrarErro() {
    final perdaAgua = RecursosConstants.PERDA_ERRO_AGUA; // 20%
    final novaAgua = (state.agua - perdaAgua).clamp(0.0, 100.0);
    final novaAguaPerdida = state.aguaPerdidaSessao + perdaAgua;

    state = state.copyWith(
      agua: novaAgua,
      aguaPerdidaSessao: novaAguaPerdida,
    );

    print(
        '❌ Erro: E=${state.energia.toStringAsFixed(0)}% A=${novaAgua.toStringAsFixed(0)}% S=${state.calcularSaudeAtual().toStringAsFixed(1)}%');
    print(
        '   Água perdida sessão: ${novaAguaPerdida.toStringAsFixed(0)}% (-${perdaAgua.toInt()}%)');
  }

  /// Registra um TIMEOUT
  /// ✅ V7.3: -20% Energia (era -10%)
  void registrarTimeout() {
    final perdaEnergia = RecursosConstants.PERDA_TIMEOUT_ENERGIA; // 20%
    final novaEnergia = (state.energia - perdaEnergia).clamp(0.0, 100.0);
    final novaEnergiaPerdida = state.energiaPerdidaSessao + perdaEnergia;

    state = state.copyWith(
      energia: novaEnergia,
      energiaPerdidaSessao: novaEnergiaPerdida,
    );

    print(
        '⏰ Timeout: E=${novaEnergia.toStringAsFixed(0)}% A=${state.agua.toStringAsFixed(0)}% S=${state.calcularSaudeAtual().toStringAsFixed(1)}%');
    print(
        '   Energia perdida sessão: ${novaEnergiaPerdida.toStringAsFixed(0)}% (-${perdaEnergia.toInt()}%)');
  }

  // ===== CHECKPOINT =====

  /// Aplica checkpoint: reseta água e energia, mantém tracking de saúde
  void aplicarCheckpoint() {
    // Saúde atual vira a nova saúde inicial
    final saudeAtual = state.calcularSaudeAtual();

    state = RecursosState(
      energia: 100.0,
      agua: 100.0,
      energiaPerdidaSessao: 0.0,
      aguaPerdidaSessao: 0.0,
      saudeInicioSessao: saudeAtual, // Mantém a saúde atual
    );

    print(
        '⚠️ CHECKPOINT: Recursos resetados. Saúde mantida em ${saudeAtual.toStringAsFixed(1)}%');
  }

  // ===== GAME OVER =====

  /// Aplica game over: reseta tudo para 100%
  void aplicarGameOver() {
    state = const RecursosState(
      energia: 100.0,
      agua: 100.0,
      energiaPerdidaSessao: 0.0,
      aguaPerdidaSessao: 0.0,
      saudeInicioSessao: 100.0,
    );

    print('💀 GAME OVER: Todos recursos resetados para 100%');
  }

  // ===== GETTERS PARA UI =====

  /// Retorna saúde atual calculada
  double get saudeAtual => state.calcularSaudeAtual();

  /// Retorna energia atual
  double get energiaAtual => state.energia;

  /// Retorna água atual
  double get aguaAtual => state.agua;

  /// Verifica se está vivo
  bool get estaVivo => state.estaVivo;

  /// Verifica checkpoint
  bool get deveAtivarCheckpoint => state.deveAtivarCheckpoint;

  /// Verifica game over
  bool get deveAtivarGameOver => state.deveAtivarGameOver;

  // ===== COMPATIBILIDADE COM CÓDIGO ANTIGO =====

  /// Método de compatibilidade (será removido depois)
  /// DEPRECATED: Use registrarAcerto(), registrarErro(), registrarTimeout()
  void atualizarRecursos(bool acertou, {bool isTimeout = false}) {
    if (isTimeout) {
      registrarTimeout();
    } else if (acertou) {
      registrarAcerto();
    } else {
      registrarErro();
    }
  }

  /// Reset recursos (compatibilidade)
  void resetRecursos() {
    state = const RecursosState();
  }
}

// ===== PROVIDER RIVERPOD =====
final recursosProvider =
    StateNotifierProvider<RecursosNotifier, RecursosState>((ref) {
  return RecursosNotifier(ref);
});

// ===== PROVIDER DE COMPATIBILIDADE =====
// Para manter compatibilidade com o código antigo que usa Map<String, double>
final recursosPersonalizadosProvider = StateNotifierProvider<
    RecursosPersonalizadosNotifierV71, Map<String, double>>((ref) {
  return RecursosPersonalizadosNotifierV71(ref);
});

// ===== CHAVES SHAREDPREFERENCES =====
const _kRecursosAgua = 'studyquest_recursos_agua';
const _kRecursosEnergia = 'studyquest_recursos_energia';
const _kRecursosSaudeInicio = 'studyquest_recursos_saude_inicio';
const _kRecursosAguaPerdida = 'studyquest_recursos_agua_perdida';
const _kRecursosEnergiaPerdida = 'studyquest_recursos_energia_perdida';

/// Notifier de compatibilidade que mantém a interface Map<String, double>
/// mas usa a lógica V7.3 internamente
class RecursosPersonalizadosNotifierV71
    extends StateNotifier<Map<String, double>> {
  final Ref ref;

  // Estado interno V7.3
  double _energia = 100.0;
  double _agua = 100.0;
  double _energiaPerdidaSessao = 0.0;
  double _aguaPerdidaSessao = 0.0;
  double _saudeInicioSessao = 100.0;

  RecursosPersonalizadosNotifierV71(this.ref)
      : super({
          'energia': 100.0,
          'agua': 100.0,
          'saude': 100.0,
        }) {
    _carregarRecursos();
  }

  /// Carrega recursos do SharedPreferences (persiste após F5)
  Future<void> _carregarRecursos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final aguaSalva = prefs.getDouble(_kRecursosAgua);
      final energiaSalva = prefs.getDouble(_kRecursosEnergia);
      final saudeSalva = prefs.getDouble(_kRecursosSaudeInicio);

      // 🔍 DEBUG: mostrar o que foi encontrado no SharedPreferences
      print('🔍 [RECURSOS] SharedPreferences keys: ${prefs.getKeys().where((k) => k.startsWith("studyquest_recursos"))}');
      print('🔍 [RECURSOS] agua=$aguaSalva energia=$energiaSalva saudeInicio=$saudeSalva');

      _agua = aguaSalva ?? 100.0;
      _energia = energiaSalva ?? 100.0;
      _saudeInicioSessao = saudeSalva ?? 100.0;
      _aguaPerdidaSessao = prefs.getDouble(_kRecursosAguaPerdida) ?? 0.0;
      _energiaPerdidaSessao = prefs.getDouble(_kRecursosEnergiaPerdida) ?? 0.0;

      if (mounted) _atualizarState();
      print('📦 [RECURSOS] Carregados: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
    } catch (e) {
      print('⚠️ [RECURSOS] Erro ao carregar: $e');
    }
  }

  /// Salva recursos no SharedPreferences (fire-and-forget)
  Future<void> _salvarRecursos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kRecursosAgua, _agua);
      await prefs.setDouble(_kRecursosEnergia, _energia);
      await prefs.setDouble(_kRecursosSaudeInicio, _saudeInicioSessao);
      await prefs.setDouble(_kRecursosAguaPerdida, _aguaPerdidaSessao);
      await prefs.setDouble(_kRecursosEnergiaPerdida, _energiaPerdidaSessao);
      print('💾 [RECURSOS] Salvos: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
    } catch (e) {
      print('⚠️ [RECURSOS] Erro ao salvar: $e');
    }
  }

  /// Inicializa para nova sessão (mantém saúde persistida)
  void iniciarSessao() {
    // Saúde persiste entre sessões — mantém o valor atual (já carregado do SharedPreferences)
    // Água e Energia são temporários — resetam por sessão
    _energia = 100.0;
    _agua = 100.0;
    _energiaPerdidaSessao = 0.0;
    _aguaPerdidaSessao = 0.0;

    _atualizarState();
    print(
        '🎮 Recursos V7.3 iniciados: E=100%, A=100%, S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
  }

  /// Calcula saúde atual com fórmula V7.1
  double _calcularSaudeAtual() {
    final saudePerdida =
        (_aguaPerdidaSessao * RecursosConstants.PESO_AGUA_SAUDE +
                _energiaPerdidaSessao * RecursosConstants.PESO_ENERGIA_SAUDE) /
            100;

    return (_saudeInicioSessao - saudePerdida).clamp(0.0, 100.0);
  }

  /// Atualiza o state Map para a UI e persiste no SharedPreferences
  void _atualizarState() {
    state = {
      'energia': _energia,
      'agua': _agua,
      'saude': _calcularSaudeAtual(),
    };
    _salvarRecursos(); // fire-and-forget
  }

  /// Método principal de atualização (compatibilidade + V7.3)
  void atualizarRecursos(bool acertou, {bool isTimeout = false}) {
    if (isTimeout) {
      // ✅ V7.3: TIMEOUT: -20% energia (era -10%)
      _energia = (_energia - RecursosConstants.PERDA_TIMEOUT_ENERGIA)
          .clamp(0.0, 100.0);
      _energiaPerdidaSessao += RecursosConstants.PERDA_TIMEOUT_ENERGIA;

      print(
          '⏰ Timeout V7.3: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}% (-20% energia)');
    } else if (acertou) {
      // ACERTO: +5% água e energia
      _energia = (_energia + RecursosConstants.GANHO_ACERTO).clamp(0.0, 100.0);
      _agua = (_agua + RecursosConstants.GANHO_ACERTO).clamp(0.0, 100.0);

      print(
          '✅ Acerto V7.3: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
    } else {
      // ✅ V7.3: ERRO: -20% água (era -10%)
      _agua = (_agua - RecursosConstants.PERDA_ERRO_AGUA).clamp(0.0, 100.0);
      _aguaPerdidaSessao += RecursosConstants.PERDA_ERRO_AGUA;

      print(
          '❌ Erro V7.3: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}% (-20% água)');
    }

    _atualizarState();

    // Atualizar saúde global no provider de sessão
    _atualizarSaudeGlobal();
  }

  /// Atualiza saúde no provider de sessão
  void _atualizarSaudeGlobal() {
    try {
      ref
          .read(sessaoUsuarioProvider.notifier)
          .atualizarSaude(_calcularSaudeAtual());
    } catch (e) {
      print('⚠️ Erro ao atualizar saúde global: $e');
    }
  }

  /// Verifica se deve ativar checkpoint
  bool get deveAtivarCheckpoint => _energia <= 0 || _agua <= 0;

  /// Verifica se deve ativar game over
  bool get deveAtivarGameOver => _calcularSaudeAtual() <= 0;

  /// Verifica se está vivo
  bool get estaVivo => !deveAtivarGameOver;

  /// Aplica checkpoint
  void aplicarCheckpoint() {
    // Salva saúde atual como novo início
    _saudeInicioSessao = _calcularSaudeAtual();

    // Reseta recursos temporários
    _energia = 100.0;
    _agua = 100.0;
    _energiaPerdidaSessao = 0.0;
    _aguaPerdidaSessao = 0.0;

    _atualizarState();
    print(
        '⚠️ CHECKPOINT V7.3: Recursos resetados. Saúde=${_saudeInicioSessao.toStringAsFixed(1)}%');
  }

  /// Aplica game over
  void aplicarGameOver() {
    _energia = 100.0;
    _agua = 100.0;
    _energiaPerdidaSessao = 0.0;
    _aguaPerdidaSessao = 0.0;
    _saudeInicioSessao = 100.0;

    _atualizarState();

    // Atualizar saúde global para 100
    try {
      ref.read(sessaoUsuarioProvider.notifier).atualizarSaude(100.0);
    } catch (e) {
      print('⚠️ Erro ao resetar saúde global: $e');
    }

    print('💀 GAME OVER V7.3: Todos recursos resetados para 100%');
  }

  /// Reset recursos
  void resetRecursos() {
    iniciarSessao();
  }

  /// Getters para valores atuais
  double get energiaAtual => _energia;
  double get aguaAtual => _agua;
  double get saudeAtual => _calcularSaudeAtual();
}
