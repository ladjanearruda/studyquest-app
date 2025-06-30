import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== MODELO DE ESTADO DO XP OCEÂNICO =====
class XpOceanoState {
  final int xpTotal;
  final int nivel;
  final int questoesRespondidas;
  final int questoesCorretas;

  XpOceanoState({
    this.xpTotal = 0,
    this.nivel = 1,
    this.questoesRespondidas = 0,
    this.questoesCorretas = 0,
  });

  // ===== PROPRIEDADES CALCULADAS =====

  /// XP necessário para o próximo nível (progressão oceânica)
  int get xpProximoNivel {
    return nivel * 100; // Cada nível requer 100 XP a mais
  }

  /// XP atual dentro do nível atual
  int get xpAtual {
    int xpNivelAnterior =
        ((nivel - 1) * nivel * 100) ~/ 2; // Soma dos XP dos níveis anteriores
    return xpTotal - xpNivelAnterior;
  }

  /// Progresso para o próximo nível (0.0 a 1.0)
  double get progressoNivel {
    if (xpProximoNivel == 0) return 0.0;
    return (xpAtual / xpProximoNivel).clamp(0.0, 1.0);
  }

  /// Percentual de acerto (precisão do mergulhador)
  double get porcentagemAcerto {
    if (questoesRespondidas == 0) return 0.0;
    return questoesCorretas / questoesRespondidas;
  }

  /// Título do mergulhador baseado no nível
  String get tituloMergulhador {
    if (nivel >= 10) return 'Mergulhador Lendário';
    if (nivel >= 7) return 'Explorador dos Abissos';
    if (nivel >= 5) return 'Mergulhador Experiente';
    if (nivel >= 3) return 'Mergulhador Intermediário';
    return 'Mergulhador Iniciante';
  }

  // ===== MÉTODOS DE CÓPIA =====

  XpOceanoState copyWith({
    int? xpTotal,
    int? nivel,
    int? questoesRespondidas,
    int? questoesCorretas,
  }) {
    return XpOceanoState(
      xpTotal: xpTotal ?? this.xpTotal,
      nivel: nivel ?? this.nivel,
      questoesRespondidas: questoesRespondidas ?? this.questoesRespondidas,
      questoesCorretas: questoesCorretas ?? this.questoesCorretas,
    );
  }
}

// ===== NOTIFIER DO XP OCEÂNICO =====
class XpOceanoNotifier extends StateNotifier<XpOceanoState> {
  XpOceanoNotifier() : super(XpOceanoState());

  /// Incrementa XP quando o mergulhador acerta uma questão
  void acerto() {
    const int xpPorAcerto = 10; // XP ganho por acerto
    int novoXpTotal = state.xpTotal + xpPorAcerto;
    int novoNivel = _calcularNivel(novoXpTotal);

    state = state.copyWith(
      xpTotal: novoXpTotal,
      nivel: novoNivel,
      questoesRespondidas: state.questoesRespondidas + 1,
      questoesCorretas: state.questoesCorretas + 1,
    );

    // Verifica se subiu de nível
    if (novoNivel > state.nivel) {
      _celebrarSubidaNivel(novoNivel);
    }
  }

  /// Registra erro (não ganha XP, mas conta para precisão)
  void erro() {
    state = state.copyWith(
      questoesRespondidas: state.questoesRespondidas + 1,
      // questoesCorretas não muda
    );
  }

  /// Reseta o progresso (para jogar novamente)
  void reset() {
    state = XpOceanoState();
  }

  /// Calcula o nível baseado no XP total
  int _calcularNivel(int xpTotal) {
    if (xpTotal < 100) return 1;
    if (xpTotal < 300) return 2; // 100 + 200
    if (xpTotal < 600) return 3; // 100 + 200 + 300
    if (xpTotal < 1000) return 4; // 100 + 200 + 300 + 400
    if (xpTotal < 1500) return 5; // ... + 500
    if (xpTotal < 2100) return 6; // ... + 600
    if (xpTotal < 2800) return 7; // ... + 700
    if (xpTotal < 3600) return 8; // ... + 800
    if (xpTotal < 4500) return 9; // ... + 900
    return 10; // Nível máximo
  }

  /// Celebra a subida de nível (pode ser expandido com animações)
  void _celebrarSubidaNivel(int novoNivel) {
    // TODO: Implementar celebração visual
    // Por exemplo: mostrar modal de parabéns, tocar som, etc.
    print('🎉 Mergulhador subiu para nível $novoNivel!');
  }

  /// Adiciona XP bônus (para conquistas especiais)
  void adicionarXpBonus(int xpBonus) {
    int novoXpTotal = state.xpTotal + xpBonus;
    int novoNivel = _calcularNivel(novoXpTotal);

    state = state.copyWith(
      xpTotal: novoXpTotal,
      nivel: novoNivel,
    );
  }

  /// Obtém estatísticas detalhadas
  Map<String, dynamic> get estatisticas {
    return {
      'xpTotal': state.xpTotal,
      'nivel': state.nivel,
      'tituloMergulhador': state.tituloMergulhador,
      'questoesRespondidas': state.questoesRespondidas,
      'questoesCorretas': state.questoesCorretas,
      'porcentagemAcerto': (state.porcentagemAcerto * 100).toInt(),
      'xpProximoNivel': state.xpProximoNivel,
      'progressoNivel': (state.progressoNivel * 100).toInt(),
    };
  }
}

// ===== PROVIDER PRINCIPAL =====
final xpOceanoProvider = StateNotifierProvider<XpOceanoNotifier, XpOceanoState>(
  (ref) => XpOceanoNotifier(),
);

// ===== PROVIDERS AUXILIARES PARA FACILITAR O USO =====

/// Provider que retorna apenas o nível atual
final nivelOceanoProvider = Provider<int>((ref) {
  return ref.watch(xpOceanoProvider).nivel;
});

/// Provider que retorna apenas o XP total
final xpTotalOceanoProvider = Provider<int>((ref) {
  return ref.watch(xpOceanoProvider).xpTotal;
});

/// Provider que retorna a porcentagem de acerto
final precisaoOceanoProvider = Provider<double>((ref) {
  return ref.watch(xpOceanoProvider).porcentagemAcerto;
});

/// Provider que retorna o título do mergulhador
final tituloMergulhadorProvider = Provider<String>((ref) {
  return ref.watch(xpOceanoProvider).tituloMergulhador;
});

/// Provider que retorna se o jogador pode subir de nível
final podeSubirNivelProvider = Provider<bool>((ref) {
  final state = ref.watch(xpOceanoProvider);
  return state.progressoNivel >= 1.0;
});

// ===== EXTENSÕES ÚTEIS =====

extension XpOceanoStateExtensions on XpOceanoState {
  /// Verifica se é um mergulhador experiente (nível 5+)
  bool get isExperiente => nivel >= 5;

  /// Verifica se tem alta precisão (80%+)
  bool get isAltaPrecisao => porcentagemAcerto >= 0.8;

  /// Verifica se é um mergulhador lendário
  bool get isLendario => nivel >= 10;

  /// Retorna a cor do nível baseada na progressão
  /// Útil para UI dinâmica
  String get corNivel {
    if (nivel >= 10) return '#FFD700'; // Dourado
    if (nivel >= 7) return '#00CED1'; // Turquesa
    if (nivel >= 5) return '#4169E1'; // Azul Royal
    if (nivel >= 3) return '#1E90FF'; // Azul Dodger
    return '#87CEEB'; // Azul Céu
  }
}
