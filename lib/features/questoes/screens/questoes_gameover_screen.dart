// lib/features/questoes/screens/questoes_gameover_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/questao_personalizada_provider.dart';

class QuestoesGameOverScreen extends ConsumerWidget {
  const QuestoesGameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessao = ref.watch(sessaoQuestoesProvider);
    final recursos = ref.watch(recursosPersonalizadosProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade900, Colors.red.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título Game Over
                  Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.bounceOut),

                  const SizedBox(height: 20),

                  // Ícone de derrota
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.sentiment_very_dissatisfied,
                      size: 80,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Mensagem motivacional
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Seus recursos vitais se esgotaram!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Não desista! Cada tentativa é uma oportunidade de aprender e crescer.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().slideY(
                        begin: 1,
                        delay: 600.ms,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 24),

                  // Status dos recursos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.shade400.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Estado Final dos Recursos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRecursoGameOver(Icons.flash_on, 'Energia',
                                recursos['energia']?.toInt() ?? 0),
                            _buildRecursoGameOver(Icons.water_drop, 'Água',
                                recursos['agua']?.toInt() ?? 0),
                            _buildRecursoGameOver(Icons.favorite, 'Saúde',
                                recursos['saude']?.toInt() ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ).animate().slideX(
                        begin: -1,
                        delay: 900.ms,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 24),

                  // Estatísticas da sessão
                  if (sessao.acertos.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.shade400.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics,
                                  color: Colors.blue.shade300, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Estatísticas da Sessão',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade200,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Questões',
                                '${sessao.questaoAtual}/${sessao.totalQuestoes}',
                                Icons.quiz,
                              ),
                              _buildStatItem(
                                'Acertos',
                                '${sessao.acertos.where((a) => a).length}',
                                Icons.check_circle,
                              ),
                              _buildStatItem(
                                'Precisão',
                                '${((sessao.acertos.where((a) => a).length / sessao.acertos.length) * 100).round()}%',
                                Icons.gps_fixed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().slideX(
                          begin: 1,
                          delay: 1200.ms,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                  const SizedBox(height: 32),

                  // Botões de ação
                  Column(
                    children: [
                      // Botão Tentar Novamente
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _tentarNovamente(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Tentar Novamente',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideY(
                            begin: 1,
                            delay: 1500.ms,
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 12),

                      // Botão Voltar ao Menu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/avatar-selection'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.home, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Voltar ao Menu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideY(
                            begin: 1,
                            delay: 1700.ms,
                            duration: 600.ms,
                            curve: Curves.easeOut,
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecursoGameOver(IconData icon, String nome, int valor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.shade400.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nome,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$valor%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valor <= 0 ? Colors.red.shade300 : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue.shade300,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade200,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _tentarNovamente(BuildContext context, WidgetRef ref) {
    // Reset dos recursos
    ref.read(recursosPersonalizadosProvider.notifier).resetRecursos();

    // Reset da sessão
    ref.read(sessaoQuestoesProvider.notifier).resetSessao();

    // Voltar para o modo de seleção ou reiniciar questões
    context.go('/modo-selection');
  }
}
