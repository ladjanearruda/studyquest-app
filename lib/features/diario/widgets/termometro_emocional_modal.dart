// lib/features/diario/widgets/termometro_emocional_modal.dart
// ✅ V9.0 - Sprint 9: Modal do Termômetro Emocional pós-sessão
// 📅 Criado: 18/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_emotion_model.dart';

/// Modal que aparece após cada sessão de questões
/// Pergunta como o usuário se sentiu estudando
class TermometroEmocionalModal extends ConsumerStatefulWidget {
  final double accuracy; // % de acertos da sessão
  final int questionsAnswered;
  final Duration sessionDuration;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const TermometroEmocionalModal({
    super.key,
    required this.accuracy,
    required this.questionsAnswered,
    required this.sessionDuration,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  ConsumerState<TermometroEmocionalModal> createState() =>
      _TermometroEmocionalModalState();

  /// Método estático para mostrar o modal
  static Future<EmotionLevel?> show({
    required BuildContext context,
    required double accuracy,
    required int questionsAnswered,
    required Duration sessionDuration,
  }) async {
    return showModalBottomSheet<EmotionLevel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => _TermometroEmocionalContent(
        accuracy: accuracy,
        questionsAnswered: questionsAnswered,
        sessionDuration: sessionDuration,
      ),
    );
  }
}

class _TermometroEmocionalModalState
    extends ConsumerState<TermometroEmocionalModal> {
  EmotionLevel? _selectedEmotion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Título
              const Text(
                '😊 Como você se sentiu?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Sua resposta nos ajuda a melhorar sua experiência',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Emojis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: EmotionLevel.values.map((emotion) {
                  final isSelected = _selectedEmotion == emotion;
                  return _buildEmotionButton(emotion, isSelected);
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Botões
              Row(
                children: [
                  // Pular
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                        widget.onSkip();
                      },
                      child: Text(
                        'Pular',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Confirmar
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedEmotion != null
                          ? () {
                              Navigator.pop(context, _selectedEmotion);
                              widget.onComplete();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionButton(EmotionLevel emotion, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? _getEmotionColor(emotion).withOpacity(0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _getEmotionColor(emotion) : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _getEmotionColor(emotion).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              emotion.emoji,
              style: TextStyle(
                fontSize: isSelected ? 36 : 32,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getEmotionShortLabel(emotion),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? _getEmotionColor(emotion)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEmotionColor(EmotionLevel emotion) {
    switch (emotion) {
      case EmotionLevel.veryBad:
        return Colors.red.shade600;
      case EmotionLevel.bad:
        return Colors.orange.shade600;
      case EmotionLevel.neutral:
        return Colors.amber.shade600;
      case EmotionLevel.good:
        return Colors.lightGreen.shade600;
      case EmotionLevel.veryGood:
        return Colors.green.shade600;
    }
  }

  String _getEmotionShortLabel(EmotionLevel emotion) {
    switch (emotion) {
      case EmotionLevel.veryBad:
        return 'Péssimo';
      case EmotionLevel.bad:
        return 'Ruim';
      case EmotionLevel.neutral:
        return 'Normal';
      case EmotionLevel.good:
        return 'Bem';
      case EmotionLevel.veryGood:
        return 'Ótimo';
    }
  }
}

/// Widget de conteúdo separado para uso com showModalBottomSheet
class _TermometroEmocionalContent extends StatefulWidget {
  final double accuracy;
  final int questionsAnswered;
  final Duration sessionDuration;

  const _TermometroEmocionalContent({
    required this.accuracy,
    required this.questionsAnswered,
    required this.sessionDuration,
  });

  @override
  State<_TermometroEmocionalContent> createState() =>
      _TermometroEmocionalContentState();
}

class _TermometroEmocionalContentState
    extends State<_TermometroEmocionalContent> {
  EmotionLevel? _selectedEmotion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Ícone
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Text('🌡️', style: TextStyle(fontSize: 32)),
              ),

              const SizedBox(height: 16),

              // Título
              const Text(
                'Como você se sentiu estudando?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Isso nos ajuda a entender seu aprendizado',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Emojis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: EmotionLevel.values.map((emotion) {
                  final isSelected = _selectedEmotion == emotion;
                  return _buildEmotionButton(emotion, isSelected);
                }).toList(),
              ),

              // Label do selecionado
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _selectedEmotion != null
                    ? Container(
                        key: ValueKey(_selectedEmotion),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getEmotionColor(_selectedEmotion!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _selectedEmotion!.label,
                          style: TextStyle(
                            color: _getEmotionColor(_selectedEmotion!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox(height: 36),
              ),

              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  // Pular
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pular',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Confirmar
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedEmotion != null
                          ? () => Navigator.pop(context, _selectedEmotion)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionButton(EmotionLevel emotion, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? _getEmotionColor(emotion).withOpacity(0.15)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _getEmotionColor(emotion) : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                emotion.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEmotionColor(EmotionLevel emotion) {
    switch (emotion) {
      case EmotionLevel.veryBad:
        return Colors.red.shade600;
      case EmotionLevel.bad:
        return Colors.orange.shade600;
      case EmotionLevel.neutral:
        return Colors.amber.shade600;
      case EmotionLevel.good:
        return Colors.lightGreen.shade600;
      case EmotionLevel.veryGood:
        return Colors.green.shade600;
    }
  }
}
