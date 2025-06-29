import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recursos_oceano_provider.dart';

class TrilhaOceanoResultadosScreen extends ConsumerWidget {
  const TrilhaOceanoResultadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursos = ref.watch(recursosOceanoProvider);
    final pontuacaoTotal =
        recursos.pressao + recursos.oxigenio + recursos.temperatura;

    String classificacao;
    String mensagem;
    IconData icone;

    if (pontuacaoTotal >= 240) {
      classificacao = "EXPLORADOR MESTRE";
      mensagem = "Você dominou completamente as profundezas oceânicas!";
      icone = Icons.military_tech;
    } else if (pontuacaoTotal >= 180) {
      classificacao = "MERGULHADOR EXPERIENTE";
      mensagem = "Excelente conhecimento dos oceanos!";
      icone = Icons.scuba_diving;
    } else if (pontuacaoTotal >= 120) {
      classificacao = "EXPLORADOR OCEÂNICO";
      mensagem = "Bom trabalho navegando pelas águas!";
      icone = Icons.sailing;
    } else {
      classificacao = "NOVATO MARINHO";
      mensagem = "Continue estudando para mergulhar mais fundo!";
      icone = Icons.pool;
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
            // ✅ ADICIONADO: Scroll para evitar overflow
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
                  const SizedBox(height: 20), // ✅ Espaço inicial

                  // Ícone de conquista
                  Container(
                    padding: const EdgeInsets.all(20), // ✅ REDUZIDO: era 25
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      icone,
                      size: 60, // ✅ REDUZIDO: era 80
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24), // ✅ REDUZIDO: era 30

                  // Título de conclusão
                  Text(
                    'EXPLORAÇÃO CONCLUÍDA!',
                    style: TextStyle(
                      fontSize: 28, // ✅ REDUZIDO: era 32
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16), // ✅ REDUZIDO: era 20

                  // Classificação
                  Text(
                    classificacao,
                    style: TextStyle(
                      fontSize: 20, // ✅ REDUZIDO: era 24
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8), // ✅ REDUZIDO: era 10

                  Padding(
                    // ✅ ADICIONADO: Padding para evitar overflow texto
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      mensagem,
                      style: const TextStyle(
                        fontSize: 15, // ✅ REDUZIDO: era 16
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32), // ✅ REDUZIDO: era 40

                  // Card de estatísticas
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20), // ✅ REDUZIDO: era 25
                      child: Column(
                        children: [
                          Text(
                            'Recursos Vitais Finais',
                            style: TextStyle(
                              fontSize: 16, // ✅ REDUZIDO: era 18
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 16), // ✅ REDUZIDO: era 20
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildEstatistica('⚡', 'Pressão',
                                  recursos.pressao, Colors.purple),
                              _buildEstatistica('🫁', 'Oxigênio',
                                  recursos.oxigenio, Colors.cyan),
                              _buildEstatistica('🌡️', 'Temperatura',
                                  recursos.temperatura, Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 16), // ✅ REDUZIDO: era 20
                          Container(
                            padding:
                                const EdgeInsets.all(12), // ✅ REDUZIDO: era 15
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star,
                                    color: Colors.blue.shade600,
                                    size: 20), // ✅ Size definido
                                const SizedBox(width: 8),
                                Flexible(
                                  // ✅ ADICIONADO: Flexible para texto longo
                                  child: Text(
                                    'Pontuação Total: $pontuacaoTotal/300',
                                    style: TextStyle(
                                      fontSize: 15, // ✅ REDUZIDO: era 16
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
                  const SizedBox(height: 32), // ✅ REDUZIDO: era 40

                  // Botões de navegação
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(recursosOceanoProvider.notifier).reset();
                            context.go('/trilha-oceano-mapa');
                          },
                          icon: const Icon(Icons.refresh,
                              size: 18), // ✅ Size definido
                          label: const Text(
                            'Explorar Novamente',
                            style: TextStyle(
                                fontSize: 13), // ✅ REDUZIDO para caber
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // ✅ REDUZIDO: era 15
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12), // ✅ REDUZIDO: era 15
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go('/trilha-mapa');
                          },
                          icon: const Icon(Icons.terrain,
                              size: 18), // ✅ Size definido
                          label: const Text(
                            'Outras Trilhas',
                            style: TextStyle(
                                fontSize: 13), // ✅ REDUZIDO para caber
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // ✅ REDUZIDO: era 15
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20), // ✅ ADICIONADO: Espaço final
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstatistica(String emoji, String nome, int valor, Color cor) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)), // ✅ REDUZIDO: era 24
        const SizedBox(height: 4), // ✅ REDUZIDO: era 5
        Text(nome,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold)), // ✅ REDUZIDO: era 12
        const SizedBox(height: 4), // ✅ REDUZIDO: era 5
        Text('$valor%',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cor)), // ✅ REDUZIDO: era 16
      ],
    );
  }
}
