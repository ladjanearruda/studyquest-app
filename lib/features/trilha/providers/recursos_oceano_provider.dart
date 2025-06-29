import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recursos_oceano.dart';

final recursosOceanoProvider =
    StateNotifierProvider<RecursosOceanoNotifier, RecursosOceano>((ref) {
  return RecursosOceanoNotifier();
});

class RecursosOceanoNotifier extends StateNotifier<RecursosOceano> {
  RecursosOceanoNotifier()
      : super(const RecursosOceano(
            pressao: 100, oxigenio: 100, temperatura: 100));

  void acerto() {
    state =
        state.ajustar(pressaoDelta: 5, oxigenioDelta: 5, temperaturaDelta: 5);
  }

  void erro() {
    state = state.ajustar(
        pressaoDelta: -10, oxigenioDelta: -10, temperaturaDelta: -10);
  }

  void reset() {
    state = const RecursosOceano(pressao: 100, oxigenio: 100, temperatura: 100);
  }

  bool get isGameOver => !state.estaVivo;
}
