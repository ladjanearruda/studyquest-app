// lib/features/modo_descoberta/providers/modo_descoberta_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/questao_descoberta.dart';
import '../models/modo_descoberta_result.dart';
import '../data/questoes_nivelamento.dart';
import '../../onboarding/screens/studyquest_onboarding.dart';

/// Estados possíveis do Modo Descoberta
enum ModoDescobertaStatus {
  inicial, // Aguardando início
  emAndamento, // Respondendo questões
  finalizado, // 5 questões completadas
  erro, // Erro durante processo
}

/// Níveis detectados pelo algoritmo
enum NivelDetectado {
  iniciante('🔰 Iniciante', 'Vamos começar do básico!'),
  iniciantePlus('🌱 Iniciante+', 'Você já tem uma base!'),
  intermediario('📚 Intermediário', 'Está no caminho certo!'),
  intermediarioPlus('🎯 Intermediário+', 'Muito bem! Quase lá!'),
  avancado('🏆 Avançado', 'Parabéns! Você domina o assunto!');

  const NivelDetectado(this.titulo, this.mensagem);
  final String titulo;
  final String mensagem;
}

/// Estado imutável do Modo Descoberta
class ModoDescobertaState {
  // Status atual
  final ModoDescobertaStatus status;

  // Configuração
  final EducationLevel? nivelEscolar;
  final List<QuestaoDescoberta> questoes;

  // Progresso
  final int questaoAtual; // 0-4
  final List<int?> respostas; // [1, null, 2, 0, 3] - índices escolhidos
  final List<bool> acertos; // [true, false, true, true, false]

  // Timing
  final DateTime? inicioTeste;
  final DateTime? fimTeste;
  final List<Duration> temposPorQuestao;

  // Resultado
  final ModoDescobertaResult? resultado;

  // Erro
  final String? mensagemErro;

  const ModoDescobertaState({
    this.status = ModoDescobertaStatus.inicial,
    this.nivelEscolar,
    this.questoes = const [],
    this.questaoAtual = 0,
    this.respostas = const [],
    this.acertos = const [],
    this.inicioTeste,
    this.fimTeste,
    this.temposPorQuestao = const [],
    this.resultado,
    this.mensagemErro,
  });

  /// Questão atual sendo exibida
  QuestaoDescoberta? get questaoAtualObj {
    if (questaoAtual >= 0 && questaoAtual < questoes.length) {
      return questoes[questaoAtual];
    }
    return null;
  }

  /// Progresso percentual (0.0 a 1.0)
  double get progressoPercentual {
    if (questoes.isEmpty) return 0.0;
    return questaoAtual / questoes.length;
  }

  /// Número total de acertos até agora
  int get totalAcertos => acertos.where((acerto) => acerto).length;

  /// Tempo total gasto (se finalizado)
  Duration? get tempoTotal {
    if (inicioTeste != null && fimTeste != null) {
      return fimTeste!.difference(inicioTeste!);
    }
    return null;
  }

  /// Verifica se todas as questões foram respondidas
  bool get todasQuestoesRespondidas {
    return respostas.length == questoes.length &&
        respostas.every((resposta) => resposta != null);
  }

  /// Verifica se o teste está em andamento
  bool get testEmAndamento => status == ModoDescobertaStatus.emAndamento;

  /// Verifica se pode avançar para próxima questão
  bool get podeAvancar {
    return questaoAtual < respostas.length && respostas[questaoAtual] != null;
  }

  /// Copia o estado com modificações
  ModoDescobertaState copyWith({
    ModoDescobertaStatus? status,
    EducationLevel? nivelEscolar,
    List<QuestaoDescoberta>? questoes,
    int? questaoAtual,
    List<int?>? respostas,
    List<bool>? acertos,
    DateTime? inicioTeste,
    DateTime? fimTeste,
    List<Duration>? temposPorQuestao,
    ModoDescobertaResult? resultado,
    String? mensagemErro,
  }) {
    return ModoDescobertaState(
      status: status ?? this.status,
      nivelEscolar: nivelEscolar ?? this.nivelEscolar,
      questoes: questoes ?? this.questoes,
      questaoAtual: questaoAtual ?? this.questaoAtual,
      respostas: respostas ?? this.respostas,
      acertos: acertos ?? this.acertos,
      inicioTeste: inicioTeste ?? this.inicioTeste,
      fimTeste: fimTeste ?? this.fimTeste,
      temposPorQuestao: temposPorQuestao ?? this.temposPorQuestao,
      resultado: resultado ?? this.resultado,
      mensagemErro: mensagemErro ?? this.mensagemErro,
    );
  }

  @override
  String toString() {
    return 'ModoDescobertaState(status: $status, questao: $questaoAtual/${questoes.length}, acertos: $totalAcertos)';
  }
}

/// Provider do estado do Modo Descoberta
final modoDescobertaProvider =
    StateNotifierProvider<ModoDescobertaNotifier, ModoDescobertaState>(
  (ref) => ModoDescobertaNotifier(),
);

/// Notifier que gerencia o estado do Modo Descoberta
class ModoDescobertaNotifier extends StateNotifier<ModoDescobertaState> {
  ModoDescobertaNotifier() : super(const ModoDescobertaState());

