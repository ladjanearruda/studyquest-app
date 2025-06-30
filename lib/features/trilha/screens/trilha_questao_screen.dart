import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/questoes_amazonia.dart';
import '../widgets/barra_recursos.dart';
import '../providers/recursos_provider.dart';
import '../providers/xp_floresta_provider.dart';
import '../widgets/barra_xp_floresta.dart';
import '../models/recursos_vitais.dart';
import 'trilha_feedback_screen.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // ✅ BARRA XP NO TOPO
            const BarraXpFloresta(),

            // Barras de Recursos Vitais
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
                      'Sobrevivência na Amazônia - Questão ${questaoId + 1} de 20',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Questão
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.green.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          questao.enunciado,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.4),
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
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.green.shade200, width: 1),
                            ),
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
      ),
    );
  }

  // 🔧 CORRIGIDO: Função com parâmetros corretos para TrilhaFeedbackScreen
  void _responder(BuildContext context, WidgetRef ref, int escolha,
      int respostaCorreta, int questaoId) {
    final recursosNotifier = ref.read(recursosProvider.notifier);
    final xpNotifier = ref.read(xpFlorestaProvider.notifier);
    final recursos = ref.read(recursosProvider);

    bool acertou = escolha == respostaCorreta;

    // ✅ CAPTURAR RECURSOS ANTES DA MUDANÇA
    final recursosAntes = RecursosVitais(
      energia: recursos.energia,
      agua: recursos.agua,
      saude: recursos.saude,
    );

    // Atualizar recursos vitais
    if (acertou) {
      recursosNotifier.acerto();
    } else {
      recursosNotifier.erro();
    }

    // ✅ ADICIONAR XP
    final xpGanho = xpNotifier.adicionarXP(acertou);

    // Pegar recursos após mudança
    final recursosDepois = ref.read(recursosProvider);

    // 🔧 MODAL COM TODOS OS PARÂMETROS CORRETOS
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar feedback',
      barrierColor: Colors.black26,
      pageBuilder: (context, animation, secondaryAnimation) {
        return TrilhaFeedbackScreen(
          acertou: acertou,
          energiaAntes: recursosAntes,
          energiaDepois: recursosDepois,
          questaoId: questaoId, // ✅ ADICIONADO
          escolha: escolha, // ✅ ADICIONADO
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );

    // 🔧 REMOVIDO: navegação automática - deixar usuário decidir
    // Future.delayed(...)
  }

  // ✅ MÉTODO AUXILIAR MANTIDO
  void _proximaQuestao(BuildContext context, int questaoAtual) {
    if (questaoAtual < 19) {
      context.go('/trilha-questao/${questaoAtual + 1}');
    } else {
      context.go('/trilha-resultados');
    }
  }
}
