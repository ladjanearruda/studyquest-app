import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrilhaOceanoMapaScreen extends StatelessWidget {
  const TrilhaOceanoMapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone Oceano
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.waves,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Título
                const Text(
                  'Exploração do Oceano Atlântico',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Subtítulo
                const Text(
                  'Mergulhe nas profundezas do conhecimento marinho!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                const Text(
                  'Gerencie sua pressão, oxigênio e temperatura para sobreviver às profundezas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Botão Iniciar
                ElevatedButton.icon(
                  onPressed: () => context.go('/trilha-oceano-questao/0'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Exploração Oceânica'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botão Voltar
                TextButton.icon(
                  onPressed: () => context.go('/trilha-mapa'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  label: const Text(
                    'Voltar à Floresta',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
