import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recursos_oceano_provider.dart';
import '../providers/xp_oceano_provider.dart'; // ✅ NOVO: Provider de XP

class TrilhaOceanoResultadosScreen extends ConsumerWidget {
  const TrilhaOceanoResultadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursos = ref.watch(recursosOceanoProvider);
    final xpState = ref.watch(xpOceanoProvider); // ✅ NOVO: Estado do XP

    final pontuacaoTotal =
        recursos.pressao + recursos.oxigenio + recursos.temperatura;

    // ✅ CLASSIFICAÇÃO MELHORADA (baseada no padrão floresta)
    String classificacao;
    String mensagem;
    IconData icone;
    Color corClassificacao;

    if (pontuacaoTotal >= 270 && xpState.nivel >= 5) {
      classificacao = "LENDA DOS OCEANOS";
      mensagem = "Você é um verdadeiro mestre das profundezas oceânicas!";
      icone = Icons.military_tech;
      corClassificacao = Colors.amber;
    } else if (pontuacaoTotal >= 240) {
      classificacao = "EXPLORADOR MESTRE";
      mensagem = "Você dominou completamente as profundezas oceânicas!";
      icone = Icons.scuba_diving;
      corClassificacao = Colors.blue;
    } else if (pontuacaoTotal >= 180) {
      classificacao = "MERGULHADOR EXPERIENTE";
      mensagem = "Excelente conhecimento dos oceanos!";
      icone = Icons.sailing;
      corClassificacao = Colors.green;
    } else if (pontuacaoTotal >= 120) {
      classificacao = "EXPLORADOR OCEÂNICO";
      mensagem = "Bom trabalho navegando pelas águas!";
      icone = Icons.pool;
      corClassificacao = Colors.orange;
    } else {
      classificacao = "NOVATO MARINHO";
      mensagem = "Continue estudando para mergulhar mais fundo!";
      icone = Icons.beach_access;
      corClassificacao = Colors.grey;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade800,
              Colors.indigo.shade900
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Ícone de conquista
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      icone,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título de conclusão
                  const Text(
                    'EXPLORAÇÃO CONCLUÍDA!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Classificação
                  Text(
                    classificacao,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      mensagem,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ✅ CARD DE ESTATÍSTICAS COMPLETO (padrão floresta)
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Relatório da Expedição',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Recursos Vitais Finais
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildEstatistica('🫁', 'Oxigênio',
                                  recursos.oxigenio, Colors.cyan),
                              _buildEstatistica('🌡️', 'Temperatura',
                                  recursos.temperatura, Colors.orange),
                              _buildEstatistica('⚡', 'Pressão',
                                  recursos.pressao, Colors.purple),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ✅ NOVO: Estatísticas de XP e Progressão
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade50,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Progressão do Mergulhador',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyan.shade800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildXpStat('Nível', '${xpState.nivel}'),
                                    _buildXpStat(
                                        'XP Total', '${xpState.xpTotal}'),
                                    _buildXpStat('Precisão',
                                        '${(xpState.porcentagemAcerto * 100).toInt()}%'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pontuação Total
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star,
                                    color: Colors.blue.shade600, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Pontuação Total: $pontuacaoTotal/300',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ✅ BOTÕES COM RESET COMPLETO (padrão floresta)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _novaAventura(context, ref),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text(
                            'Nova Aventura',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _explorarOutrasTrilhas(context, ref),
                          icon: const Icon(Icons.terrain, size: 18),
                          label: const Text(
                            'Outras Trilhas',
                            style: TextStyle(fontSize: 13),
                          ),
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== WIDGETS HELPERS =====

  Widget _buildEstatistica(String emoji, String nome, int valor, Color cor) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(nome,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$valor%',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: cor)),
      ],
    );
  }

  Widget _buildXpStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.cyan.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.cyan.shade700,
          ),
        ),
      ],
    );
  }

  // ===== FUNÇÕES DE NAVEGAÇÃO COM RESET =====

  /// ✅ NOVA AVENTURA - Reset completo dos providers oceânicos
  void _novaAventura(BuildContext context, WidgetRef ref) {
    // Reset completo de todos os providers oceânicos
    ref.read(recursosOceanoProvider.notifier).reset();
    ref.read(xpOceanoProvider.notifier).reset();

    // Navegar para o mapa da trilha oceânica
    context.go('/trilha-oceano-mapa');
  }

  /// ✅ EXPLORAR OUTRAS TRILHAS - Reset apenas recursos (mantém XP como conquista)
  void _explorarOutrasTrilhas(BuildContext context, WidgetRef ref) {
    // Reset apenas dos recursos (XP mantém como conquista)
    ref.read(recursosOceanoProvider.notifier).reset();

    // Navegar para o menu principal
    context.go('/trilha-mapa');
  }
}
