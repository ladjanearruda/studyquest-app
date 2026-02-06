class QuestaoPersonalizada {
  final String id;
  final String subject;
  final String schoolLevel;
  final String difficulty;
  final String enunciado;
  final List<String> alternativas;
  final int respostaCorreta;
  final String explicacao;
  final String? imagemEspecifica;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const QuestaoPersonalizada({
    required this.id,
    required this.subject,
    required this.schoolLevel,
    required this.difficulty,
    required this.enunciado,
    required this.alternativas,
    required this.respostaCorreta,
    required this.explicacao,
    this.imagemEspecifica,
    required this.tags,
    required this.metadata,
  });

  // Conversão do Firebase
  factory QuestaoPersonalizada.fromFirestore(Map<String, dynamic> data) {
    return QuestaoPersonalizada(
      id: data['id'] ?? '',
      subject: data['subject'] ?? '',
      schoolLevel: data['school_level'] ?? '',
      difficulty: data['difficulty'] ?? '',
      enunciado: data['enunciado'] ?? '',
      alternativas: List<String>.from(data['alternativas'] ?? []),
      respostaCorreta: data['resposta_correta'] ?? 0,
      explicacao: data['explicacao'] ?? data['explanation'] ?? '',
      imagemEspecifica: data['imagem_especifica'],
      tags: List<String>.from(data['tags'] ?? []),
      metadata: data['metadata'] ?? {},
    );
  }
}

// Estado da sessão de questões
class SessaoQuestoes {
  final List<QuestaoPersonalizada> questoes;
  final int questaoAtual;
  final List<int> respostasUsuario;
  final List<bool> acertos;
  final DateTime inicioSessao;
  final bool sessaoFinalizada;

  const SessaoQuestoes({
    this.questoes = const [],
    this.questaoAtual = 0,
    this.respostasUsuario = const [],
    this.acertos = const [],
    required this.inicioSessao,
    this.sessaoFinalizada = false,
  });

  SessaoQuestoes copyWith({
    List<QuestaoPersonalizada>? questoes,
    int? questaoAtual,
    List<int>? respostasUsuario,
    List<bool>? acertos,
    DateTime? inicioSessao,
    bool? sessaoFinalizada,
  }) {
    return SessaoQuestoes(
      questoes: questoes ?? this.questoes,
      questaoAtual: questaoAtual ?? this.questaoAtual,
      respostasUsuario: respostasUsuario ?? this.respostasUsuario,
      acertos: acertos ?? this.acertos,
      inicioSessao: inicioSessao ?? this.inicioSessao,
      sessaoFinalizada: sessaoFinalizada ?? this.sessaoFinalizada,
    );
  }

  // Getters úteis
  QuestaoPersonalizada? get questaoAtualObj =>
      questaoAtual < questoes.length ? questoes[questaoAtual] : null;

  int get totalQuestoes => questoes.length;
  int get questoesCorretas => acertos.where((a) => a).length;
  double get porcentagemAcerto =>
      totalQuestoes > 0 ? questoesCorretas / totalQuestoes : 0;
  bool get temProximaQuestao => questaoAtual < questoes.length - 1;
}
