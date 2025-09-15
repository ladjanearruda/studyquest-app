import 'package:flutter/material.dart';

class AvatarQuestao extends StatelessWidget {
  final dynamic avatarData;
  final int timeLeft;

  const AvatarQuestao({
    super.key,
    this.avatarData,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar principal grande
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Indicadores do avatar
        const SizedBox(height: 8),

        // Badge de nível
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade500,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Nv. 3',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Indicador de estado baseado no timer
        if (timeLeft <= 10) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.yellow.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '💭',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
