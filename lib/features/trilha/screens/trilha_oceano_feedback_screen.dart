import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/questoes_oceano.dart';
import '../providers/recursos_oceano_provider.dart';
import '../providers/xp_oceano_provider.dart'; // ✅ NOVO: Provider de XP oceânico
import '../models/recursos_vitais.dart'; // ✅ NOVO: Para os parâmetros antes/depois

class TrilhaOceanoFeedbackScreen extends ConsumerWidget {
  final int questaoId;
  final bool acertou;
  final int escolha;
  final RecursosVitais energiaAntes; // ✅ NOVO: Estado antes
  final RecursosVitais energiaDepois; // ✅ NOVO: Estado depois

  const TrilhaOceanoFeedbackScreen({
    super.key,
    required this.questaoId,
    required this.acertou,
    required this.escolha,
    required this.energiaAntes,
    required this.energiaDepois,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questao = QuestoesOceano.getQuestao(questaoId);
    final recursos = ref.watch(recursosOceanoProvider);
    final xpState = ref.watch(xpOceanoProvider); // ✅ NOVO: Estado do XP

    if (questao == null) {
      return const Scaffold(
        body: Center(child: Text('Questão não encontrada')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black54, // Fundo escuro semitransparente
      body: Center(
        // Centraliza completamente o modal
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92, // 92% da largura
          height: MediaQuery.of(context).size.height * 0.88, // 88% da altura
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header do Feedback
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: acertou ? Colors.green.shade400 : Colors.red.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      acertou ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acertou ? '🎉 Excelente!' : '😅 Quase lá!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sua resposta: ${String.fromCharCode(65 + escolha)} | Correta: ${String.fromCharCode(65 + questao.respostaCorreta)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _proximaQuestao(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ✅ CONTEÚDO PRINCIPAL - LAYOUT EM COLUNAS 50/50 (SEM SCROLL)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== COLUNA ESQUERDA: EXPLICAÇÃO (50%) =====
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.92 - 48) /
                            2, // Exatamente 50%
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título da Explicação
                              Row(
                                children: [
                                  Icon(Icons.lightbulb,
                                      color: Colors.orange.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Explicação da Questão',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Texto da Explicação (com scroll interno se necessário)
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    questao.explicacao,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ===== COLUNA DIREITA: RECURSOS + XP (50%) =====
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.92 - 48) /
                            2, // Exatamente 50%
                        child: Column(
                          children: [
                            // CARD 1: Status dos Recursos Oceânicos
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: acertou
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: acertou
                                        ? Colors.green.shade200
                                        : Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Título dos Recursos
                                    Row(
                                      children: [
                                        Icon(
                                          acertou
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          color: acertou
                                              ? Colors.green
                                              : Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _getRecursoTexto(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: acertou
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    Text(
                                      _getRecursoDescricao(),
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 16),

                                    // Recursos Vitais Oceânicos
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildRecursoBar('🫁', 'Oxigênio',
                                              energiaDepois.energia),
                                          _buildRecursoBar('🌡️', 'Temperatura',
                                              energiaDepois.agua),
                                          _buildRecursoBar('⚡', 'Pressão',
                                              energiaDepois.saude),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // CARD 2: XP e Progressão Oceânica
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.cyan.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Título da Progressão
                                    Row(
                                      children: [
                                        Icon(Icons.scuba_diving,
                                            color: Colors.cyan.shade600,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Mergulhador',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.cyan.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Estatísticas de XP Oceânico
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildXpStat(
                                              'Nível',
                                              '${xpState.nivel}',
                                              Icons.military_tech),
                                          _buildXpStat(
                                              'XP Total',
                                              '${xpState.xpTotal}',
                                              Icons.stars),
                                          _buildXpStat(
                                              'Precisão',
                                              '${(xpState.porcentagemAcerto * 100).toInt()}%',
                                              Icons.gps_fixed),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== BOTÃO DE AÇÃO (FIXO NO FUNDO) =====
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _proximaQuestao(context),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      _getProximoTexto(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== WIDGETS HELPERS OCEÂNICOS =====

  Widget _buildRecursoBar(String emoji, String nome, double valor) {
    Color cor = Colors.blue;
    if (valor <= 20) {
      cor = Colors.red;
    } else if (valor <= 50) {
      cor = Colors.orange;
    } else {
      cor = Colors.green;
    }

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 2),
              LinearProgressIndicator(
                value: valor / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(cor),
                minHeight: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${valor.toInt()}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ],
    );
  }

  Widget _buildXpStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.cyan.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.cyan.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.cyan.shade800,
          ),
        ),
      ],
    );
  }

  // ===== LÓGICA INTELIGENTE DE RECURSOS (IGUAL À FLORESTA) =====

  String _getRecursoTexto() {
    if (acertou) {
      // Verificar se algum recurso estava em 100% e não mudou
      bool oxigenioEm100 =
          energiaAntes.energia >= 100 && energiaDepois.energia >= 100;
      bool temperaturaEm100 =
          energiaAntes.agua >= 100 && energiaDepois.agua >= 100;
      bool pressaoEm100 =
          energiaAntes.saude >= 100 && energiaDepois.saude >= 100;

      if (oxigenioEm100 && temperaturaEm100 && pressaoEm100) {
        return 'Recursos Mantidos!';
      } else {
        return 'Recursos Recuperados!';
      }
    } else {
      return 'Recursos Perdidos!';
    }
  }

  String _getRecursoDescricao() {
    if (acertou) {
      // Verificar se algum recurso estava em 100%
      bool algumEm100 = energiaAntes.energia >= 100 ||
          energiaAntes.agua >= 100 ||
          energiaAntes.saude >= 100;

      if (algumEm100) {
        return 'Você está em ótimas condições de mergulho! Continue assim.';
      } else {
        return '+5% em todos os recursos vitais';
      }
    } else {
      return '-10% em todos os recursos vitais';
    }
  }

  String _getProximoTexto() {
    if (questaoId >= 19) {
      return 'Finalizar Trilha';
    }
    return 'Próxima Questão';
  }

  void _proximaQuestao(BuildContext context) {
    Navigator.of(context).pop();

    if (questaoId >= 19) {
      context.go('/trilha-oceano-resultados');
    } else {
      context.go('/trilha-oceano-questao/${questaoId + 1}');
    }
  }
}
