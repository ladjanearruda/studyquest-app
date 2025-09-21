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

    // Calcular estatísticas
    final totalRespondidas =
        sessao.acertos.isNotEmpty ? sessao.acertos.length : 0;
    final acertos = sessao.acertos.where((a) => a).length;
    final precisao = totalRespondidas > 0 ? (acertos / totalRespondidas) : 0.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade800, Colors.orange.shade600],
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
                  _buildCompactHeader(),
                  const SizedBox(height: 24),

                  // Card principal de game over
                  _buildMainGameOverCard(totalRespondidas, acertos),
                  const SizedBox(height: 20),

                  // Estatísticas em grid
                  _buildStatsGrid(
                      totalRespondidas, acertos, precisao, recursos),
                  const SizedBox(height: 20),

                  // Análise dos recursos vitais
                  _buildResourceAnalysis(recursos),
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

  Widget _buildCompactHeader() {
    return Row(
      children: [
        // Ícone de game over
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
            Icons.refresh,
            size: 32,
            color: Colors.red.shade700,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.bounceOut),

        const SizedBox(width: 16),

        // Título e subtítulo motivacional
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RECURSOS ESGOTADOS',
                style: TextStyle(
                  fontSize: 22,
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
                'Toda jornada tem desafios!',
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

  Widget _buildMainGameOverCard(int totalRespondidas, int acertos) {
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
          // Badge motivacional
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'EXPERIÊNCIA CONQUISTADA',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progresso antes de parar
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
                  color: Colors.orange.shade700,
                ),
              ),
              Text(
                '/$totalRespondidas',
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
            'Questões Respondidas Corretamente',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Mensagem motivacional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              'Cada tentativa é um passo em direção à maestria. Você está construindo conhecimento!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, delay: 400.ms);
  }

  Widget _buildStatsGrid(int totalRespondidas, int acertos, double precisao,
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
            'Estatísticas da Sessão',
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
                  child: _buildStatItem('Questões', '$totalRespondidas',
                      Icons.quiz, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatItem(
                      'Acertos', '$acertos', Icons.check_circle, Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatItem(
                      'Precisão',
                      '${(precisao * 100).round()}%',
                      Icons.gps_fixed,
                      Colors.amber)),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: -1, duration: 600.ms, delay: 600.ms);
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color cor) {
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
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceAnalysis(Map<String, double> recursos) {
    final energiaZero = (recursos['energia'] ?? 0) <= 0;
    final aguaZero = (recursos['agua'] ?? 0) <= 0;
    final saudeZero = (recursos['saude'] ?? 0) <= 0;

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
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Análise dos Recursos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid de recursos com status
          Row(
            children: [
              Expanded(
                  child: _buildRecursoAnalysis(Icons.flash_on, 'Energia',
                      recursos['energia']?.toInt() ?? 0, energiaZero)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildRecursoAnalysis(Icons.water_drop, 'Água',
                      recursos['agua']?.toInt() ?? 0, aguaZero)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildRecursoAnalysis(Icons.favorite, 'Saúde',
                      recursos['saude']?.toInt() ?? 0, saudeZero)),
            ],
          ),

          const SizedBox(height: 16),

          // Dica para próxima tentativa
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dica: Responda com calma e atenção para conservar seus recursos!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 1, duration: 600.ms, delay: 800.ms);
  }

  Widget _buildRecursoAnalysis(
      IconData icon, String nome, int valor, bool isZero) {
    Color statusColor =
        isZero ? Colors.red : (valor < 30 ? Colors.orange : Colors.green);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: statusColor, size: 24),
          const SizedBox(height: 8),
          Text(
            '$valor%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nome,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isZero ? 'ESGOTADO' : (valor < 30 ? 'CRÍTICO' : 'OK'),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Botão principal - Tentar Novamente
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _tentarNovamente(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade700,
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Tentar Novamente',
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
            // Mudar Estratégia
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/modo-selection'),
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
                      Icon(Icons.change_circle, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Mudar Modo',
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
                  onPressed: () => context.go('/avatar-selection'),
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

  void _tentarNovamente(BuildContext context, WidgetRef ref) {
    // Reset dos recursos
    ref.read(recursosPersonalizadosProvider.notifier).resetRecursos();

    // Reset da sessão
    ref.read(sessaoQuestoesProvider.notifier).resetSessao();

    // Reiniciar as questões personalizadas
    context.go('/questoes-personalizada');
  }
}
