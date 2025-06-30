import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recursos_oceano_provider.dart';
import '../providers/xp_oceano_provider.dart'; // ✅ NOVO: Provider de XP

class TrilhaOceanoGameOverScreen extends ConsumerWidget {
  const TrilhaOceanoGameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursos =
        ref.watch(recursosOceanoProvider); // ✅ NOVO: Para mostrar estatísticas
    final xpState = ref.watch(xpOceanoProvider); // ✅ NOVO: Estado do XP

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Ícone de afogamento
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.water_damage,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                const Text(
                  'EMERGÊNCIA OCEÂNICA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Subtítulo
                const Text(
                  'Seus recursos vitais se esgotaram nas profundezas!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                const Text(
                  'A pressão oceânica, falta de oxigênio ou frio extremo foram fatais.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // ✅ NOVO: Card de Estatísticas da Aventura (padrão floresta)
                Card(
                  color: Colors.white.withValues(alpha: 0.95),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics,
                          size: 40,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Estatísticas da Exploração',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Recursos Finais
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRecursoInfo(
                                '🫁', 'Oxigênio', recursos.oxigenio),
                            _buildRecursoInfo(
                                '🌡️', 'Temp.', recursos.temperatura),
                            _buildRecursoInfo('⚡', 'Pressão', recursos.pressao),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Progressão do Mergulhador
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mensagem de socorro
                Card(
                  color: Colors.white.withValues(alpha: 0.95),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.sos,
                          size: 40,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dica de Mergulho Seguro',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Na exploração oceânica, cada decisão afeta sua sobrevivência. Estude biologia marinha e física da pressão para mergulhar com segurança!',
                          style: TextStyle(fontSize: 13, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ BOTÕES COM RESET COMPLETO (padrão floresta)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _resetarEJogarNovamente(context, ref),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Resgate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _voltarParaMenuPrincipal(context, ref),
                        icon: const Icon(Icons.terrain),
                        label: const Text('Voltar à Terra'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== WIDGETS HELPERS =====

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
        Text(emoji, style: const TextStyle(fontSize: 16)),
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

  Widget _buildXpInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.cyan.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.cyan.shade700,
          ),
        ),
      ],
    );
  }

  // ===== FUNÇÕES DE RESET COMPLETO =====

  /// ✅ RESET COMPLETO + NOVA AVENTURA OCEÂNICA
  void _resetarEJogarNovamente(BuildContext context, WidgetRef ref) {
    // Reset completo de todos os providers
    ref.read(recursosOceanoProvider.notifier).reset();
    ref.read(xpOceanoProvider.notifier).reset();

    // Navegar para o início da trilha oceânica
    context.go('/trilha-oceano-questao/0');
  }

  /// ✅ VOLTA PARA MENU SEM RESET (mantém progresso)
  void _voltarParaMenuPrincipal(BuildContext context, WidgetRef ref) {
    // Apenas reset dos recursos para não ficar em game over
    ref.read(recursosOceanoProvider.notifier).reset();
    // XP mantém para mostrar progresso no menu

    // Navegar para o menu principal
    context.go('/trilha-mapa');
  }
}
