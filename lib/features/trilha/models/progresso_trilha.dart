// lib/features/trilha/models/progresso_trilha.dart
class ProgressoTrilha {
  final int checkpointAtual;
  final int xp;

  ProgressoTrilha({required this.checkpointAtual, required this.xp});

  ProgressoTrilha avancar({int xpGanho = 10}) {
    return ProgressoTrilha(
      checkpointAtual: checkpointAtual + 1,
      xp: xp + xpGanho,
    );
  }
}
