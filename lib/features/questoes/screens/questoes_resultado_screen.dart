// lib/features/questoes/screens/questoes_resultado_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/questao_personalizada_provider.dart';

class QuestoesResultadoScreen extends ConsumerWidget {
  const QuestoesResultadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessao = ref.watch(sessaoQuestoesProvider);
    final recursos = ref.watch(recursosPersonalizadosProvider);

    // Calcular estatísticas
    final totalQuestoes = sessao.totalQuestoes;
    final acertos = sessao.acertos.where((a) => a).length;
    final precisao = totalQuestoes > 0 ? (acertos / totalQuestoes) : 0.0;
    final performance = _getPerformanceLevel(precisao);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
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
                  // Título de sucesso
                  Text(
                    'MISSÃO CONCLUÍDA!',
                    style: TextStyle(
                      fontSize: 36,
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
                    textAlign: TextAlign.center,
                  ).animate().scale(duration: 600.ms, curve: Curves.bounceOut),

                  const SizedBox(height: 20),

                  // Ícone de vitória
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      performance.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ).animate().scale(delay: 300.ms, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Mensagem de performance
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          performance.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          performance.message,
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

                  // Estatísticas da sessão
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Resultados da Missão',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              'Questões',
                              '$totalQuestoes',
                              Icons.quiz,
                            ),
                            _buildStatColumn(
                              'Acertos',
                              '$acertos',
                              Icons.check_circle,
                            ),
                            _buildStatColumn(
                              'Precisão',
                              '${(precisao * 100).round()}%',
                              Icons.gps_fixed,
                            ),
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

                  // Status dos recursos finais
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Recursos Vitais Finais',
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
                            _buildRecursoFinal(Icons.flash_on, 'Energia',
                                recursos['energia']?.toInt() ?? 0),
                            _buildRecursoFinal(Icons.water_drop, 'Água',
                                recursos['agua']?.toInt() ?? 0),
                            _buildRecursoFinal(Icons.favorite, 'Saúde',
                                recursos['saude']?.toInt() ?? 0),
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
                      // Botão Nova Missão
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _novaMissao(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Nova Missão',
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home, size: 24),
                              SizedBox(width: 8),
                              Text(
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

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRecursoFinal(IconData icon, String nome, int valor) {
    final isHigh = valor >= 70;
    final isMedium = valor >= 40;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isHigh
                    ? Colors.green
                    : isMedium
                        ? Colors.orange
                        : Colors.red)
                .withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isHigh
                      ? Colors.green
                      : isMedium
                          ? Colors.orange
                          : Colors.red)
                  .withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          nome,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$valor%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHigh ? Colors.white : Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  PerformanceData _getPerformanceLevel(double precisao) {
    if (precisao >= 0.9) {
      return PerformanceData(
        icon: Icons.emoji_events,
        title: 'PERFORMANCE EXCEPCIONAL!',
        message:
            'Você demonstrou excelência e domínio completo dos conceitos. Continue assim!',
      );
    } else if (precisao >= 0.7) {
      return PerformanceData(
        icon: Icons.thumb_up,
        title: 'MUITO BOM!',
        message:
            'Você enfrentou os desafios com determinação e inteligência. Excelente trabalho!',
      );
    } else if (precisao >= 0.5) {
      return PerformanceData(
        icon: Icons.trending_up,
        title: 'BOM TRABALHO!',
        message:
            'Você está aprendendo e evoluindo. Continue praticando para alcançar ainda melhores resultados!',
      );
    } else {
      return PerformanceData(
        icon: Icons.school,
        title: 'MISSÃO CUMPRIDA!',
        message:
            'Você mostrou coragem e persistência. Continue estudando para aprimorar suas habilidades!',
      );
    }
  }

  void _novaMissao(BuildContext context, WidgetRef ref) {
    // Reset dos recursos
    ref.read(recursosPersonalizadosProvider.notifier).resetRecursos();

    // Reset da sessão
    ref.read(sessaoQuestoesProvider.notifier).resetSessao();

    // Voltar para seleção de modo
    context.go('/modo-selection');
  }
}

class PerformanceData {
  final IconData icon;
  final String title;
  final String message;

  PerformanceData({
    required this.icon,
    required this.title,
    required this.message,
  });
}
