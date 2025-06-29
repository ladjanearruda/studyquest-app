import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/questoes_oceano.dart';
import '../providers/recursos_oceano_provider.dart';

class TrilhaOceanoFeedbackScreen extends ConsumerWidget {
  final int questaoId;
  final bool acertou;
  final int escolha;

  const TrilhaOceanoFeedbackScreen({
    super.key,
    required this.questaoId,
    required this.acertou,
    required this.escolha,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questao = QuestoesOceano.getQuestao(questaoId);
    final recursos =
        ref.watch(recursosOceanoProvider); // ✅ MANTIDO: padrão da floresta

    if (questao == null) {
      return const Scaffold(
        body: Center(child: Text('Questão não encontrada')),
      );
    }

    return Material(
      // ✅ ADICIONADO: Material wrapper
      color: Colors.transparent,
      child: Row(
        children: [
          // ✅ ÁREA TRANSPARENTE (lado esquerdo) - pode clicar para fechar
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _proximaQuestao(context),
              child: Container(
                color: Colors.transparent, // ✅ CORRIGIDO: transparente
              ),
            ),
          ),

          // ✅ MODAL LATERAL (lado direito)
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context)
                .size
                .height, // ✅ ADICIONADO: altura total
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header do Feedback
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        acertou ? Colors.green.shade400 : Colors.red.shade400,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        acertou ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          acertou ? '🎉 Excelente!' : '😅 Quase lá!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _proximaQuestao(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Conteúdo do Feedback
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resultado da Resposta
                        Text(
                          'Sua resposta: ${String.fromCharCode(65 + escolha)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Resposta correta: ${String.fromCharCode(65 + questao.respostaCorreta)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Explicação
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb,
                                        color: Colors.orange.shade600,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Explicação:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  questao.explicacao,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Impacto nos Recursos + Status Atual
                        Card(
                          color: acertou
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      acertou
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      color:
                                          acertou ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      acertou
                                          ? 'Recursos Recuperados!'
                                          : 'Recursos Perdidos!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: acertou
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  acertou
                                      ? '+5% em todos os recursos vitais'
                                      : '-10% em todos os recursos vitais',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // ✅ STATUS ATUAL DOS RECURSOS (padrão floresta)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Status Atual:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildRecursoInfo('🫁', 'Oxigênio',
                                              recursos.oxigenio),
                                          _buildRecursoInfo('🌡️', 'Temp.',
                                              recursos.temperatura),
                                          _buildRecursoInfo(
                                              '⚡', 'Pressão', recursos.pressao),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Botões de Ação
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _proximaQuestao(context),
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(_getProximoTexto()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  String _getProximoTexto() {
    if (questaoId >= 19) {
      // Última questão (índice 19 = questão 20)
      return 'Finalizar Trilha';
    }
    return 'Próxima Questão';
  }

  // ✅ HELPER PARA MOSTRAR RECURSOS (padrão floresta)
  Widget _buildRecursoInfo(String emoji, String nome, int valor) {
    Color cor = Colors.blue;
    if (valor <= 20) {
      cor = Colors.red;
    } else if (valor <= 50) {
      cor = Colors.orange;
    } else {
      cor = Colors.green;
    }

    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          nome,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${valor}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ],
    );
  }

  void _proximaQuestao(BuildContext context) {
    Navigator.of(context).pop(); // Fecha o modal

    if (questaoId >= 19) {
      // Última questão - vai para resultados
      context.go('/trilha-oceano-resultados');
    } else {
      // Próxima questão
      context.go('/trilha-oceano-questao/${questaoId + 1}');
    }
  }
}
