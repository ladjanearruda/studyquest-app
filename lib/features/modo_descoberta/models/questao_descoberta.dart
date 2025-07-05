// lib/features/modo_descoberta/models/questao_descoberta.dart

/// Modelo simplificado de questão para o Modo Descoberta
/// Otimizado para nivelamento rápido (5 questões em 2 minutos)
class QuestaoDescoberta {
  /// ID único da questão (ex: "6ano_001")
  final String id;

  /// Texto da questão contextualizada
  final String enunciado;

  /// Lista com exatamente 4 alternativas
  final List<String> alternativas;

  /// Índice da resposta correta (0-3)
  final int respostaCorreta;

  /// Explicação didática da resposta
  final String explicacao;

  /// Assunto/tópico da questão (ex: "Frações", "Equações")
  final String assunto;

  /// Nível de dificuldade (1=Fácil, 2=Médio, 3=Difícil)
  final int dificuldade;

  const QuestaoDescoberta({
    required this.id,
    required this.enunciado,
    required this.alternativas,
    required this.respostaCorreta,
    required this.explicacao,
    required this.assunto,
    required this.dificuldade,
  });

  /// Factory para criar a partir de JSON (futuro backend)
  factory QuestaoDescoberta.fromJson(Map<String, dynamic> json) {
    return QuestaoDescoberta(
      id: json['id'] as String,
      enunciado: json['enunciado'] as String,
      alternativas: List<String>.from(json['alternativas']),
      respostaCorreta: json['resposta_correta'] as int,
      explicacao: json['explicacao'] as String,
      assunto: json['assunto'] as String,
      dificuldade: json['dificuldade'] as int,
    );
  }

  /// Converte para JSON (futuro analytics)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enunciado': enunciado,
      'alternativas': alternativas,
      'resposta_correta': respostaCorreta,
      'explicacao': explicacao,
      'assunto': assunto,
      'dificuldade': dificuldade,
    };
  }

  /// Verifica se uma resposta está correta
  bool isRespostaCorreta(int indiceEscolhido) {
    return indiceEscolhido == respostaCorreta;
  }

  /// Retorna o texto da alternativa correta
  String get alternativaCorreta => alternativas[respostaCorreta];

  /// Retorna o texto da alternativa escolhida
  String getAlternativaEscolhida(int indice) {
    if (indice < 0 || indice >= alternativas.length) {
      return 'Alternativa inválida';
    }
    return alternativas[indice];
  }

  /// Validação básica da questão
  bool get isValida {
    return id.isNotEmpty &&
        enunciado.isNotEmpty &&
        alternativas.length == 4 &&
        respostaCorreta >= 0 &&
        respostaCorreta < 4 &&
        explicacao.isNotEmpty &&
        assunto.isNotEmpty &&
        dificuldade >= 1 &&
        dificuldade <= 3;
  }

  /// Retorna emoji baseado na dificuldade
  String get emojiDificuldade {
    switch (dificuldade) {
      case 1:
        return '🟢'; // Fácil
      case 2:
        return '🟡'; // Médio
      case 3:
        return '🔴'; // Difícil
      default:
        return '⚪'; // Desconhecido
    }
  }

  /// Retorna texto da dificuldade
  String get textoDificuldade {
    switch (dificuldade) {
      case 1:
        return 'Fácil';
      case 2:
        return 'Médio';
      case 3:
        return 'Difícil';
      default:
        return 'Desconhecido';
    }
  }

  @override
  String toString() {
    return 'QuestaoDescoberta(id: $id, assunto: $assunto, dificuldade: $dificuldade)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestaoDescoberta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Copia a questão com modificações opcionais
  QuestaoDescoberta copyWith({
    String? id,
    String? enunciado,
    List<String>? alternativas,
    int? respostaCorreta,
    String? explicacao,
    String? assunto,
    int? dificuldade,
  }) {
    return QuestaoDescoberta(
      id: id ?? this.id,
      enunciado: enunciado ?? this.enunciado,
      alternativas: alternativas ?? this.alternativas,
      respostaCorreta: respostaCorreta ?? this.respostaCorreta,
      explicacao: explicacao ?? this.explicacao,
      assunto: assunto ?? this.assunto,
      dificuldade: dificuldade ?? this.dificuldade,
    );
  }
}
