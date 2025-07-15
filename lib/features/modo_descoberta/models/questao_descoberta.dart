// lib/features/modo_descoberta/models/questao_descoberta.dart

class QuestaoDescoberta {
  final String id;
  final String enunciado;
  final List<String> alternativas;
  final int respostaCorreta;
  final String explicacao;
  final String assunto;
  final int dificuldade; // 1-3
  final String?
      imagemEspecifica; // NOVO: Caminho para imagem específica da questão

  QuestaoDescoberta({
    required this.id,
    required this.enunciado,
    required this.alternativas,
    required this.respostaCorreta,
    required this.explicacao,
    required this.assunto,
    required this.dificuldade,
    this.imagemEspecifica, // Opcional - se null, usa imagem contextual
  });

  /// Verifica se a questão tem imagem específica
  bool get temImagemEspecifica => imagemEspecifica != null;

  /// Verifica se uma resposta está correta
  bool isRespostaCorreta(int indiceResposta) {
    return indiceResposta == respostaCorreta;
  }

  /// Retorna o caminho da imagem a ser usado (específica ou contextual)
  String getImagemPath() {
    if (imagemEspecifica != null) {
      return imagemEspecifica!;
    }

    // Se não tem imagem específica, usa lógica contextual baseada no assunto
    return _getImagemContextual();
  }

  /// Lógica para determinar imagem contextual baseada no assunto/conteúdo
  String _getImagemContextual() {
    final assunto = this.assunto.toLowerCase();
    final enunciado = this.enunciado.toLowerCase();

    // GEO - Geometria, área, perímetro, formas
    if (assunto.contains('área') ||
        assunto.contains('geometria') ||
        assunto.contains('perímetro') ||
        assunto.contains('quadrado') ||
        assunto.contains('triângulo') ||
        enunciado.contains('figura') ||
        enunciado.contains('forma')) {
      return 'assets/images/questoes/modo_descoberta/geo.jpg';
    }

    // LAB - Álgebra, equações, sistemas
    if (assunto.contains('equação') ||
        assunto.contains('álgebra') ||
        enunciado.contains('resolva') ||
        enunciado.contains('x =')) {
      return 'assets/images/questoes/modo_descoberta/lab.jpg';
    }

    // PATTERNS - Funções, sequências, gráficos
    if (assunto.contains('função') ||
        assunto.contains('sequência') ||
        assunto.contains('gráfico') ||
        enunciado.contains('f(x)')) {
      return 'assets/images/questoes/modo_descoberta/patterns.jpg';
    }

    // TECH - Probabilidade, estatística, porcentagem
    if (assunto.contains('probabilidade') ||
        assunto.contains('porcentagem') ||
        enunciado.contains('%') ||
        enunciado.contains('chance')) {
      return 'assets/images/questoes/modo_descoberta/tech.jpg';
    }

    // PRINCIPAL - Padrão para outros casos
    return 'assets/images/questoes/modo_descoberta/principal.jpg';
  }

  /// Cria uma cópia da questão com novos valores
  QuestaoDescoberta copyWith({
    String? id,
    String? enunciado,
    List<String>? alternativas,
    int? respostaCorreta,
    String? explicacao,
    String? assunto,
    int? dificuldade,
    String? imagemEspecifica,
  }) {
    return QuestaoDescoberta(
      id: id ?? this.id,
      enunciado: enunciado ?? this.enunciado,
      alternativas: alternativas ?? this.alternativas,
      respostaCorreta: respostaCorreta ?? this.respostaCorreta,
      explicacao: explicacao ?? this.explicacao,
      assunto: assunto ?? this.assunto,
      dificuldade: dificuldade ?? this.dificuldade,
      imagemEspecifica: imagemEspecifica ?? this.imagemEspecifica,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enunciado': enunciado,
      'alternativas': alternativas,
      'respostaCorreta': respostaCorreta,
      'explicacao': explicacao,
      'assunto': assunto,
      'dificuldade': dificuldade,
      'imagemEspecifica': imagemEspecifica,
    };
  }

  /// Cria instância a partir de JSON
  factory QuestaoDescoberta.fromJson(Map<String, dynamic> json) {
    return QuestaoDescoberta(
      id: json['id'],
      enunciado: json['enunciado'],
      alternativas: List<String>.from(json['alternativas']),
      respostaCorreta: json['respostaCorreta'],
      explicacao: json['explicacao'],
      assunto: json['assunto'],
      dificuldade: json['dificuldade'],
      imagemEspecifica: json['imagemEspecifica'],
    );
  }

  /// Para debug - representação em string
  @override
  String toString() {
    return 'QuestaoDescoberta{id: $id, assunto: $assunto, dificuldade: $dificuldade, temImagem: $temImagemEspecifica}';
  }

  /// Igualdade baseada no ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestaoDescoberta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
