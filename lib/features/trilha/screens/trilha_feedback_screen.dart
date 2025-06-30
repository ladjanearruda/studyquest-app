import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/recursos_vitais.dart';
import '../providers/recursos_provider.dart';
import '../providers/xp_floresta_provider.dart';
import '../data/questoes_amazonia.dart';

class TrilhaFeedbackScreen extends ConsumerWidget {
  final bool acertou;
  final RecursosVitais energiaAntes;
  final RecursosVitais energiaDepois;
  final int questaoId;
  final int escolha;

  const TrilhaFeedbackScreen({
    super.key,
    required this.acertou,
    required this.energiaAntes,
    required this.energiaDepois,
    required this.questaoId,
    required this.escolha,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questao = QuestoesAmazonia.getQuestao(questaoId);
    final xpState = ref.watch(xpFlorestaProvider);

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
              colors: [Colors.green.shade50, Colors.green.shade100],
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

              // ✅ CONTEÚDO PRINCIPAL - LAYOUT EM COLUNAS (SEM SCROLL)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== COLUNA ESQUERDA: EXPLICAÇÃO =====
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.92 - 48) /
                            2, // Exatamente 50% (descontando padding)
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
                                      color: Colors.green.shade800,
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

                      // ===== COLUNA DIREITA: RECURSOS + XP =====
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.92 - 48) /
                            2, // Exatamente 50% (descontando padding)
                        child: Column(
                          children: [
                            // CARD 1: Status dos Recursos
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

                                    // Recursos Vitais
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildRecursoBar('⚡', 'Energia',
                                              energiaDepois.energia),
                                          _buildRecursoBar(
                                              '💧', 'Água', energiaDepois.agua),
                                          _buildRecursoBar('❤️', 'Saúde',
                                              energiaDepois.saude),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // CARD 2: XP e Progressão
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Título da Progressão
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.amber.shade600,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Progressão',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Estatísticas de XP
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
                      backgroundColor: Colors.green.shade600,
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

  // ===== WIDGETS HELPERS OTIMIZADOS =====

  Widget _buildRecursoBar(String emoji, String nome, double valor) {
    Color cor = Colors.green;
    if (valor <= 20) {
      cor = Colors.red;
    } else if (valor <= 50) {
      cor = Colors.orange;
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
                  color: Colors.green.shade700,
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
        Icon(icon, size: 16, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade800,
          ),
        ),
      ],
    );
  }

  // ===== MÉTODOS ORIGINAIS =====

  String _getRecursoTexto() {
    if (acertou) {
      bool energiaEm100 =
          energiaAntes.energia >= 100 && energiaDepois.energia >= 100;
      bool aguaEm100 = energiaAntes.agua >= 100 && energiaDepois.agua >= 100;
      bool saudeEm100 = energiaAntes.saude >= 100 && energiaDepois.saude >= 100;

      if (energiaEm100 && aguaEm100 && saudeEm100) {
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
      bool algumEm100 = energiaAntes.energia >= 100 ||
          energiaAntes.agua >= 100 ||
          energiaAntes.saude >= 100;
      if (algumEm100) {
        return 'Você está em ótima forma! Continue assim.';
      } else {
        return '+5% em todos os recursos vitais';
      }
    } else {
      return '-10% em todos os recursos vitais';
    }
  }

  String _getProximoTexto() {
    if (questaoId >= 19) {
      return 'Ver Resultados';
    }
    return 'Próxima Questão';
  }

  void _proximaQuestao(BuildContext context) {
    Navigator.of(context).pop();

    if (questaoId >= 19) {
      context.go('/trilha-resultados');
    } else {
      context.go('/trilha-questao/${questaoId + 1}');
    }
  }
}
