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

    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          // Área transparente (lado esquerdo) - pode clicar para fechar
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _proximaQuestao(context),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Modal lateral (lado direito) - POSICIONADO MAIS PARA CIMA
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: MediaQuery.of(context).size.height * 0.9, // 90% da altura
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05, // 5% do topo
              bottom: MediaQuery.of(context).size.height * 0.05, // 5% do fundo
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
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

                // Conteúdo do Feedback (SCROLLABLE)
                Expanded(
                  child: SingleChildScrollView(
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
                            color: Colors.green.shade800,
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

                        // ✅ EXPLICAÇÃO DA QUESTÃO (COMO NO OCEANO)
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
                                        color: Colors.green.shade800,
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

                        // ✅ IMPACTO NOS RECURSOS COM LÓGICA DE 100%
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
                                      _getRecursoTexto(),
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
                                  _getRecursoDescricao(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Status atual dos recursos
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Status Atual:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildRecursoInfo('⚡', 'Energia',
                                              energiaDepois.energia),
                                          _buildRecursoInfo(
                                              '💧', 'Água', energiaDepois.agua),
                                          _buildRecursoInfo('❤️', 'Saúde',
                                              energiaDepois.saude),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ✅ INFORMAÇÕES DE XP E NÍVEL
                        Card(
                          color: Colors.amber.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.amber.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Progressão do Explorador',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildXpInfo('Nível', '${xpState.nivel}'),
                                    _buildXpInfo(
                                        'XP Total', '${xpState.xpTotal}'),
                                    _buildXpInfo('Precisão',
                                        '${(xpState.porcentagemAcerto * 100).toInt()}%'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 80), // Espaço para o botão
                      ],
                    ),
                  ),
                ),

                // Botão de ação (FIXO NO FUNDO)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _proximaQuestao(context),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(_getProximoTexto()),
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
        ],
      ),
    );
  }

  // ✅ LÓGICA INTELIGENTE PARA RECURSOS EM 100%
  String _getRecursoTexto() {
    if (acertou) {
      // Verificar se algum recurso estava em 100% e não mudou
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
      // Verificar se algum recurso estava em 100%
      bool algumEm100 = energiaAntes.energia >= 100 ||
          energiaAntes.agua >= 100 ||
          energiaAntes.saude >= 100;

      if (algumEm100) {
        return 'Você está em ótima forma! Continue assim para manter seus recursos no máximo.';
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

  Widget _buildRecursoInfo(String emoji, String nome, double valor) {
    Color cor = Colors.green;
    if (valor <= 20) {
      cor = Colors.red;
    } else if (valor <= 50) {
      cor = Colors.orange;
    }

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          nome,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${valor.toInt()}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ],
    );
  }

  Widget _buildXpInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.amber.shade700,
          ),
        ),
      ],
    );
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
