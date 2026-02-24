// lib/features/diario/widgets/anotar_erro_modal.dart
// ✅ V9.2 - Sprint 9 Fase 2: Modal pós-erro com questionId
// 📅 Atualizado: 22/02/2026
// 🎯 Agora recebe questionId real do Firebase

import 'package:flutter/material.dart';
import '../models/diary_emotion_model.dart';

/// Classe para transportar dados da anotação
class DiaryAnnotation {
  final String questionId; // ✅ V9.2: ID real da questão no Firebase
  final String questionText;
  final String correctAnswer;
  final String userAnswer;
  final String subject;
  final String learning;
  final String strategy;
  final int difficulty;
  final EmotionLevel emotion;

  DiaryAnnotation({
    required this.questionId, // ✅ V9.2: Agora obrigatório
    required this.questionText,
    required this.correctAnswer,
    required this.userAnswer,
    required this.subject,
    required this.learning,
    required this.strategy,
    required this.difficulty,
    required this.emotion,
  });
}

/// Modal que aparece após errar uma questão
/// Pergunta se o usuário quer anotar a lição no Diário
class AnotarErroModal {
  /// Mostrar o modal e retornar a anotação ou null
  static Future<DiaryAnnotation?> show({
    required BuildContext context,
    required String questionId, // ✅ V9.2: ID real da questão
    required String questionText,
    required String correctAnswer,
    required String userAnswer,
    required String subject,
    String? explicacao,
  }) async {
    return showModalBottomSheet<DiaryAnnotation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => _AnotarErroContent(
        questionId: questionId,
        questionText: questionText,
        correctAnswer: correctAnswer,
        userAnswer: userAnswer,
        subject: subject,
        explicacao: explicacao,
      ),
    );
  }
}

/// Conteúdo do modal
class _AnotarErroContent extends StatefulWidget {
  final String questionId;
  final String questionText;
  final String correctAnswer;
  final String userAnswer;
  final String subject;
  final String? explicacao;

  const _AnotarErroContent({
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.userAnswer,
    required this.subject,
    this.explicacao,
  });

  @override
  State<_AnotarErroContent> createState() => _AnotarErroContentState();
}

class _AnotarErroContentState extends State<_AnotarErroContent> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  final _learningController = TextEditingController();
  final _strategyController = TextEditingController();
  int _difficulty = 3;
  EmotionLevel _emotion = EmotionLevel.neutral;

  @override
  void dispose() {
    _learningController.dispose();
    _strategyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _showForm ? _buildForm() : _buildInitialPrompt(),
        ),
      ),
    );
  }

  /// Tela inicial: "Quer anotar essa lição?"
  Widget _buildInitialPrompt() {
    return SafeArea(
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Text('🌱', style: TextStyle(fontSize: 48)),
            ),

            const SizedBox(height: 20),

            // Título
            const Text(
              'Plantar essa lição no Diário?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Anotar seus erros ajuda a fixar o conteúdo e evitar repeti-los!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Preview da questão
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Matéria
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.subject.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Questão (truncada)
                  Text(
                    widget.questionText.length > 100
                        ? '${widget.questionText.substring(0, 100)}...'
                        : widget.questionText,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Respostas
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnswerChip(
                          '❌ ${widget.userAnswer}',
                          Colors.red.shade100,
                          Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAnswerChip(
                          '✅ ${widget.correctAnswer}',
                          Colors.green.shade100,
                          Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // XP bonus
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+25 XP por anotação reflexiva!',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
                    child:
                        const Text('Continuar', style: TextStyle(fontSize: 15)),
                  ),
                ),

                const SizedBox(width: 12),

                // Anotar
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showForm = true;
                      });
                    },
                    icon: const Icon(Icons.edit_note, size: 20),
                    label: const Text('Sim, anotar!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildAnswerChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  /// Formulário de anotação
  Widget _buildForm() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showForm = false;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '📝 Anotar Lição',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Campo 1: O que aprendi
              const Text(
                '💡 O que aprendi com esse erro?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _learningController,
                maxLength: 280,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex: A derivada de x² é 2x, não x...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.green.shade500, width: 2),
                  ),
                  counterStyle: TextStyle(color: Colors.grey.shade500),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escreva o que aprendeu';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo 2: Como evitar
              const Text(
                '🎯 Como vou evitar esse erro?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _strategyController,
                maxLength: 280,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ex: Sempre multiplicar o expoente...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.green.shade500, width: 2),
                  ),
                  counterStyle: TextStyle(color: Colors.grey.shade500),
                ),
              ),

              const SizedBox(height: 16),

              // Dificuldade
              const Text(
                '⭐ Dificuldade percebida',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _difficulty = starIndex;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex <= _difficulty
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              Center(
                child: Text(
                  _getDifficultyLabel(_difficulty),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Emoção
              const Text(
                '😊 Como você se sentiu?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: EmotionLevel.values.map((emotion) {
                  final isSelected = _emotion == emotion;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _emotion = emotion;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green.shade500
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        emotion.emoji,
                        style: TextStyle(fontSize: isSelected ? 28 : 24),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveAnnotation,
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar Anotação (+25 XP)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Muito fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Médio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muito difícil';
      default:
        return 'Médio';
    }
  }

  void _saveAnnotation() {
    if (_formKey.currentState!.validate()) {
      final annotation = DiaryAnnotation(
        questionId: widget.questionId, // ✅ V9.2: ID real
        questionText: widget.questionText,
        correctAnswer: widget.correctAnswer,
        userAnswer: widget.userAnswer,
        subject: widget.subject,
        learning: _learningController.text.trim(),
        strategy: _strategyController.text.trim(),
        difficulty: _difficulty,
        emotion: _emotion,
      );

      Navigator.pop(context, annotation);
    }
  }
}
