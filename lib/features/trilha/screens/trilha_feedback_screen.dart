import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/questoes_amazonia.dart';

class TrilhaFeedbackScreen extends StatelessWidget {
  final int questaoId;
  final bool acertou;
  final int escolha;

  const TrilhaFeedbackScreen({
    super.key,
    required this.questaoId,
    required this.acertou,
    required this.escolha,
  });

  @override
  Widget build(BuildContext context) {
    final questao = QuestoesAmazonia.getQuestao(questaoId);
    if (questao == null) return const Scaffold(body: Text('Erro'));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: acertou
                ? [Colors.green.shade300, Colors.green.shade600]
                : [Colors.red.shade300, Colors.red.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de resultado
                Icon(
                  acertou ? Icons.check_circle : Icons.cancel,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

                // Texto resultado
                Text(
                  acertou ? 'PARABÉNS!' : 'OPS!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  acertou ? 'Você acertou!' : 'Resposta incorreta',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 30),

                // Explicação
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Explicação:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          questao.explicacao,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Botão próxima questão
                ElevatedButton.icon(
                  onPressed: () {
                    if (questaoId + 1 < QuestoesAmazonia.totalQuestoes) {
                      context.go('/trilha-questao/${questaoId + 1}');
                    } else {
                      context.go('/trilha-resultados');
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(questaoId + 1 < QuestoesAmazonia.totalQuestoes
                      ? 'Próxima Questão'
                      : 'Ver Resultados'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: acertou ? Colors.green : Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
