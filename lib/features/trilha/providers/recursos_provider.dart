import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recursos_vitais.dart';

final recursosProvider =
    StateNotifierProvider<RecursosNotifier, RecursosVitais>((ref) {
  return RecursosNotifier();
});

class RecursosNotifier extends StateNotifier<RecursosVitais> {
  RecursosNotifier()
      : super(const RecursosVitais(energia: 100, agua: 100, saude: 100));

  void acerto() {
    state = state.ajustar(energiaDelta: 5, aguaDelta: 5, saudeDelta: 5);
  }

  void erro() {
    state = state.ajustar(energiaDelta: -10, aguaDelta: -10, saudeDelta: -10);
  }

  void reset() {
    state = const RecursosVitais(energia: 100, agua: 100, saude: 100);
  }

  bool get isGameOver => !state.estaVivo;
}
