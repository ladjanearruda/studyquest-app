import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recursos_provider.dart';
import '../providers/xp_floresta_provider.dart';

class TrilhaResultadosScreen extends ConsumerWidget {
  const TrilhaResultadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursos = ref.watch(recursosProvider);
    final xpState = ref.watch(xpFlorestaProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade700,
              Colors.green.shade500,
              Colors.green.shade300,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 🏆 TÍTULO DE SUCESSO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '🎉 PARABÉNS!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Você completou a Trilha da Floresta Amazônica!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 📊 ESTATÍSTICAS FINAIS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Estatísticas da Expedição',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Grid de estatísticas
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Questões Corretas',
                              '${xpState.questoesCorretas}/20',
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Precisão',
                              '${(xpState.porcentagemAcerto * 100).toInt()}%',
                              Icons
                                  .track_changes, // ✅ CORRIGIDO: de target para track_changes
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'XP Total',
                              '${xpState.xpTotal}',
                              Icons.star,
                              Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Nível Alcançado',
                              '${xpState.nivel}',
                              Icons.trending_up,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🎖️ TIPO DE EXPLORADOR
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: Colors.orange.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Tipo de Explorador',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _getTipoExploradorCor(xpState).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTipoExploradorCor(xpState),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getTipoExploradorIcon(xpState),
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getTipoExplorador(xpState),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getTipoExploradorCor(xpState),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getTipoExploradorDescricao(xpState),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 💚 STATUS FINAL DOS RECURSOS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Estado Final do Explorador',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRecursoFinal('⚡', 'Energia', recursos.energia),
                          _buildRecursoFinal('💧', 'Água', recursos.agua),
                          _buildRecursoFinal('❤️', 'Saúde', recursos.saude),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 🎮 BOTÕES DE AÇÃO
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _jogarNovamente(context, ref),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'NOVA EXPEDIÇÃO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/trilha-mapa'),
                        icon: Icon(Icons.map, color: Colors.green.shade600),
                        label: Text(
                          'EXPLORAR OUTRAS TRILHAS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                              color: Colors.green.shade600, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecursoFinal(String emoji, String nome, double valor) {
    Color cor = Colors.green;
    if (valor <= 20)
      cor = Colors.red;
    else if (valor <= 50) cor = Colors.orange;

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 8),
        Text(
          '${valor.toInt()}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          nome,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // 🎖️ LÓGICA DO TIPO DE EXPLORADOR
  String _getTipoExplorador(XpFlorestaState xpState) {
    final precisao = xpState.porcentagemAcerto;
    final nivel = xpState.nivel;

    if (precisao >= 0.9 && nivel >= 3) return 'EXPLORADOR LENDÁRIO';
    if (precisao >= 0.8 && nivel >= 2) return 'AVENTUREIRO EXPERIENTE';
    if (precisao >= 0.7) return 'DESBRAVADOR CORAJOSO';
    if (precisao >= 0.5) return 'EXPLORADOR INICIANTE';
    return 'SOBREVIVENTE DETERMINADO';
  }

  String _getTipoExploradorIcon(XpFlorestaState xpState) {
    final precisao = xpState.porcentagemAcerto;
    final nivel = xpState.nivel;

    if (precisao >= 0.9 && nivel >= 3) return '🏆';
    if (precisao >= 0.8 && nivel >= 2) return '🥇';
    if (precisao >= 0.7) return '🥈';
    if (precisao >= 0.5) return '🥉';
    return '🎖️';
  }

  Color _getTipoExploradorCor(XpFlorestaState xpState) {
    final precisao = xpState.porcentagemAcerto;
    final nivel = xpState.nivel;

    if (precisao >= 0.9 && nivel >= 3) return Colors.amber;
    if (precisao >= 0.8 && nivel >= 2) return Colors.orange;
    if (precisao >= 0.7) return Colors.blue;
    if (precisao >= 0.5) return Colors.green;
    return Colors.purple;
  }

  String _getTipoExploradorDescricao(XpFlorestaState xpState) {
    final precisao = xpState.porcentagemAcerto;
    final nivel = xpState.nivel;

    if (precisao >= 0.9 && nivel >= 3) {
      return 'Você dominou completamente a floresta! Conhecimento excepcional e habilidades extraordinárias.';
    }
    if (precisao >= 0.8 && nivel >= 2) {
      return 'Excelente desempenho! Você mostrou grande sabedoria e coragem na expedição.';
    }
    if (precisao >= 0.7) {
      return 'Muito bom! Você enfrentou os desafios da floresta com determinação e inteligência.';
    }
    if (precisao >= 0.5) {
      return 'Bom trabalho! Você está aprendendo e evoluindo como explorador. Continue praticando!';
    }
    return 'Você mostrou coragem ao enfrentar a floresta. Continue estudando para melhorar suas habilidades!';
  }

  void _jogarNovamente(BuildContext context, WidgetRef ref) {
    // Reset completo
    ref.read(recursosProvider.notifier).reset();
    ref.read(xpFlorestaProvider.notifier).reset();

    // Voltar para primeira questão
    context.go('/trilha-questao/0');
  }
}
