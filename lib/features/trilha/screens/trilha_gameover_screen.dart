import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recursos_provider.dart';
import '../providers/xp_floresta_provider.dart';

class TrilhaGameOverScreen extends ConsumerWidget {
  const TrilhaGameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursos = ref.watch(recursosProvider);
    final xpState =
        ref.watch(xpFlorestaProvider); // ✅ ADICIONADO para estatísticas

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // ✅ GRADIENTE DRAMÁTICO DA FLORESTA
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D4F3C), // Verde escuro profundo
              const Color(0xFF1B5E20), // Verde militar
              const Color(0xFF2E7D32), // Verde médio
              const Color(0xFF388E3C), // Verde mais claro
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ✅ EFEITO DE FOLHAS CAINDO (DECORATIVO)
            ...List.generate(
                8,
                (index) => Positioned(
                      top: 50.0 + (index * 80),
                      left: (index % 2 == 0) ? 20.0 : null,
                      right: (index % 2 == 1) ? 30.0 : null,
                      child: AnimatedOpacity(
                        opacity: 0.3,
                        duration: Duration(milliseconds: 2000 + (index * 200)),
                        child: Icon(
                          index % 3 == 0
                              ? Icons.eco
                              : index % 3 == 1
                                  ? Icons.local_florist
                                  : Icons.grass,
                          size: 24 + (index % 3 * 8),
                          color: Colors.green.shade300.withOpacity(0.4),
                        ),
                      ),
                    )),

            // ✅ CONTEÚDO PRINCIPAL COM SCROLL
            SafeArea(
              child: SingleChildScrollView(
                // ✅ ADICIONADO: Scroll para evitar overflow
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20), // ✅ REDUZIDO: era Spacer()

                      // ✅ ÍCONE DRAMÁTICO FLORESTA
                      Container(
                        padding: const EdgeInsets.all(16), // ✅ REDUZIDO: era 20
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade800.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.red.shade300,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.dangerous, // Ícone de perigo
                          size: 60, // ✅ REDUZIDO: era 80
                          color: Colors.red.shade200,
                        ),
                      ),

                      const SizedBox(height: 24), // ✅ REDUZIDO: era 32

                      // ✅ TÍTULO DRAMÁTICO
                      Text(
                        'A FLORESTA VENCEU',
                        style: TextStyle(
                          fontSize: 28, // ✅ REDUZIDO: era 32
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade100,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black54,
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12), // ✅ REDUZIDO: era 16

                      // ✅ SUBTÍTULO CONTEXTUALIZADO
                      Text(
                        'Sem conhecimento suficiente, você\nnão conseguiu sobreviver na Amazônia...',
                        style: TextStyle(
                          fontSize: 16, // ✅ REDUZIDO: era 18
                          color: Colors.green.shade100,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30), // ✅ REDUZIDO: era 40

                      // ✅ RECURSOS VITAIS ZERADOS
                      Container(
                        padding: const EdgeInsets.all(20), // ✅ REDUZIDO: era 24
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.shade400.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber,
                                    color: Colors.orange.shade300,
                                    size: 20), // ✅ REDUZIDO: era 24
                                const SizedBox(width: 12),
                                Expanded(
                                  // ✅ ADICIONADO: Expanded para evitar overflow
                                  child: Text(
                                    'Recursos Vitais Esgotados',
                                    style: TextStyle(
                                      fontSize: 16, // ✅ REDUZIDO: era 18
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16), // ✅ REDUZIDO: era 20

                            // Status dos recursos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildRecursoGameOver(
                                    '🔋', 'Energia', recursos.energia),
                                _buildRecursoGameOver(
                                    '💧', 'Água', recursos.agua),
                                _buildRecursoGameOver(
                                    '❤️', 'Saúde', recursos.saude),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30), // ✅ REDUZIDO: era 40

                      // ✅ ESTATÍSTICAS FINAIS NO GAME OVER (ADICIONADO)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.shade400.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.analytics,
                                    color: Colors.blue.shade300, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Estatísticas da Expedição',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Grid de estatísticas
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatGameOver(
                                    'Questões\nRespondidas',
                                    '${xpState.questoesTentadas}',
                                    Icons.quiz,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatGameOver(
                                    'Acertos',
                                    '${xpState.questoesCorretas}',
                                    Icons.check_circle,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatGameOver(
                                    'Precisão',
                                    '${(xpState.porcentagemAcerto * 100).toInt()}%',
                                    Icons
                                        .track_changes, // ✅ MUDEI: de target para track_changes
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatGameOver(
                                    'XP Total',
                                    '${xpState.xpTotal}',
                                    Icons.star,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatGameOver(
                                    'Nível',
                                    '${xpState.nivel}',
                                    Icons.trending_up,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatGameOver(
                                    'Tipo',
                                    _getTipoExploradorGameOver(xpState),
                                    Icons.emoji_events,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ✅ FRASE MOTIVACIONAL AMAZÔNICA
                      Container(
                        padding: const EdgeInsets.all(16), // ✅ REDUZIDO: era 20
                        decoration: BoxDecoration(
                          color: Colors.green.shade800.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade300.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.psychology,
                                color: Colors.yellow.shade300,
                                size: 24), // ✅ REDUZIDO: era 28
                            const SizedBox(height: 8), // ✅ REDUZIDO: era 12
                            Text(
                              '"Na Amazônia, como nos estudos,\no conhecimento é sua única arma\ncontra o desconhecido."',
                              style: TextStyle(
                                fontSize: 14, // ✅ REDUZIDO: era 16
                                fontStyle: FontStyle.italic,
                                color: Colors.green.shade100,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40), // ✅ REDUZIDO: era 50

                      // ✅ BOTÕES DE AÇÃO TEMÁTICOS
                      Column(
                        children: [
                          // Botão Tentar Novamente
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _tentarNovamente(context, ref),
                              icon: const Icon(Icons.refresh,
                                  size: 20), // ✅ REDUZIDO: era 24
                              label: const Text(
                                'NOVA EXPEDIÇÃO',
                                style: TextStyle(
                                  fontSize: 16, // ✅ REDUZIDO: era 18
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16), // ✅ REDUZIDO: era 18
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12), // ✅ REDUZIDO: era 16

                          // Botão Voltar ao Mapa
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/trilha-mapa'),
                              icon: Icon(Icons.map,
                                  color: Colors.green.shade200,
                                  size: 18), // ✅ REDUZIDO: era sem size
                              label: Text(
                                'VOLTAR AO ACAMPAMENTO',
                                style: TextStyle(
                                  fontSize: 14, // ✅ REDUZIDO: era 16
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade200,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14), // ✅ REDUZIDO: era 16
                                side: BorderSide(
                                  color: Colors.green.shade300,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20), // ✅ ADICIONADO: espaço final
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 CORRIGIDO: Mudou parâmetro de 'int valor' para 'double valor'
  Widget _buildRecursoGameOver(String emoji, String nome, double valor) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          nome,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 4),
        // 🔧 CORRIGIDO: Convertendo double para int na exibição
        Text(
          '${valor.toInt()}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valor <= 0 ? Colors.red.shade300 : Colors.orange.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: valor / 100,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color:
                    valor <= 0 ? Colors.red.shade400 : Colors.orange.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ ADICIONADOS: Métodos para as estatísticas no Game Over
  Widget _buildStatGameOver(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTipoExploradorGameOver(XpFlorestaState xpState) {
    final precisao = xpState.porcentagemAcerto;
    final nivel = xpState.nivel;

    if (precisao >= 0.9 && nivel >= 3) return 'Lendário';
    if (precisao >= 0.8 && nivel >= 2) return 'Experiente';
    if (precisao >= 0.7) return 'Corajoso';
    if (precisao >= 0.5) return 'Iniciante';
    return 'Determinado';
  }

  void _tentarNovamente(BuildContext context, WidgetRef ref) {
    // 🔧 CORRIGIDO: Usar método correto do provider
    ref.read(recursosProvider.notifier).reset();
    ref.read(xpFlorestaProvider.notifier).reset();

    // Ir para primeira questão
    context.go('/trilha-questao/0');
  }
}
