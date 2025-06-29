import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrilhaMapaScreen extends StatelessWidget {
  const TrilhaMapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa da Trilha Amazônica')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forest, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text('Trilha da Floresta Amazônica',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Prepare-se para uma aventura educacional!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => context.go('/trilha-questao/0'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar Primeira Questão'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            // Adicionar após o botão da Floresta
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go('/trilha-oceano-mapa'),
              icon: const Icon(Icons.waves),
              label: const Text('Explorar Oceano Atlântico'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
