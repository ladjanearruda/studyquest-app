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
            colors: [performance.primaryColor, performance.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Header compacto
                  _buildCompactHeader(performance),
                  const SizedBox(height: 24),

                  // Card principal de resultado
                  _buildMainResultCard(
                      performance, acertos, totalQuestoes, precisao),
                  const SizedBox(height: 20),

                  // Estatísticas em grid
                  _buildStatsGrid(totalQuestoes, acertos, precisao, recursos),
                  const SizedBox(height: 20),

                  // XP e Badge conquistados
                  _buildRewardsSection(performance, acertos),
                  const SizedBox(height: 24),

                  // Botões de ação
                  _buildActionButtons(context, ref),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(PerformanceData performance) {
    return Row(
      children: [
        // Ícone de conquista
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            performance.icon,
            size: 32,
            color: performance.primaryColor,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.bounceOut),

        const SizedBox(width: 16),

        // Título e subtítulo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MISSÃO CONCLUÍDA!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                performance.subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().slideX(begin: 1, duration: 600.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildMainResultCard(PerformanceData performance, int acertos,
      int totalQuestoes, double precisao) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge de performance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: performance.badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              performance.badge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Score principal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$acertos',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: performance.primaryColor,
                ),
              ),
              Text(
                '/$totalQuestoes',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Questões Corretas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Barra de progresso circular ou linear estilizada
          _buildProgressBar(precisao, performance),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, delay: 400.ms);
  }

  Widget _buildProgressBar(double precisao, PerformanceData performance) {
    return Column(
      children: [
        // Barra de progresso
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: precisao,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    performance.primaryColor,
                    performance.secondaryColor
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(precisao * 100).round()}% de precisão',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int totalQuestoes, int acertos, double precisao,
      Map<String, double> recursos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recursos Vitais Finais',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildRecursoStat(Icons.flash_on, 'Energia',
                      recursos['energia']?.toInt() ?? 0, Colors.amber)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildRecursoStat(Icons.water_drop, 'Água',
                      recursos['agua']?.toInt() ?? 0, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildRecursoStat(Icons.favorite, 'Saúde',
                      recursos['saude']?.toInt() ?? 0, Colors.red)),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: -1, duration: 600.ms, delay: 600.ms);
  }

  Widget _buildRecursoStat(IconData icon, String nome, int valor, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: cor, size: 24),
          const SizedBox(height: 8),
          Text(
            '$valor%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nome,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(PerformanceData performance, int acertos) {
    final xpGanho = acertos * 15;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // XP Ganho
          Expanded(
            child: Column(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 32),
                const SizedBox(height: 8),
                Text(
                  '+$xpGanho XP',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Experiência',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),

          // Badge conquistado
          Expanded(
            child: Column(
              children: [
                Icon(performance.icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  performance.badge,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Conquista',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 1, duration: 600.ms, delay: 800.ms);
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Botão principal - Nova Missão
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _novaMissao(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade700,
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.replay, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Nova Missão',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 1, delay: 1000.ms, duration: 600.ms),

        const SizedBox(height: 12),

        // Botões secundários em linha
        Row(
          children: [
            // Próximo Nível (se disponível)
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _proximoNivel(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Próximo Nível',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Voltar ao Menu
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/modo-selection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: Colors.white.withOpacity(0.7), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Menu',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ).animate().slideY(begin: 1, delay: 1200.ms, duration: 600.ms),
      ],
    );
  }

  PerformanceData _getPerformanceLevel(double precisao) {
    if (precisao >= 0.9) {
      return PerformanceData(
        icon: Icons.emoji_events,
        badge: 'MAESTRIA',
        subtitle: 'Performance excepcional!',
        primaryColor: Colors.amber.shade600,
        secondaryColor: Colors.orange.shade400,
        badgeColor: Colors.amber.shade700,
      );
    } else if (precisao >= 0.7) {
      return PerformanceData(
        icon: Icons.military_tech,
        badge: 'EXPERT',
        subtitle: 'Muito bem executado!',
        primaryColor: Colors.green.shade600,
        secondaryColor: Colors.teal.shade400,
        badgeColor: Colors.green.shade700,
      );
    } else if (precisao >= 0.5) {
      return PerformanceData(
        icon: Icons.trending_up,
        badge: 'PROGRESSO',
        subtitle: 'Evoluindo constantemente!',
        primaryColor: Colors.blue.shade600,
        secondaryColor: Colors.indigo.shade400,
        badgeColor: Colors.blue.shade700,
      );
    } else {
      return PerformanceData(
        icon: Icons.school,
        badge: 'EXPLORADOR',
        subtitle: 'Jornada de aprendizado!',
        primaryColor: Colors.purple.shade600,
        secondaryColor: Colors.deepPurple.shade400,
        badgeColor: Colors.purple.shade700,
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

  void _proximoNivel(BuildContext context, WidgetRef ref) {
    // TODO: Implementar sistema de níveis progressivos
    // Por enquanto, inicia nova sessão com dificuldade aumentada
    ref.read(recursosPersonalizadosProvider.notifier).resetRecursos();
    ref.read(sessaoQuestoesProvider.notifier).resetSessao();
    context.go('/questoes-personalizada');
  }
}

class PerformanceData {
  final IconData icon;
  final String badge;
  final String subtitle;
  final Color primaryColor;
  final Color secondaryColor;
  final Color badgeColor;

  PerformanceData({
    required this.icon,
    required this.badge,
    required this.subtitle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.badgeColor,
  });
}
