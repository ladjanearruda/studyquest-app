// lib/features/questoes/screens/questao_personalizada_screen.dart
// ✅ V6.9.4 - CORRIGIDO: Validação de alternativas + logs debug

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math'; // ✅ ADICIONADO para min()
import '../providers/questao_personalizada_provider.dart';
import '../models/questao_personalizada.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../core/models/avatar.dart';
import '../../avatar/providers/avatar_provider.dart';

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

  Avatar? _currentAvatar;
  AvatarEmotion _currentEmotion = AvatarEmotion.neutro;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeSession();
    _loadAvatar();
  }

  void _loadAvatar() {
    final onboardingData = ref.read(onboardingProvider);
    if (onboardingData.selectedAvatarType != null &&
        onboardingData.selectedAvatarGender != null) {
      setState(() {
        _currentAvatar = Avatar.fromTypeAndGender(
          onboardingData.selectedAvatarType!,
          onboardingData.selectedAvatarGender!,
        );
      });
    }
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
    setState(() {
      _showFeedback = true;
      _currentEmotion = AvatarEmotion.determinado;
    });
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

    final sessao = ref.read(sessaoQuestoesProvider);
    final questao = sessao.questaoAtualObj;
    final isCorrect = questao != null && index == questao.respostaCorreta;

    setState(() {
      _selectedOption = index;
      _showFeedback = true;
      _currentEmotion =
          isCorrect ? AvatarEmotion.feliz : AvatarEmotion.determinado;
    });

    _timer?.cancel();
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
        currentAvatar: _currentAvatar,
        currentEmotion: _currentEmotion,
        onContinue: _nextQuestion,
      ),
    );
  }

  void _nextQuestion() {
    if (!mounted) return;
    Navigator.of(context).pop();
    final sessao = ref.read(sessaoQuestoesProvider);
    if (sessao.temProximaQuestao) {
      ref.read(sessaoQuestoesProvider.notifier).proximaQuestao();
      setState(() {
        _selectedOption = null;
        _showFeedback = false;
        _timeLeft = 45;
        _currentEmotion = AvatarEmotion.neutro;
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ LOG DE DEBUG DETALHADO
    print('🔍 RENDERIZANDO QUESTÃO ${sessao.questaoAtual + 1}:');
    print('   ID: ${questao.id}');
    print(
        '   Enunciado: ${questao.enunciado.substring(0, min(50, questao.enunciado.length))}...');
    print('   Alternativas: ${questao.alternativas?.length ?? 0}');
    if (questao.alternativas != null && questao.alternativas.isNotEmpty) {
      for (int i = 0; i < questao.alternativas.length; i++) {
        final altText = questao.alternativas[i];
        final preview =
            altText.length > 30 ? altText.substring(0, 30) : altText;
        print('   [$i]: $preview${altText.length > 30 ? "..." : ""}');
      }
    } else {
      print('   ⚠️ ALTERNATIVAS VAZIAS OU NULL!');
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
    final avatarDisplay = _getAvatarShortDisplay(onboardingData);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentAvatar != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    _currentAvatar!.getPath(_currentEmotion),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          onboardingData.name?.substring(0, 1).toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  onboardingData.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
                  avatarDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Questão ${sessao.questaoAtual + 1} de ${sessao.totalQuestoes}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (onboardingData.mainDifficulty != null)
                  Text(
                    'Desafio: ${_formatMateria(onboardingData.mainDifficulty!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
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
                Icon(Icons.access_time,
                    size: 16,
                    color:
                        _timeLeft <= 10 ? Colors.red[700] : Colors.orange[700]),
                const SizedBox(width: 4),
                Text('${_timeLeft}s',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 10
                            ? Colors.red[700]
                            : Colors.orange[700])),
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
              child: _buildRecursoItemPrototipo(Icons.flash_on, 'Energia',
                  recursos['energia'] ?? 100.0, Colors.yellow[700]!)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildRecursoItemPrototipo(Icons.water_drop, 'Água',
                  recursos['agua'] ?? 100.0, Colors.blue[700]!)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildRecursoItemPrototipo(Icons.favorite, 'Saúde',
                  recursos['saude'] ?? 100.0, Colors.red[700]!)),
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: cor),
              const SizedBox(width: 4),
              Text('${valor.toInt()}%',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: cor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(nome, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentAvatar != null)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green.shade300, Colors.green.shade500]),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.white,
                  child: Image.asset(
                    _currentAvatar!.getPath(_currentEmotion),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          onboardingData.name?.substring(0, 1).toUpperCase() ??
                              'U',
                          style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green.shade300, Colors.green.shade500]),
                borderRadius: BorderRadius.circular(60),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  onboardingData.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
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
                      child: Text(questao.subject.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(questao.difficulty.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                    'Sobrevivência na Amazônia - Questão ${sessao.questaoAtual + 1}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800)),
                const SizedBox(height: 16),
                Text(questao.enunciado,
                    style: const TextStyle(
                        fontSize: 15, height: 1.5, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO CORRIGIDO COM VALIDAÇÃO COMPLETA
  List<Widget> _buildAlternativas(questao) {
    // 🛡️ VALIDAÇÃO DE SEGURANÇA
    if (questao?.alternativas == null ||
        questao.alternativas.isEmpty ||
        questao.alternativas.length < 2) {
      print('⚠️ ERRO: Questão sem alternativas válidas!');
      print('   ID: ${questao?.id}');
      print('   Alternativas: ${questao?.alternativas}');

      // Retorna placeholder visual
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade300, width: 2),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Erro ao carregar alternativas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Esta questão está com dados corrompidos no Firebase',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return questao.alternativas.asMap().entries.map<Widget>((entry) {
      final index = entry.key as int;
      final opcao = entry.value as String;
      final letra = String.fromCharCode(65 + index);
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
                  width: isSelected ? 2 : 1),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isSelected ? Colors.green.shade600 : Colors.grey.shade100,
                radius: 16,
                child: Text(letra,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(opcao, style: const TextStyle(fontSize: 15))),
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progresso da Sessão',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600)),
              Text('${sessao.questaoAtual + 1}/${sessao.totalQuestoes}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600)),
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

  String _getAvatarShortDisplay(OnboardingData onboarding) {
    final userName = onboarding.name ?? "Usuário";
    if (onboarding.selectedAvatarType != null &&
        onboarding.selectedAvatarGender != null) {
      final tipo = _getAvatarTipoMinusculo(
          onboarding.selectedAvatarType!, onboarding.selectedAvatarGender!);
      return '$userName, $tipo';
    }
    return userName;
  }

  String _getAvatarTipoMinusculo(AvatarType type, AvatarGender gender) {
    final isFeminino = gender == AvatarGender.feminino;
    switch (type) {
      case AvatarType.academico:
        return isFeminino ? 'a acadêmica' : 'o acadêmico';
      case AvatarType.competitivo:
        return isFeminino ? 'a competitiva' : 'o competitivo';
      case AvatarType.explorador:
        return isFeminino ? 'a exploradora' : 'o explorador';
      case AvatarType.equilibrado:
        return isFeminino ? 'a equilibrada' : 'o equilibrado';
    }
  }

  String _formatMateria(String materia) {
    const materiaMap = {
      'Português e Literatura': 'Português',
      'Matemática': 'Matemática',
      'Física': 'Física',
      'Química': 'Química',
      'Biologia': 'Biologia',
      'História': 'História',
      'Geografia': 'Geografia',
      'Inglês': 'Inglês',
      'Não tenho dificuldade específica em matérias': 'Geral',
    };
    return materiaMap[materia] ?? materia;
  }
}

// ===== MODAL (sem mudanças) =====
class FeedbackPersonalizadoModal extends StatelessWidget {
  final bool acertou;
  final bool isTimeout;
  final int? selectedOption;
  final dynamic questao;
  final Map<String, double> recursos;
  final dynamic sessao;
  final Avatar? currentAvatar;
  final AvatarEmotion currentEmotion;
  final VoidCallback onContinue;

  const FeedbackPersonalizadoModal({
    super.key,
    required this.acertou,
    this.isTimeout = false,
    this.selectedOption,
    this.questao,
    required this.recursos,
    required this.sessao,
    this.currentAvatar,
    this.currentEmotion = AvatarEmotion.neutro,
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
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildExplicacaoCard()),
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
          if (currentAvatar != null)
            ClipOval(
              child: Container(
                width: 60,
                height: 60,
                color: Colors.white,
                child: Image.asset(
                  currentAvatar!.getPath(currentEmotion),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      isTimeout
                          ? Icons.schedule
                          : (acertou ? Icons.check_circle : Icons.cancel),
                      color:
                          acertou ? Colors.green.shade400 : Colors.red.shade400,
                      size: 32,
                    );
                  },
                ),
              ),
            )
          else
            Icon(
              isTimeout
                  ? Icons.schedule
                  : (acertou ? Icons.check_circle : Icons.cancel),
              color: Colors.white,
              size: 32,
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
                      fontWeight: FontWeight.bold),
                ),
                Text(_buildSubtitle(),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Explicação da Questão',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            questao?.explicacao ?? 'Explicação não disponível.',
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursosCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: acertou ? Colors.green[200]! : Colors.red[200]!, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(acertou ? Icons.trending_up : Icons.trending_down,
                  color: acertou ? Colors.green[600] : Colors.red[600],
                  size: 20),
              const SizedBox(width: 8),
              Text(_getRecursoTexto(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: acertou ? Colors.green[700] : Colors.red[700])),
            ],
          ),
          const SizedBox(height: 8),
          Text(_getRecursoDescricao(),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
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
        Text(nome,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text('$valor%',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: cor)),
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
    final xpGanho = acertou ? 15 : (isTimeout ? 0 : 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text('Progresso',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800])),
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
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(valor,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800])),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward, size: 20),
              SizedBox(width: 8),
              Text('Próxima Questão',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    int getRespostaCorretaIndex() {
      final resposta = questao?.respostaCorreta;
      if (resposta == null) return 0;
      if (resposta is int) return resposta;
      if (resposta is num) return resposta.toInt();
      return 0;
    }

    if (isTimeout) {
      final respostaCorretaIndex = getRespostaCorretaIndex();
      return 'O tempo esgotou | Correta: ${String.fromCharCode(65 + respostaCorretaIndex)}';
    }

    final suaResposta = selectedOption != null
        ? String.fromCharCode(65 + selectedOption!)
        : 'Nenhuma';
    final respostaCorretaIndex = getRespostaCorretaIndex();
    final respostaCorreta = String.fromCharCode(65 + respostaCorretaIndex);
    return 'Sua resposta: $suaResposta | Correta: $respostaCorreta';
  }

  String _getRecursoTexto() {
    if (acertou) {
      bool todosRecursosEm100 = (recursos['energia'] ?? 0) >= 100 &&
          (recursos['agua'] ?? 0) >= 100 &&
          (recursos['saude'] ?? 0) >= 100;
      if (todosRecursosEm100) {
        return 'Recursos Mantidos!';
      } else {
        return 'Recursos Recuperados!';
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
