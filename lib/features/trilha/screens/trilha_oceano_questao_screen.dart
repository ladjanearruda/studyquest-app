import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/questoes_oceano.dart';
import '../widgets/barra_recursos_oceano.dart';
import '../widgets/barra_xp_oceano.dart'; // ✅ NOVO: Widget da barra de XP
import '../providers/recursos_oceano_provider.dart';
import '../providers/xp_oceano_provider.dart';
import '../models/recursos_vitais.dart';
import 'trilha_oceano_feedback_screen.dart';

class TrilhaOceanoQuestaoScreen extends ConsumerWidget {
  final int questaoId;
  const TrilhaOceanoQuestaoScreen({super.key, required this.questaoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questao = QuestoesOceano.getQuestao(questaoId);
    final recursos = ref.watch(recursosOceanoProvider);

    if (questao == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Questão não encontrada')),
        body: const Center(child: Text('Ops! Esta questão não existe.')),
      );
    }

    // Verificar Game Over
    if (!recursos.estaVivo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/trilha-oceano-gameover');
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // ✅ BARRA XP NO TOPO (AGORA PADRONIZADA COM A FLORESTA)
            const BarraXpOceano(),

            // Barras de Recursos Oceânicos
            const BarraRecursosOceano(),

            // Conteúdo da Questão
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Text(
                      'Exploração Oceânica - Questão ${questaoId + 1} de 20',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
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
                            colors: [Colors.white, Colors.blue.shade50],
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
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.blue.shade800,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.blue.shade200, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade600,
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

  // ✅ FUNÇÃO COMPLETA COM TODAS AS FUNCIONALIDADES DA FLORESTA
  void _responder(BuildContext context, WidgetRef ref, int escolha,
      int respostaCorreta, int questaoId) {
    final recursosNotifier = ref.read(recursosOceanoProvider.notifier);
    final xpNotifier = ref.read(xpOceanoProvider.notifier);

    bool acertou = escolha == respostaCorreta;

    // ✅ CAPTURAR ESTADO DOS RECURSOS ANTES DA MUDANÇA
    final recursosAntes = ref.read(recursosOceanoProvider);
    final RecursosVitais energiaAntes = RecursosVitais(
      energia: recursosAntes.oxigenio.toDouble(),
      agua: recursosAntes.temperatura.toDouble(),
      saude: recursosAntes.pressao.toDouble(),
    );

    // ✅ LÓGICA INTELIGENTE DE RECURSOS (igual à floresta)
    bool todosRecursosEm100 = recursosAntes.oxigenio >= 100 &&
        recursosAntes.temperatura >= 100 &&
        recursosAntes.pressao >= 100;

    // Atualizar recursos vitais APENAS se não estiverem todos em 100%
    if (acertou) {
      if (!todosRecursosEm100) {
        recursosNotifier
            .acerto(); // +5% nos recursos apenas se não estiver em 100%
      }
      xpNotifier.acerto(); // ✅ XP sempre aumenta no acerto
    } else {
      recursosNotifier.erro(); // -10% nos recursos
      xpNotifier.erro(); // ✅ Registra erro para precisão
    }

    // ✅ CAPTURAR ESTADO DOS RECURSOS DEPOIS DA MUDANÇA
    final recursosDepois = ref.read(recursosOceanoProvider);
    final RecursosVitais energiaDepois = RecursosVitais(
      energia: recursosDepois.oxigenio.toDouble(),
      agua: recursosDepois.temperatura.toDouble(),
      saude: recursosDepois.pressao.toDouble(),
    );

    // ✅ MODAL COM PARÂMETROS COMPLETOS (igual à floresta)
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar feedback',
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return TrilhaOceanoFeedbackScreen(
          questaoId: questaoId,
          acertou: acertou,
          escolha: escolha,
          energiaAntes: energiaAntes,
          energiaDepois: energiaDepois,
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
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
