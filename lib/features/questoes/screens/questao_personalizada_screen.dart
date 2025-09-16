// lib/features/questoes/screens/questao_personalizada_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../providers/questao_personalizada_provider.dart';
import '../models/questao_personalizada.dart';
import '../../onboarding/screens/onboarding_screen.dart';

class QuestaoPersonalizadaScreen extends ConsumerStatefulWidget {
  const QuestaoPersonalizadaScreen({super.key});

  @override
  ConsumerState<QuestaoPersonalizadaScreen> createState() =>
      _QuestaoPersonalizadaScreenState();
}

class _QuestaoPersonalizadaScreenState
    extends ConsumerState<QuestaoPersonalizadaScreen> {
  int? _selectedOption;
  Timer? _timer;
  int _timeLeft = 45;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeSession();
  }

  void _initializeSession() async {
    try {
      await ref.read(sessaoQuestoesProvider.notifier).iniciarSessao();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar questões: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && !_showFeedback && mounted) {
        setState(() => _timeLeft--);
      } else if (_timeLeft == 0 && !_showFeedback && mounted) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (!mounted || _showFeedback) return;

    setState(() => _showFeedback = true);
    ref.read(sessaoQuestoesProvider.notifier).responderQuestao(-1);
    ref.read(recursosPersonalizadosProvider.notifier).atualizarRecursos(false);

    _showFeedbackModal(false, isTimeout: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_showFeedback) return;

    setState(() {
      _selectedOption = index;
      _showFeedback = true;
    });

    _timer?.cancel();

    final sessao = ref.read(sessaoQuestoesProvider);
    final questao = sessao.questaoAtualObj;
    final isCorrect = questao != null && index == questao.respostaCorreta;

    ref.read(sessaoQuestoesProvider.notifier).responderQuestao(index);
    ref
        .read(recursosPersonalizadosProvider.notifier)
        .atualizarRecursos(isCorrect);

    _showFeedbackModal(isCorrect);
  }

  void _showFeedbackModal(bool isCorrect, {bool isTimeout = false}) {
    if (!mounted) return;

    final recursos = ref.read(recursosPersonalizadosProvider);
    final sessao = ref.read(sessaoQuestoesProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FeedbackPersonalizadoModal(
        acertou: isCorrect,
        isTimeout: isTimeout,
        selectedOption: _selectedOption,
        questao: sessao.questaoAtualObj,
        recursos: recursos,
        sessao: sessao,
        onContinue: _nextQuestion,
      ),
    );
  }

  void _nextQuestion() {
    print('🔍 _nextQuestion chamado');

    if (!mounted) return;

    Navigator.of(context).pop();

    final sessao = ref.read(sessaoQuestoesProvider);
    print(
        '📊 Questão atual: ${sessao.questaoAtual + 1}/${sessao.totalQuestoes}');

    if (sessao.temProximaQuestao) {
      print('➡️ Avançando para próxima questão...');

      ref.read(sessaoQuestoesProvider.notifier).proximaQuestao();

      setState(() {
        _selectedOption = null;
        _showFeedback = false;
        _timeLeft = 45;
      });

      _startTimer();
    } else {
      context.go('/questoes-resultado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessao = ref.watch(sessaoQuestoesProvider);
    final recursos = ref.watch(recursosPersonalizadosProvider);
    final onboardingData = ref.watch(onboardingProvider);

    final questao = sessao.questaoAtualObj;

    if (questao == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!ref.read(recursosPersonalizadosProvider.notifier).estaVivo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/questoes-gameover');
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderPrototipo(onboardingData, sessao),
                _buildRecursosVitaisPrototipo(recursos),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildQuestaoComAvatarProtagonista(
                          questao, onboardingData, sessao),
                      const SizedBox(height: 20),
                      ..._buildAlternativas(questao),
                      const SizedBox(height: 20),
                      _buildBarraProgresso(sessao),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPrototipo(
      OnboardingData onboardingData, SessaoQuestoes sessao) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                onboardingData.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${onboardingData.name ?? "Usuário"}, Exploradora',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Questão ${sessao.questaoAtual + 1} de ${sessao.totalQuestoes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _timeLeft <= 10 ? Colors.red[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: _timeLeft <= 10 ? Colors.red[700] : Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Text(
                  '${_timeLeft}s',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        _timeLeft <= 10 ? Colors.red[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursosVitaisPrototipo(Map<String, double> recursos) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildRecursoItemPrototipo(
              Icons.flash_on,
              'Energia',
              recursos['energia'] ?? 100.0,
              Colors.yellow[700]!,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildRecursoItemPrototipo(
              Icons.water_drop,
              'Água',
              recursos['agua'] ?? 100.0,
              Colors.blue[700]!,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildRecursoItemPrototipo(
              Icons.favorite,
              'Saúde',
              recursos['saude'] ?? 100.0,
              Colors.red[700]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursoItemPrototipo(
      IconData icon, String nome, double valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: cor),
              const SizedBox(width: 4),
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
          Text(
            nome,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestaoComAvatarProtagonista(
      questao, OnboardingData onboardingData, SessaoQuestoes sessao) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                onboardingData.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        questao.subject.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        questao.difficulty.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sobrevivência na Amazônia - Questão ${sessao.questaoAtual + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  questao.enunciado,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlternativas(questao) {
    return questao.alternativas.asMap().entries.map<Widget>((entry) {
      final index = entry.key;
      final opcao = entry.value;
      final letra = String.fromCharCode(65 + index as int);
      final isSelected = _selectedOption == index;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ElevatedButton(
          onPressed: _showFeedback ? null : () => _selectOption(index),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: isSelected ? Colors.green.shade100 : Colors.white,
            foregroundColor:
                isSelected ? Colors.green.shade800 : Colors.black87,
            elevation: isSelected ? 6 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    isSelected ? Colors.green.shade400 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isSelected ? Colors.green.shade600 : Colors.grey.shade100,
                radius: 16,
                child: Text(
                  letra,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opcao,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBarraProgresso(SessaoQuestoes sessao) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso da Sessão',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${sessao.questaoAtual + 1}/${sessao.totalQuestoes}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (sessao.questaoAtual + 1) / sessao.totalQuestoes,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade500),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

/// Modal de feedback corrigido com lógica dos protótipos
class FeedbackPersonalizadoModal extends StatelessWidget {
  final bool acertou;
  final bool isTimeout;
  final int? selectedOption;
  final dynamic questao;
  final Map<String, double> recursos;
  final dynamic sessao;
  final VoidCallback onContinue;

  const FeedbackPersonalizadoModal({
    super.key,
    required this.acertou,
    this.isTimeout = false,
    this.selectedOption,
    this.questao,
    required this.recursos,
    required this.sessao,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildExplicacaoCard(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildRecursosCard(),
                            const SizedBox(height: 16),
                            _buildProgressoCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBotaoContinuar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: acertou ? Colors.green.shade400 : Colors.red.shade400,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTimeout
                ? Icons.schedule
                : (acertou ? Icons.check_circle : Icons.cancel),
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTimeout
                      ? 'Tempo Esgotado!'
                      : (acertou ? 'Excelente!' : 'Quase lá!'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _buildSubtitle(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplicacaoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: Colors.amber[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Explicação da Questão',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                questao?.explicacao ??
                    'Para calcular a área de um retângulo, multiplicamos comprimento × largura: 150m × 80m = 12.000 m². Portanto, serão necessárias 12.000 mudas para o reflorestamento.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAvatarProfessor(),
        ],
      ),
    );
  }

  Widget _buildAvatarProfessor() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              isTimeout
                  ? '"Não desista! O tempo é um desafio, mas você pode superar!"'
                  : (acertou
                      ? '"Excelente raciocínio! Continue assim!"'
                      : '"Não desista! Cada erro é uma oportunidade de aprender."'),
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecursosCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: acertou ? Colors.green[200]! : Colors.red[200]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                acertou ? Icons.trending_up : Icons.trending_down,
                color: acertou ? Colors.green[600] : Colors.red[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getRecursoTexto(), // USAR MÉTODO DINÂMICO
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: acertou ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getRecursoDescricao(), // DESCRIÇÃO DINÂMICA
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildRecursoItem(Icons.flash_on, 'Energia',
              recursos['energia']?.toInt() ?? 100, Colors.yellow[700]!),
          const SizedBox(height: 8),
          _buildRecursoItem(Icons.water_drop, 'Água',
              recursos['agua']?.toInt() ?? 100, Colors.blue[700]!),
          const SizedBox(height: 8),
          _buildRecursoItem(Icons.favorite, 'Saúde',
              recursos['saude']?.toInt() ?? 100, Colors.red[700]!),
        ],
      ),
    );
  }

  Widget _buildRecursoItem(IconData icon, String nome, int valor, Color cor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cor),
        const SizedBox(width: 8),
        Text(
          nome,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          '$valor%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressoCard() {
    final questaoAtual = (sessao?.questaoAtual ?? 0) + 1;
    final totalQuestoes = sessao?.totalQuestoes ?? 10;
    final acertos =
        sessao?.acertos?.where((acerto) => acerto == true).length ?? 0;
    final totalRespondidas = sessao?.acertos?.length ?? 1;
    final precisao =
        totalRespondidas > 0 ? ((acertos / totalRespondidas) * 100).round() : 0;
    final xpGanho = this.acertou ? 15 : (isTimeout ? 0 : 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Progresso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressoItem('XP Ganho', '+$xpGanho'),
          const SizedBox(height: 8),
          _buildProgressoItem('Questão', '$questaoAtual/$totalQuestoes'),
          const SizedBox(height: 8),
          _buildProgressoItem('Precisão', '$precisao%'),
        ],
      ),
    );
  }

  Widget _buildProgressoItem(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.amber[800],
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoContinuar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward, size: 20),
              SizedBox(width: 8),
              Text(
                'Próxima Questão',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    if (isTimeout) {
      return 'O tempo esgotou | Correta: ${String.fromCharCode(65 + (questao?.respostaCorreta as int? ?? 0))}';
    }

    final suaResposta = selectedOption != null
        ? String.fromCharCode(65 + selectedOption!)
        : 'Nenhuma';
    final respostaCorreta =
        String.fromCharCode(65 + (questao?.respostaCorreta as int? ?? 0));

    return 'Sua resposta: $suaResposta | Correta: $respostaCorreta';
  }

  // MÉTODOS DOS RECURSOS CORRIGIDOS - IGUAL AOS PROTÓTIPOS
  String _getRecursoTexto() {
    if (acertou) {
      // Verificar se todos recursos estão em 100%
      bool todosRecursosEm100 = (recursos['energia'] ?? 0) >= 100 &&
          (recursos['agua'] ?? 0) >= 100 &&
          (recursos['saude'] ?? 0) >= 100;

      if (todosRecursosEm100) {
        return 'Recursos Mantidos!'; // CORRETO: quando já está 100%
      } else {
        return 'Recursos Recuperados!'; // CORRETO: quando precisa recuperar
      }
    } else {
      return 'Recursos Perdidos!';
    }
  }

  String _getRecursoDescricao() {
    if (acertou) {
      bool todosRecursosEm100 = (recursos['energia'] ?? 0) >= 100 &&
          (recursos['agua'] ?? 0) >= 100 &&
          (recursos['saude'] ?? 0) >= 100;

      if (todosRecursosEm100) {
        return 'Você está em ótima forma! Continue assim.';
      } else {
        return '+5% em todos os recursos vitais';
      }
    } else {
      return '-10% em todos os recursos vitais';
    }
  }
}
