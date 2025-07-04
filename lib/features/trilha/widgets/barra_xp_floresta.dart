import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/xp_floresta_provider.dart';

class BarraXpFloresta extends ConsumerWidget {
  const BarraXpFloresta({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpState = ref.watch(xpFlorestaProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ✅ ÍCONE DO EXPLORADOR + NÍVEL
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Nível ${xpState.nivel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ✅ BARRA DE PROGRESSO + INFORMAÇÕES
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${xpState.xpTotal} XP',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${xpState.porcentagemAcerto.isNaN ? 0 : (xpState.porcentagemAcerto * 100).toInt()}% precisão',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: xpState.progressoNivel,
                    backgroundColor: Colors.green.shade900,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.lightGreen.shade300),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // ✅ ÍCONE FINAL (IGUAL AO OCEANO) - REPRESENTANDO NATUREZA
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.lightGreen.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.nature,
                color: Colors.green.shade800,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
