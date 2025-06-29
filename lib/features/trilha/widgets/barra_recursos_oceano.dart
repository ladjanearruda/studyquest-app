import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recursos_oceano_provider.dart';

class BarraRecursosOceano extends ConsumerWidget {
  const BarraRecursosOceano({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursos = ref.watch(recursosOceanoProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRecurso('⚡', 'Pressão', recursos.pressao, Colors.purple),
          _buildRecurso('🫁', 'Oxigênio', recursos.oxigenio, Colors.cyan),
          _buildRecurso(
              '🌡️', 'Temperatura', recursos.temperatura, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildRecurso(String emoji, String nome, int valor, Color cor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(nome,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: valor / 100,
            child: Container(
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: cor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text('$valor%',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
