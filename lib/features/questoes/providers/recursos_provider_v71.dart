// lib/features/questoes/providers/recursos_provider_v71.dart
// ✅ V7.1 - Sistema de Recursos com Fórmula Correta
// SUBSTITUI: recursosPersonalizadosProvider no questao_personalizada_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sessao_usuario_provider.dart';

// ===== ESTADO DOS RECURSOS V7.1 =====
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
    final saudePerdida = (aguaPerdidaSessao * GameConstants.PESO_AGUA_SAUDE +
            energiaPerdidaSessao * GameConstants.PESO_ENERGIA_SAUDE) /
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

// ===== NOTIFIER DOS RECURSOS V7.1 =====
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

    print('🎮 Recursos iniciados: E=100%, A=100%, S=${saudeAtual.toStringAsFixed(1)}%');
  }

  // ===== AÇÕES V7.1 =====

  /// Registra um ACERTO
  /// V7.1: +5% Água e +5% Energia (se < 100%)
  void registrarAcerto() {
    final novaEnergia =
        (state.energia + GameConstants.GANHO_ACERTO).clamp(0.0, 100.0);
    final novaAgua =
        (state.agua + GameConstants.GANHO_ACERTO).clamp(0.0, 100.0);

    state = state.copyWith(
      energia: novaEnergia,
      agua: novaAgua,
    );

    print('✅ Acerto: E=${novaEnergia.toStringAsFixed(0)}% A=${novaAgua.toStringAsFixed(0)}% S=${state.calcularSaudeAtual().toStringAsFixed(1)}%');
  }

  /// Registra um ERRO
  /// V7.1: -10% Água apenas (NÃO afeta energia diretamente)
  void registrarErro() {
    final perdaAgua = GameConstants.PERDA_ERRO_AGUA;
    final novaAgua = (state.agua - perdaAgua).clamp(0.0, 100.0);
    final novaAguaPerdida = state.aguaPerdidaSessao + perdaAgua;

    state = state.copyWith(
      agua: novaAgua,
      aguaPerdidaSessao: novaAguaPerdida,
    );

    print('❌ Erro: E=${state.energia.toStringAsFixed(0)}% A=${novaAgua.toStringAsFixed(0)}% S=${state.calcularSaudeAtual().toStringAsFixed(1)}%');
    print('   Água perdida sessão: ${novaAguaPerdida.toStringAsFixed(0)}%');
  }

  /// Registra um TIMEOUT
  /// V7.1: -10% Energia apenas (NÃO afeta água diretamente)
  void registrarTimeout() {
    final perdaEnergia = GameConstants.PERDA_TIMEOUT_ENERGIA;
    final novaEnergia = (state.energia - perdaEnergia).clamp(0.0, 100.0);
    final novaEnergiaPerdida = state.energiaPerdidaSessao + perdaEnergia;

    state = state.copyWith(
      energia: novaEnergia,
      energiaPerdidaSessao: novaEnergiaPerdida,
    );

    print('⏰ Timeout: E=${novaEnergia.toStringAsFixed(0)}% A=${state.agua.toStringAsFixed(0)}% S=${state.calcularSaudeAtual().toStringAsFixed(1)}%');
    print('   Energia perdida sessão: ${novaEnergiaPerdida.toStringAsFixed(0)}%');
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

    print('⚠️ CHECKPOINT: Recursos resetados. Saúde mantida em ${saudeAtual.toStringAsFixed(1)}%');
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
final recursosPersonalizadosProvider =
    StateNotifierProvider<RecursosPersonalizadosNotifierV71, Map<String, double>>(
        (ref) {
  return RecursosPersonalizadosNotifierV71(ref);
});

/// Notifier de compatibilidade que mantém a interface Map<String, double>
/// mas usa a lógica V7.1 internamente
class RecursosPersonalizadosNotifierV71
    extends StateNotifier<Map<String, double>> {
  final Ref ref;

  // Estado interno V7.1
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
    _carregarSaudeInicial();
  }

  /// Carrega saúde inicial do provider de sessão
  void _carregarSaudeInicial() {
    try {
      final sessao = ref.read(sessaoUsuarioProvider);
      _saudeInicioSessao = sessao.saudeGlobal;
      _atualizarState();
    } catch (e) {
      print('⚠️ Erro ao carregar saúde inicial: $e');
    }
  }

  /// Inicializa para nova sessão
  void iniciarSessao() {
    try {
      final sessao = ref.read(sessaoUsuarioProvider);
      _saudeInicioSessao = sessao.saudeGlobal;
    } catch (e) {
      _saudeInicioSessao = 100.0;
    }

    _energia = 100.0;
    _agua = 100.0;
    _energiaPerdidaSessao = 0.0;
    _aguaPerdidaSessao = 0.0;

    _atualizarState();
    print('🎮 Recursos V7.1 iniciados: E=100%, A=100%, S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
  }

  /// Calcula saúde atual com fórmula V7.1
  double _calcularSaudeAtual() {
    final saudePerdida = (_aguaPerdidaSessao * GameConstants.PESO_AGUA_SAUDE +
            _energiaPerdidaSessao * GameConstants.PESO_ENERGIA_SAUDE) /
        100;

    return (_saudeInicioSessao - saudePerdida).clamp(0.0, 100.0);
  }

  /// Atualiza o state Map para a UI
  void _atualizarState() {
    state = {
      'energia': _energia,
      'agua': _agua,
      'saude': _calcularSaudeAtual(),
    };
  }

  /// Método principal de atualização (compatibilidade + V7.1)
  void atualizarRecursos(bool acertou, {bool isTimeout = false}) {
    if (isTimeout) {
      // TIMEOUT: -10% energia apenas
      _energia = (_energia - GameConstants.PERDA_TIMEOUT_ENERGIA).clamp(0.0, 100.0);
      _energiaPerdidaSessao += GameConstants.PERDA_TIMEOUT_ENERGIA;

      print('⏰ Timeout V7.1: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
    } else if (acertou) {
      // ACERTO: +5% água e energia
      _energia = (_energia + GameConstants.GANHO_ACERTO).clamp(0.0, 100.0);
      _agua = (_agua + GameConstants.GANHO_ACERTO).clamp(0.0, 100.0);

      print('✅ Acerto V7.1: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
    } else {
      // ERRO: -10% água apenas
      _agua = (_agua - GameConstants.PERDA_ERRO_AGUA).clamp(0.0, 100.0);
      _aguaPerdidaSessao += GameConstants.PERDA_ERRO_AGUA;

      print('❌ Erro V7.1: E=${_energia.toStringAsFixed(0)}% A=${_agua.toStringAsFixed(0)}% S=${_calcularSaudeAtual().toStringAsFixed(1)}%');
    }

    _atualizarState();

    // Atualizar saúde global no provider de sessão
    _atualizarSaudeGlobal();
  }

  /// Atualiza saúde no provider de sessão
  void _atualizarSaudeGlobal() {
    try {
      ref.read(sessaoUsuarioProvider.notifier).atualizarSaude(_calcularSaudeAtual());
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
    print('⚠️ CHECKPOINT V7.1: Recursos resetados. Saúde=${_saudeInicioSessao.toStringAsFixed(1)}%');
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

    print('💀 GAME OVER V7.1: Todos recursos resetados para 100%');
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