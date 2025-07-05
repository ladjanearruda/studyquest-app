// lib/features/modo_descoberta/models/modo_descoberta_result.dart

import '../models/questao_descoberta.dart';
import '../providers/modo_descoberta_provider.dart';
import '../../onboarding/screens/onboarding_screen.dart';

/// Resultado completo do Modo Descoberta com analytics
class ModoDescobertaResult {
  // Informações básicas
  final EducationLevel nivelEscolar;
  final NivelDetectado nivelDetectado;

  // Performance
  final int acertos;
  final int totalQuestoes;
  final int porcentagemAcerto;
  final Duration tempoTotal;

  // Dados detalhados para analytics
  final List<QuestaoDescoberta> questoesRespondidas;
  final List<int> respostasEscolhidas; // Índices das alternativas escolhidas
  final List<bool> detalhesAcertos; // true/false para cada questão

  // Metadados
  final DateTime dataRealizacao;

  const ModoDescobertaResult({
    required this.nivelEscolar,
    required this.nivelDetectado,
    required this.acertos,
    required this.totalQuestoes,
    required this.porcentagemAcerto,
    required this.tempoTotal,
    required this.questoesRespondidas,
    required this.respostasEscolhidas,
    required this.detalhesAcertos,
    required this.dataRealizacao,
  });

  /// Texto do nível escolar
  String get textoNivelEscolar {
    switch (nivelEscolar) {
      case EducationLevel.fundamental6:
        return '6º ano';
      case EducationLevel.fundamental7:
        return '7º ano';
      case EducationLevel.fundamental8:
        return '8º ano';
      case EducationLevel.fundamental9:
        return '9º ano';
      case EducationLevel.medio1:
        return '1º ano EM';
      case EducationLevel.medio2:
        return '2º ano EM';
      case EducationLevel.medio3:
        return '3º ano EM';
      case EducationLevel.completed:
        return 'Ensino Médio Completo';
    }
  }

  /// Resultado formatado para exibição
  String get resultadoFormatado {
    return '${nivelDetectado.titulo} do $textoNivelEscolar';
  }

  /// Mensagem personalizada baseada na performance
  String get mensagemPersonalizada {
    if (porcentagemAcerto >= 80) {
      return 'Excelente! Você tem ótimo domínio dos conceitos do $textoNivelEscolar! 🎉';
    } else if (porcentagemAcerto >= 60) {
      return 'Muito bem! Você está no caminho certo no $textoNivelEscolar! 📚';
    } else if (porcentagemAcerto >= 40) {
      return 'Bom início! Vamos reforçar alguns conceitos do $textoNivelEscolar! 🌱';
    } else {
      return 'Que tal começarmos devagar? Vamos construir uma base sólida! 🔰';
    }
  }

  /// Tempo médio por questão
  Duration get tempoMedioPorQuestao {
    if (totalQuestoes == 0) return Duration.zero;
    return Duration(
      milliseconds: tempoTotal.inMilliseconds ~/ totalQuestoes,
    );
  }

  /// Tempo formatado para exibição
  String get tempoFormatado {
    final minutos = tempoTotal.inMinutes;
    final segundos = tempoTotal.inSeconds % 60;

    if (minutos > 0) {
      return '${minutos}min ${segundos}s';
    } else {
      return '${segundos}s';
    }
  }

  /// Badge conquistado
  String get badgeConquistado => 'Autoconhecimento 🧭';

  /// Descrição da badge
  String get badgeDescricao =>
      'Concedido por descobrir seu nível de conhecimento!';

  /// Cor baseada na performance
  String get corPerformance {
    if (porcentagemAcerto >= 80) return '#00C851'; // Verde
    if (porcentagemAcerto >= 60) return '#007BFF'; // Azul
    if (porcentagemAcerto >= 40) return '#FF6B00'; // Laranja
    return '#6F42C1'; // Roxo
  }

  /// Emoji baseado na performance
  String get emojiPerformance {
    if (porcentagemAcerto >= 80) return '🏆';
    if (porcentagemAcerto >= 60) return '🎯';
    if (porcentagemAcerto >= 40) return '📚';
    return '🌱';
  }

  /// Sugestões personalizadas
  List<String> get sugestoes {
    final sugestoes = <String>[];

    if (porcentagemAcerto >= 80) {
      sugestoes.addAll([
        'Você pode tentar questões mais desafiadoras!',
        'Que tal explorar olimpíadas de matemática?',
        'Considere ser monitor/tutor dos colegas!',
      ]);
    } else if (porcentagemAcerto >= 60) {
      sugestoes.addAll([
        'Continue praticando para dominar totalmente o conteúdo!',
        'Foque nos tópicos que teve mais dificuldade.',
        'Busque exercícios extras dos assuntos estudados.',
      ]);
    } else if (porcentagemAcerto >= 40) {
      sugestoes.addAll([
        'Revise os conceitos fundamentais primeiro.',
        'Pratique mais exercícios básicos antes de avançar.',
        'Peça ajuda ao professor se tiver dúvidas.',
      ]);
    } else {
      sugestoes.addAll([
        'Comece com o básico e vá avançando gradualmente.',
        'Não tenha pressa - cada um tem seu ritmo!',
        'Busque apoio extra de professores ou tutores.',
      ]);
    }

    return sugestoes;
  }