  /// Inicia o teste com base no nível escolar do usuário
  void iniciarTeste(EducationLevel nivelEscolar) {
    try {
      // Seleciona 5 questões aleatórias do pool do nível
      final questoesSelecionadas =
          QuestoesNivelamento.selecionarQuestoesPara(nivelEscolar);

      if (questoesSelecionadas.length < 5) {
        state = state.copyWith(
          status: ModoDescobertaStatus.erro,
          mensagemErro:
              'Erro: Pool de questões insuficiente para o nível $nivelEscolar',
        );
        return;
      }

      // Inicializa o estado
      state = state.copyWith(
        status: ModoDescobertaStatus.emAndamento,
        nivelEscolar: nivelEscolar,
        questoes: questoesSelecionadas,
        questaoAtual: 0,
        respostas: List.filled(5, null),
        acertos: [],
        temposPorQuestao: [],
        inicioTeste: DateTime.now(),
        fimTeste: null,
        resultado: null,
        mensagemErro: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ModoDescobertaStatus.erro,
        mensagemErro: 'Erro ao iniciar teste: $e',
      );
    }
  }

  /// Registra a resposta de uma questão
  void responderQuestao(int indiceResposta) {
    if (state.status != ModoDescobertaStatus.emAndamento) return;
    if (state.questaoAtual >= state.questoes.length) return;

    final questaoAtual = state.questoes[state.questaoAtual];
    final isCorreto = questaoAtual.isRespostaCorreta(indiceResposta);

    // Atualiza listas de respostas e acertos
    final novasRespostas = List<int?>.from(state.respostas);
    novasRespostas[state.questaoAtual] = indiceResposta;

    final novosAcertos = List<bool>.from(state.acertos);
    novosAcertos.add(isCorreto);

    state = state.copyWith(
      respostas: novasRespostas,
      acertos: novosAcertos,
    );
  }

  /// Avança para a próxima questão
  void avancarQuestao() {
    if (state.status != ModoDescobertaStatus.emAndamento) return;
    if (!state.podeAvancar) return;

    final proximaQuestao = state.questaoAtual + 1;

    // Se chegou na última questão, finaliza o teste
    if (proximaQuestao >= state.questoes.length) {
      finalizarTeste();
    } else {
      state = state.copyWith(questaoAtual: proximaQuestao);
    }
  }

  /// Finaliza o teste e calcula resultado
  void finalizarTeste() {
    if (state.status != ModoDescobertaStatus.emAndamento) return;

    final fimTeste = DateTime.now();
    final resultado = _calcularResultado();

    state = state.copyWith(
      status: ModoDescobertaStatus.finalizado,
      fimTeste: fimTeste,
      resultado: resultado,
    );
  }

  /// Calcula o resultado baseado nas respostas
  ModoDescobertaResult _calcularResultado() {
    final totalAcertos = state.totalAcertos;
    final totalQuestoes = state.questoes.length;
    final porcentagemAcerto = (totalAcertos / totalQuestoes * 100).round();

    // Algoritmo de nivelamento baseado em acertos
    final nivel = _determinarNivel(totalAcertos);

    final tempoTotal = state.tempoTotal ?? Duration.zero;

    return ModoDescobertaResult(
      nivelEscolar: state.nivelEscolar!,
      nivelDetectado: nivel,
      acertos: totalAcertos,
      totalQuestoes: totalQuestoes,
      porcentagemAcerto: porcentagemAcerto,
      tempoTotal: tempoTotal,
      questoesRespondidas: state.questoes,
      respostasEscolhidas: state.respostas.whereType<int>().toList(),
      detalhesAcertos: state.acertos,
      dataRealizacao: DateTime.now(),
    );
  }

  /// Determina o nível baseado no número de acertos (0-5)
  NivelDetectado _determinarNivel(int acertos) {
    switch (acertos) {
      case 5:
        return NivelDetectado.avancado;
      case 4:
        return NivelDetectado.intermediarioPlus;
      case 3:
        return NivelDetectado.intermediario;
      case 2:
        return NivelDetectado.iniciantePlus;
      case 0:
      case 1:
      default:
        return NivelDetectado.iniciante;
    }
  }

  /// Volta para questão anterior (se permitido)
  void voltarQuestao() {
    if (state.status != ModoDescobertaStatus.emAndamento) return;
    if (state.questaoAtual <= 0) return;

    state = state.copyWith(questaoAtual: state.questaoAtual - 1);
  }

  /// Reseta o estado para o inicial
  void resetar() {
    state = const ModoDescobertaState();
  }

  /// Pula uma questão (registra como erro)
  void pularQuestao() {
    if (state.status != ModoDescobertaStatus.emAndamento) return;

    // Registra resposta inválida (-1) que será considerada erro
    responderQuestao(-1);
    avancarQuestao();
  }

  /// Método para debug - força um resultado específico
  void debugSetResultado(NivelDetectado nivel, int acertos) {
    if (state.nivelEscolar == null) return;

    final resultado = ModoDescobertaResult(
      nivelEscolar: state.nivelEscolar!,
      nivelDetectado: nivel,
      acertos: acertos,
      totalQuestoes: 5,
      porcentagemAcerto: (acertos / 5 * 100).round(),
      tempoTotal: const Duration(minutes: 2),
      questoesRespondidas: [],
      respostasEscolhidas: [],
      detalhesAcertos: [],
      dataRealizacao: DateTime.now(),
    );

    state = state.copyWith(
      status: ModoDescobertaStatus.finalizado,
      resultado: resultado,
    );
  }
}

/// Provider para acessar apenas o resultado
final modoDescobertaResultProvider = Provider<ModoDescobertaResult?>((ref) {
  return ref.watch(modoDescobertaProvider).resultado;
});

/// Provider para verificar se o teste está ativo
final modoDescobertaAtivoProvider = Provider<bool>((ref) {
  final status = ref.watch(modoDescobertaProvider).status;
  return status == ModoDescobertaStatus.emAndamento;
});

/// Provider para progresso visual
final modoDescobertaProgressoProvider = Provider<double>((ref) {
  return ref.watch(modoDescobertaProvider).progressoPercentual;
});
