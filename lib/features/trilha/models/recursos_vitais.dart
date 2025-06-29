// lib/features/trilha/models/recursos_vitais.dart
class RecursosVitais {
  final int energia;
  final int agua;
  final int saude;

  const RecursosVitais({
    required this.energia,
    required this.agua,
    required this.saude,
  });

  RecursosVitais ajustar(
      {int energiaDelta = 0, int aguaDelta = 0, int saudeDelta = 0}) {
    return RecursosVitais(
      energia: (energia + energiaDelta).clamp(0, 100),
      agua: (agua + aguaDelta).clamp(0, 100),
      saude: (saude + saudeDelta).clamp(0, 100),
    );
  }

  bool get estaVivo => energia > 0 && agua > 0 && saude > 0;
}
