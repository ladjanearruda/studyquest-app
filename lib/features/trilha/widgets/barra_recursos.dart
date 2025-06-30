import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recursos_provider.dart';

class BarraRecursos extends ConsumerWidget {
  const BarraRecursos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recursos = ref.watch(recursosProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRecurso('⚡', 'Energia', recursos.energia, Colors.orange),
          _buildRecurso('💧', 'Água', recursos.agua, Colors.blue),
          _buildRecurso('❤️', 'Saúde', recursos.saude, Colors.red),
        ],
      ),
    );
  }

  // 🔧 CORRIGIDO: Mudou parâmetro de 'int valor' para 'double valor'
  Widget _buildRecurso(String emoji, String nome, double valor, Color cor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(nome, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // 🔧 CORRIGIDO: Convertendo double para int na exibição
        Text('${valor.toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}
