// lib/features/trilha/models/questao_trilha.dart
class QuestaoTrilha {
  final int id;
  final String enunciado;
  final List<String> opcoes;
  final int respostaCorreta; // índice da opção correta
  final String explicacao;

  QuestaoTrilha({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
    required this.explicacao,
  });
}
