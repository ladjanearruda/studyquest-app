// lib/shared/widgets/fonte_tag_widget.dart
// Tag visual discreta exibida acima do enunciado para questões de vestibular.
// Questões autorais (StudyQuest Original, autoral, null) não exibem nada.

import 'package:flutter/material.dart';

class FonteTagWidget extends StatelessWidget {
  final String? fonte;

  const FonteTagWidget({super.key, this.fonte});

  bool get _deveMostrar {
    if (fonte == null || fonte!.isEmpty) return false;
    final lower = fonte!.toLowerCase();
    if (lower.contains('studyquest')) return false; // StudyQuest Original, StudyQuest-Original, etc.
    if (lower.contains('autoral')) return false;
    return true;
  }

  bool get _ehAdaptada => fonte?.contains('-adaptada') ?? false;

  @override
  Widget build(BuildContext context) {
    if (!_deveMostrar) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[300]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '[$fonte]',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.amber[900],
            ),
          ),
          const SizedBox(width: 4),
          const Text('🏛️', style: TextStyle(fontSize: 12)),
          if (_ehAdaptada)
            const Text('✏️', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
