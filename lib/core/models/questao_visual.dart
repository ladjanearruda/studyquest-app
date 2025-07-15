// lib/core/models/questao_visual.dart
class QuestaoVisual {
  final String questaoId;
  final String imagemPath;
  final String descricao;
  final String serie;
  final String tipo; // 'contextual' ou 'especifica'

  const QuestaoVisual({
    required this.questaoId,
    required this.imagemPath,
    required this.descricao,
    required this.serie,
    required this.tipo,
  });

  factory QuestaoVisual.fromJson(Map<String, dynamic> json) {
    return QuestaoVisual(
      questaoId: json['questaoId'] as String,
      imagemPath: json['imagemPath'] as String,
      descricao: json['descricao'] as String,
      serie: json['serie'] as String,
      tipo: json['tipo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questaoId': questaoId,
      'imagemPath': imagemPath,
      'descricao': descricao,
      'serie': serie,
      'tipo': tipo,
    };
  }
}
