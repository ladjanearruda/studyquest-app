import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/questoes_amazonia.dart';
import '../widgets/barra_recursos.dart';
import '../providers/recursos_provider.dart';

class TrilhaQuestaoScreen extends ConsumerWidget {
  final int questaoId;
  const TrilhaQuestaoScreen({super.key, required this.questaoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questao = QuestoesAmazonia.getQuestao(questaoId);
    final recursos = ref.watch(recursosProvider);

    if (questao == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Questão não encontrada')),
        body: const Center(child: Text('Ops! Esta questão não existe.')),
      );
    }

    // Verificar Game Over
    if (!recursos.estaVivo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/trilha-gameover');
      });
    }

    return Scaffold(
      body: Column(
        children: [
          // Barras de Recursos
          const BarraRecursos(),

          // Conteúdo da Questão
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Questão ${questaoId + 1} de 20',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Questão
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        questao.enunciado,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opções
                  ...questao.opcoes.asMap().entries.map((entry) {
                    int index = entry.key;
                    String opcao = entry.value;
                    String letra =
                        String.fromCharCode(65 + index); // A, B, C, D

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        onPressed: () => _responder(context, ref, index,
                            questao.respostaCorreta, questaoId),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green.shade800,
                          elevation: 2,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green.shade600,
                              child: Text(letra,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(opcao,
                                    style: const TextStyle(fontSize: 15))),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _responder(BuildContext context, WidgetRef ref, int escolha,
      int respostaCorreta, int questaoId) {
    final recursosNotifier = ref.read(recursosProvider.notifier);
    bool acertou = escolha == respostaCorreta;

    if (acertou) {
      recursosNotifier.acerto();
    } else {
      recursosNotifier.erro();
    }

    // Navegar para feedback
    context.go(
        '/trilha-feedback?questao=$questaoId&acertou=$acertou&escolha=$escolha');
  }
}
