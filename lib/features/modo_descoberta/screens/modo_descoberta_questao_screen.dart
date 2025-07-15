// lib/features/modo_descoberta/screens/modo_descoberta_questao_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../providers/modo_descoberta_provider.dart';

class ModoDescobertaQuestaoScreen extends ConsumerStatefulWidget {
  const ModoDescobertaQuestaoScreen({super.key});

  @override
  ConsumerState<ModoDescobertaQuestaoScreen> createState() =>
      _ModoDescobertaQuestaoScreenState();
}

class _ModoDescobertaQuestaoScreenState
    extends ConsumerState<ModoDescobertaQuestaoScreen> {
  int? _respostaSelecionada;
  Timer? _timer;
  int _tempoRestante = 25;
  bool _processandoResposta = false;

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tempoRestante > 0) {
        setState(() {
          _tempoRestante--;
        });
      } else {
        _proximaQuestao();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selecionarResposta(int index) {
    if (_processandoResposta) return;
    setState(() {
      _respostaSelecionada = index;
    });
  }

  void _proximaQuestao() {
    _timer?.cancel();

    final resposta = _respostaSelecionada ?? -1;

    // Captura dados para feedback ANTES de enviar resposta
    final state = ref.read(modoDescobertaProvider);
    final questao = state.questaoAtualObj;

    // Envia para provider
    ref.read(modoDescobertaProvider.notifier).responderQuestao(resposta);

    // Feedback completo com resposta correta
    if (_respostaSelecionada != null && questao != null) {
      final isCorreto = questao.isRespostaCorreta(_respostaSelecionada!);
      final respostaCorreta = questao.alternativas[questao.respostaCorreta];
      final minhaResposta = questao.alternativas[_respostaSelecionada!];

      String mensagem;
      if (isCorreto) {
        mensagem = "✅ Correto! Resposta: $respostaCorreta";
      } else {
        mensagem =
            "❌ Incorreto. Sua resposta: $minhaResposta\n✅ Correto: $respostaCorreta";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor: isCorreto ? Colors.green[600] : Colors.red[600],
          duration: const Duration(milliseconds: 2000), // 2 segundos para ler
        ),
      );
    }

    // Reset simples
    if (mounted) {
      setState(() {
        _respostaSelecionada = null;
        _tempoRestante = 25;
        _processandoResposta = false;
      });
    }

    // Verificar status após delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final newState = ref.read(modoDescobertaProvider);

      if (newState.status == ModoDescobertaStatus.finalizado) {
        context.go('/modo-descoberta/resultado');
      } else if (newState.status == ModoDescobertaStatus.emAndamento) {
        _iniciarTimer();
      }
    });
  }

  // 🔥 ÚLTIMA CHANCE - MÁXIMO CONTROLE POSSÍVEL
  Widget _buildImagemQuestao() {
    final state = ref.watch(modoDescobertaProvider);
    final questao = state.questaoAtualObj;

    if (questao == null) {
      return const SizedBox.shrink();
    }

    // Sistema híbrido
    final imagemPath = questao.imagemEspecifica != null
        ? questao.imagemEspecifica!
        : _getImagemParaQuestao(questao);

    return Container(
      height: 300, // AUMENTEI PARA 300PX (era 250)
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300, // AUMENTEI PARA 300PX
            constraints: const BoxConstraints(
              maxHeight: 300, // AUMENTEI CONSTRAINTS
              minHeight: 300,
              maxWidth: 600, // AUMENTEI LARGURA MÁX TAMBÉM
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagemPath,
                height: 300, // AUMENTEI ALTURA DA IMAGEM TAMBÉM
                fit: BoxFit.fitHeight, // SÓ AJUSTA LARGURA
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300, // ALTURA DO ERRO TAMBÉM
                    width: 300,
                    color: Colors.green[50],
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
                                  Colors.orange[600]!,
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

                    // 🎯 IMAGEM DA QUESTÃO - EXATAMENTE COMO A VERSÃO QUE FUNCIONAVA
                    _buildImagemQuestao(),

                    // Container da questão
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.08), // ✅ CORRIGIDO
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enunciado
                          Text(
                            questao.enunciado,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Alternativas
                          ...List.generate(questao.alternativas.length,
                              (index) {
                            final letra = String.fromCharCode(65 + index);
                            final isSelected = _respostaSelecionada == index;

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _selecionarResposta(index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.orange[100]
                                        : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.orange[400]!
                                          : Colors.grey[200]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.orange[400]
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            letra,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          questao.alternativas[index],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isSelected
                                                ? Colors.orange[700]
                                                : Colors.black87,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão Confirmar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _respostaSelecionada != null
                            ? _proximaQuestao
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[500],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _respostaSelecionada != null
                              ? 'Confirmar Resposta'
                              : 'Selecione uma alternativa',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
}
