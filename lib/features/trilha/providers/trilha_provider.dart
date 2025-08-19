import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progresso_trilha.dart';

final progressoProvider = StateProvider<ProgressoTrilha>((ref) {
  return ProgressoTrilha(checkpointAtual: 0, xp: 0);
});