  /// Análise detalhada por assunto
  Map<String, dynamic> get analiseAssuntos {
    final assuntos = <String, List<bool>>{};

    // Agrupa acertos por assunto
    for (int i = 0;
        i < questoesRespondidas.length && i < detalhesAcertos.length;
        i++) {
      final assunto = questoesRespondidas[i].assunto;
      final acerto = detalhesAcertos[i];

      if (!assuntos.containsKey(assunto)) {
        assuntos[assunto] = [];
      }
      assuntos[assunto]!.add(acerto);
    }

    // Calcula percentual por assunto
    final analise = <String, dynamic>{};
    assuntos.forEach((assunto, acertosLista) {
      final totalAssunto = acertosLista.length;
      final acertosAssunto = acertosLista.where((a) => a).length;
      final percentualAssunto = (acertosAssunto / totalAssunto * 100).round();

      analise[assunto] = {
        'acertos': acertosAssunto,
        'total': totalAssunto,
        'percentual': percentualAssunto,
        'status': percentualAssunto >= 70 ? 'Bom' : 'Revisar',
      };
    });

    return analise;
  }

  /// Converte para JSON para analytics/persistência
  Map<String, dynamic> toJson() {
    return {
      'nivel_escolar': nivelEscolar.toString(),
      'nivel_detectado': nivelDetectado.toString(),
      'acertos': acertos,
      'total_questoes': totalQuestoes,
      'porcentagem_acerto': porcentagemAcerto,
      'tempo_total_ms': tempoTotal.inMilliseconds,
      'data_realizacao': dataRealizacao.toIso8601String(),
      'questoes_ids': questoesRespondidas.map((q) => q.id).toList(),
      'respostas_escolhidas': respostasEscolhidas,
      'detalhes_acertos': detalhesAcertos,
      'analise_assuntos': analiseAssuntos,
    };
  }

  /// Cria a partir de JSON
  factory ModoDescobertaResult.fromJson(
    Map<String, dynamic> json,
    List<QuestaoDescoberta> questoes,
  ) {
    return ModoDescobertaResult(
      nivelEscolar: EducationLevel.values.firstWhere(
        (e) => e.toString() == json['nivel_escolar'],
      ),
      nivelDetectado: NivelDetectado.values.firstWhere(
        (e) => e.toString() == json['nivel_detectado'],
      ),
      acertos: json['acertos'] as int,
      totalQuestoes: json['total_questoes'] as int,
      porcentagemAcerto: json['porcentagem_acerto'] as int,
      tempoTotal: Duration(milliseconds: json['tempo_total_ms'] as int),
      dataRealizacao: DateTime.parse(json['data_realizacao'] as String),
      questoesRespondidas: questoes,
      respostasEscolhidas: List<int>.from(json['respostas_escolhidas']),
      detalhesAcertos: List<bool>.from(json['detalhes_acertos']),
    );
  }

  @override
  String toString() {
    return 'ModoDescobertaResult($resultadoFormatado, $acertos/$totalQuestoes acertos, ${tempoFormatado})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModoDescobertaResult &&
        other.dataRealizacao == dataRealizacao &&
        other.nivelEscolar == nivelEscolar;
  }

  @override
  int get hashCode => dataRealizacao.hashCode ^ nivelEscolar.hashCode;

  /// Copia com modificações
  ModoDescobertaResult copyWith({
    EducationLevel? nivelEscolar,
    NivelDetectado? nivelDetectado,
    int? acertos,
    int? totalQuestoes,
    int? porcentagemAcerto,
    Duration? tempoTotal,
    List<QuestaoDescoberta>? questoesRespondidas,
    List<int>? respostasEscolhidas,
    List<bool>? detalhesAcertos,
    DateTime? dataRealizacao,
  }) {
    return ModoDescobertaResult(
      nivelEscolar: nivelEscolar ?? this.nivelEscolar,
      nivelDetectado: nivelDetectado ?? this.nivelDetectado,
      acertos: acertos ?? this.acertos,
      totalQuestoes: totalQuestoes ?? this.totalQuestoes,
      porcentagemAcerto: porcentagemAcerto ?? this.porcentagemAcerto,
      tempoTotal: tempoTotal ?? this.tempoTotal,
      questoesRespondidas: questoesRespondidas ?? this.questoesRespondidas,
      respostasEscolhidas: respostasEscolhidas ?? this.respostasEscolhidas,
      detalhesAcertos: detalhesAcertos ?? this.detalhesAcertos,
      dataRealizacao: dataRealizacao ?? this.dataRealizacao,
    );
  }
}
