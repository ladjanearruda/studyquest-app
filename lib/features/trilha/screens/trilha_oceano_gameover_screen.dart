import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recursos_oceano_provider.dart';

class TrilhaOceanoGameOverScreen extends ConsumerWidget {
  const TrilhaOceanoGameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const SizedBox(height: 40), // Espaço no topo

                // Ícone de afogamento
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.water_damage,
                    size: 80, // Reduzido de 120
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20), // Reduzido de 30

                // Título
                const Text(
                  'EMERGÊNCIA OCEÂNICA',
                  style: TextStyle(
                    fontSize: 28, // Reduzido de 36
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10), // Reduzido de 15

                // Subtítulo
                const Text(
                  'Seus recursos vitais se esgotaram nas profundezas!',
                  style: TextStyle(
                    fontSize: 16, // Reduzido de 18
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8), // Reduzido de 10

                const Text(
                  'A pressão oceânica, falta de oxigênio ou frio extremo foram fatais.',
                  style: TextStyle(
                    fontSize: 13, // Reduzido de 14
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30), // Reduzido de 50

                // Mensagem de socorro
                Card(
                  color: Colors.white.withValues(alpha: 0.95),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20), // Reduzido de 25
                    child: Column(
                      children: [
                        Icon(
                          Icons.sos,
                          size: 40, // Reduzido de 50
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(height: 12), // Reduzido de 15
                        Text(
                          'Dica de Mergulho Seguro',
                          style: TextStyle(
                            fontSize: 16, // Reduzido de 18
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8), // Reduzido de 10
                        const Text(
                          'Na exploração oceânica, cada decisão afeta sua sobrevivência. Estude biologia marinha e física da pressão para mergulhar com segurança!',
                          style:
                              TextStyle(fontSize: 13, height: 1.4), // Reduzido
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Reduzido de 40

                // Botões de resgate
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(recursosOceanoProvider.notifier).reset();
                          context.go('/trilha-oceano-mapa');
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Resgate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12), // Reduzido
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.go('/trilha-mapa');
                        },
                        icon: const Icon(Icons.terrain),
                        label: const Text('Voltar à Terra'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12), // Reduzido
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // Espaço no final
              ],
            ),
          ),
        ),
      ),
    );
  }
}
