import 'package:flutter/material.dart';

class BarraRecursosPersonalizada extends StatelessWidget {
  final Map<String, double> recursos;

  const BarraRecursosPersonalizada({
    super.key,
    required this.recursos,
  });

  Color _getResourceColor(double value) {
    if (value <= 20) return Colors.red;
    if (value <= 50) return Colors.orange;
    return Colors.green;
  }

  String _getResourceIcon(String type) {
    switch (type) {
      case 'energia':
        return '⚡';
      case 'agua':
        return '💧';
      case 'saude':
        return '❤️';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: recursos.entries.map((entry) {
          final tipo = entry.key;
          final valor = entry.value;
          final cor = _getResourceColor(valor);
          final icone = _getResourceIcon(tipo);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text(icone, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tipo.substring(0, 1).toUpperCase() +
                                  tipo.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${valor.toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: valor / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(cor),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
