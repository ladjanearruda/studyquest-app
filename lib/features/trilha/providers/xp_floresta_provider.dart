import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ PROVIDER PARA XP DA TRILHA FLORESTA
final xpFlorestaProvider =
    StateNotifierProvider<XpFlorestaNotifier, XpFlorestaState>((ref) {
  return XpFlorestaNotifier();
});

class XpFlorestaState {
  final int xpTotal;
  final int questoesCorretas;
  final int questoesTentadas;
  final int nivel;

  const XpFlorestaState({
    this.xpTotal = 0,
    this.questoesCorretas = 0,
    this.questoesTentadas = 0,
    this.nivel = 1,
  });

  double get porcentagemAcerto =>
      questoesTentadas > 0 ? questoesCorretas / questoesTentadas : 0.0;
  int get xpAtualNoNivel => xpTotal % 100; // XP no nível atual (0-99)
  double get progressoNivel => xpAtualNoNivel / 100.0;
  int get xpParaProximoNivel => 100 - xpAtualNoNivel;

  XpFlorestaState copyWith({
    int? xpTotal,
    int? questoesCorretas,
    int? questoesTentadas,
    int? nivel,
  }) {
    return XpFlorestaState(
      xpTotal: xpTotal ?? this.xpTotal,
      questoesCorretas: questoesCorretas ?? this.questoesCorretas,
      questoesTentadas: questoesTentadas ?? this.questoesTentadas,
      nivel: nivel ?? this.nivel,
    );
  }
}

class XpFlorestaNotifier extends StateNotifier<XpFlorestaState> {
  XpFlorestaNotifier() : super(const XpFlorestaState());

  int adicionarXP(bool acertou, {int bonusVelocidade = 0}) {
    int xpGanho = 0;

    if (acertou) {
      xpGanho = 15 + bonusVelocidade; // 15 XP base + bônus de velocidade
    } else {
      xpGanho = 3; // XP de consolação por tentar
    }

    final novoXpTotal = state.xpTotal + xpGanho;
    final novoNivel = (novoXpTotal ~/ 100) + 1;
    final novasCorretas =
        acertou ? state.questoesCorretas + 1 : state.questoesCorretas;

    state = state.copyWith(
      xpTotal: novoXpTotal,
      questoesCorretas: novasCorretas,
      questoesTentadas: state.questoesTentadas + 1,
      nivel: novoNivel,
    );

    return xpGanho; // Retorna XP ganho para animação
  }

  void reset() {
    state = const XpFlorestaState();
  }

  // 🔧 ADICIONADO: Método resetar que chama reset
  void resetar() {
    reset();
  }
}
