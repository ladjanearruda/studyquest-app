// lib/features/modo_descoberta/screens/modo_descoberta_questao_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/modo_descoberta_provider.dart';

/// Tela de questões do Modo Descoberta
/// Apresenta 5 questões com timer de 25 segundos cada
class ModoDescobertaQuestaoScreen extends ConsumerStatefulWidget {
  const ModoDescobertaQuestaoScreen({super.key});

  @override
  ConsumerState<ModoDescobertaQuestaoScreen> createState() =>
      _ModoDescobertaQuestaoScreenState();
}

class _ModoDescobertaQuestaoScreenState
    extends ConsumerState<ModoDescobertaQuestaoScreen>
    with TickerProviderStateMixin {
  late AnimationController _questionController;
  late AnimationController _optionsController;
  late AnimationController _timerController;

  Timer? _questionTimer;
  int _tempoRestante = 25; // 25 segundos por questão
  int? _alternativaSelecionada;
  bool _respondida = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _optionsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
  }

  void _startAnimations() {
    _questionController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _optionsController.forward();
    });
    _timerController.forward();
  }

  void _startTimer() {
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tempoRestante > 0 && !_respondida) {
        setState(() {
          _tempoRestante--;
        });
      } else {
        timer.cancel();
        if (!_respondida) {
          _responderQuestao(-1); // Timeout
        }
      }
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _questionController.dispose();
    _optionsController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _responderQuestao(int indice) {
    if (_respondida) return;

    setState(() {
      _alternativaSelecionada = indice;
      _respondida = true;
    });

    _questionTimer?.cancel();

    // Salva resposta no provider usando método correto
    if (indice >= 0) {
      ref.read(modoDescobertaProvider.notifier).responderQuestao(indice);
    } else {
      // Timeout - registra como resposta inválida
      ref.read(modoDescobertaProvider.notifier).pularQuestao();
    }

    // Aguarda feedback visual e avança
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _avancarOuFinalizar();
      }
    });
  }

  void _avancarOuFinalizar() {
    final state = ref.read(modoDescobertaProvider);

    // Avança para próxima questão usando método correto
    ref.read(modoDescobertaProvider.notifier).avancarQuestao();

    // Verifica se finalizou
    final newState = ref.read(modoDescobertaProvider);
    if (newState.status == ModoDescobertaStatus.finalizado) {
      // Vai para tela de resultado
      context.pushReplacement('/modo-descoberta/resultado');
    } else {
      // Reinicia animações para próxima questão
      _reiniciarAnimacoes();
    }
  }

  void _reiniciarAnimacoes() {
    setState(() {
      _tempoRestante = 25;
      _alternativaSelecionada = null;
      _respondida = false;
    });

    _questionController.reset();
    _optionsController.reset();
    _timerController.reset();

    _startAnimations();
    _startTimer();
  }

  String _getImagemParaQuestao(questao) {
    final assunto = questao.assunto.toLowerCase();
    final enunciado = questao.enunciado.toLowerCase();

    // GEO - Geometria, áreas, medidas, formas
    if (assunto.contains('geometria') ||
        assunto.contains('área') ||
        assunto.contains('perímetro') ||
        assunto.contains('triângulo') ||
        assunto.contains('retângulo') ||
        assunto.contains('teorema') ||
        enunciado.contains('altura') ||
        enunciado.contains('lado') ||
        enunciado.contains('metro')) {
      return 'assets/images/questoes/modo_descoberta/geo.jpg';
    }

    // LAB - Equações, álgebra, sistemas
    if (assunto.contains('equação') ||
        assunto.contains('sistema') ||
        assunto.contains('álgebra') ||
        enunciado.contains('resolva') ||
        enunciado.contains('x =')) {
      return 'assets/images/questoes/modo_descoberta/lab.jpg';
    }

    // PATTERNS - Funções, sequências
    if (assunto.contains('função') ||
        assunto.contains('sequência') ||
        enunciado.contains('f(x)')) {
      return 'assets/images/questoes/modo_descoberta/patterns.jpg';
    }

    // TECH - Probabilidade, estatística, porcentagem
    if (assunto.contains('probabilidade') ||
        assunto.contains('%') ||
        enunciado.contains('chance')) {
      return 'assets/images/questoes/modo_descoberta/tech.jpg';
    }

    // PRINCIPAL - Padrão
    return 'assets/images/questoes/modo_descoberta/principal.jpg';
  }

  // SUBSTITUIR toda a seção do build() por esta versão corrigida:

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modoDescobertaProvider);
    final questao = state.questaoAtualObj;

    if (questao == null || state.status != ModoDescobertaStatus.emAndamento) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // Header com progresso
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🧭 Descobrindo seu nível',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _tempoRestante <= 5
                              ? Colors.red[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _tempoRestante <= 5
                                ? Colors.red[300]!
                                : Colors.orange[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: _tempoRestante <= 5
                                  ? Colors.red[600]
                                  : Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_tempoRestante}s',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _tempoRestante <= 5
                                    ? Colors.red[600]
                                    : Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Barra de progresso
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questão ${state.questaoAtual + 1} de ${state.questoes.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: MediaQuery.of(context).size.width *
                                state.progressoPercentual *
                                0.86,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange[400]!,
                                  Colors.orange[600]!
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 🎯 QUESTÃO COM IMAGEM - CORRIGIDA
                    AnimatedBuilder(
                      animation: _questionController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset:
                              Offset(0, 20 * (1 - _questionController.value)),
                          child: Opacity(
                            opacity: _questionController.value,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                        alpha: 0.08), // 🎯 CORRIGIDO
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // 🎯 IMAGEM CONTEXTUAL
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: 0.05), // 🎯 CORRIGIDO
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        _getImagemParaQuestao(questao),
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.orange[400]!,
                                                  Colors.orange[600]!
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('🧭',
                                                      style: TextStyle(
                                                          fontSize: 24)),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Modo Descoberta',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  // QUESTÃO
                                  Text(
                                    questao.enunciado,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E7D32),
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${questao.assunto} • ${questao.emojiDificuldade}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // 🎯 ALTERNATIVAS - CORRIGIDAS
                    AnimatedBuilder(
                      animation: _optionsController,
                      builder: (context, child) {
                        return Column(
                          children:
                              questao.alternativas.asMap().entries.map((entry) {
                            final indice = entry.key;
                            final alternativa = entry.value;
                            final delay = indice * 0.1;

                            return Transform.translate(
                              offset: Offset(
                                30 *
                                    (1 -
                                        Curves.easeOut.transform(
                                            (_optionsController.value - delay)
                                                .clamp(0.0, 1.0))),
                                0,
                              ),
                              child: Opacity(
                                opacity: Curves.easeOut.transform(
                                    (_optionsController.value - delay)
                                        .clamp(0.0, 1.0)),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: _buildAlternativaCard(
                                      indice, alternativa, questao),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 🎯 MÉTODO _buildAlternativaCard CORRIGIDO:
  Widget _buildAlternativaCard(int indice, String alternativa, questao) {
    final bool isSelected = _alternativaSelecionada == indice;
    final bool isCorrect = questao.isRespostaCorreta(indice);
    final bool showResult = _respondida;

    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;
    IconData? icon;

    if (showResult) {
      if (isSelected && isCorrect) {
        cardColor = Colors.green[50]!;
        borderColor = Colors.green[500]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        cardColor = Colors.red[50]!;
        borderColor = Colors.red[500]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
      } else if (!isSelected && isCorrect) {
        cardColor = Colors.green[50]!;
        borderColor = Colors.green[300]!;
        textColor = Colors.green[600]!;
        icon = Icons.check_circle_outline;
      }
    } else if (isSelected) {
      cardColor = Colors.orange[50]!;
      borderColor = Colors.orange[500]!;
      textColor = Colors.orange[700]!;
    }

    return GestureDetector(
      onTap: _respondida ? null : () => _responderQuestao(indice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.2), // 🎯 CORRIGIDO
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.2), // 🎯 CORRIGIDO
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + indice), // A, B, C, D
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                alternativa,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, color: textColor, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
