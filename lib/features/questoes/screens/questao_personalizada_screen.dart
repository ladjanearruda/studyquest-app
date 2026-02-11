// lib/features/questoes/screens/questao_personalizada_screen.dart
// ✅ V7.2.1 - CORRIGIDO: Loop do Game Over
// 📅 Atualizado: 10/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../providers/questao_personalizada_provider.dart';
import '../providers/sessao_usuario_provider.dart';
import '../providers/recursos_provider_v71.dart';
import '../widgets/checkpoint_modal.dart';
import '../widgets/gameover_modal.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../core/models/avatar.dart';

// ✅ V7.2: Imports do sistema de níveis
import '../../niveis/models/nivel_model.dart';
import '../../niveis/providers/nivel_provider.dart';
import '../../niveis/widgets/level_up_modal.dart';

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
  bool _isProcessing = false;

  Avatar? _currentAvatar;
  AvatarEmotion _currentEmotion = AvatarEmotion.neutro;

  // ✅ V7.2: Level up pendente
  Map<String, dynamic>? _pendingLevelUp;

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

  void _initializeSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        ref.read(recursosPersonalizadosProvider.notifier).iniciarSessao();
        await ref.read(sessaoQuestoesProvider.notifier).iniciarSessao();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar questões: $e')),
          );
        }
      }
    });
  }

  void _startTimer() {
    _timer?.cancel(); // Cancela timer anterior se existir
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
    if (!mounted || _showFeedback || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _showFeedback = true;
      _currentEmotion = AvatarEmotion.determinado;
    });

    ref
        .read(sessaoQuestoesProvider.notifier)
        .responderQuestao(-1, isTimeout: true);
    ref
        .read(recursosPersonalizadosProvider.notifier)
        .atualizarRecursos(false, isTimeout: true);

    _showFeedbackAndCheckStatus(false, isTimeout: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ✅ V7.2: Método atualizado com sistema de níveis
  void _selectOption(int index) async {
    if (_showFeedback || _isProcessing) return;

    final sessao = ref.read(sessaoQuestoesProvider);
    final questao = sessao.questaoAtualObj;
    final isCorrect = questao != null && index == questao.respostaCorreta;

    setState(() {
      _isProcessing = true;
      _selectedOption = index;
      _showFeedback = true;
      _currentEmotion =
          isCorrect ? AvatarEmotion.feliz : AvatarEmotion.determinado;
    });

    _timer?.cancel();

    // Registrar resposta
    ref.read(sessaoQuestoesProvider.notifier).responderQuestao(index);
    ref
        .read(recursosPersonalizadosProvider.notifier)
        .atualizarRecursos(isCorrect);

    // ✅ V7.2: ADICIONAR XP AO SISTEMA DE NÍVEIS
    if (isCorrect && questao != null) {
      final acertosConsecutivos = _contarAcertosConsecutivos();
      final resultado =
          await ref.read(nivelProvider.notifier).adicionarXpQuestao(
                acertou: true,
                dificuldade: questao.difficulty,
                streakAtual: acertosConsecutivos,
              );

      // Verificar se subiu de nível
      if (resultado['subiuNivel'] == true) {
        _pendingLevelUp = resultado;
        print(
            '🎉 LEVEL UP PENDENTE: ${resultado['nivelAnterior']} → ${resultado['novoNivel']}');
      }
    }

    _showFeedbackAndCheckStatus(isCorrect);
  }

  // ✅ V7.2: Contar acertos consecutivos para streak
  int _contarAcertosConsecutivos() {
    final sessao = ref.read(sessaoQuestoesProvider);
    int consecutivos = 0;
    for (int i = sessao.acertos.length - 1; i >= 0; i--) {
      if (sessao.acertos[i]) {
        consecutivos++;
      } else {
        break;
      }
    }
    return consecutivos;
  }

  void _showFeedbackAndCheckStatus(bool isCorrect,
      {bool isTimeout = false}) async {
    if (!mounted) return;

    final recursosNotifier = ref.read(recursosPersonalizadosProvider.notifier);

    // ✅ Verificar Game Over PRIMEIRO (prioridade)
    if (recursosNotifier.deveAtivarGameOver) {
      await _handleGameOver();
      return;
    }

    // ✅ Verificar Checkpoint
    if (recursosNotifier.deveAtivarCheckpoint) {
      final continuar = await _handleCheckpoint();
      if (!continuar) {
        if (mounted) {
          context.go('/modo-selection');
        }
        return;
      }
      _reiniciarSessaoAposCheckpoint();
      return;
    }

    _showFeedbackModal(isCorrect, isTimeout: isTimeout);
  }

  Future<bool> _handleCheckpoint() async {
    if (!mounted) return false;

    final recursos = ref.read(recursosPersonalizadosProvider);
    final sessaoUsuario = ref.read(sessaoUsuarioProvider);

    final recursoZerado = recursos['agua']! <= 0 ? 'agua' : 'energia';
    final xpPerdido = sessaoUsuario.xpGanhoSessao;

    final continuar = await showCheckpointModal(
      context: context,
      recursoZerado: recursoZerado,
      xpPerdido: xpPerdido,
      avatar: _currentAvatar,
    );

    if (continuar) {
      ref.read(recursosPersonalizadosProvider.notifier).aplicarCheckpoint();
      ref.read(sessaoUsuarioProvider.notifier).aplicarCheckpoint();
    }

    return continuar;
  }

  // ✅ V7.2.2: CORRIGIDO - Loop do Game Over resolvido
  Future<void> _handleGameOver() async {
    if (!mounted) return;

    final nivelUsuario = ref.read(nivelProvider);
    final xpPerdido = nivelUsuario.xpNoNivel;

    final tentarNovamente = await showGameOverModal(
      context: context,
      nivelAtual: nivelUsuario.nivel,
      xpPerdido: xpPerdido,
      avatar: _currentAvatar,
    );

    // ✅ ORDEM CRÍTICA: Primeiro resetar a sessão do usuário (que guarda a saúde)
    ref.read(sessaoUsuarioProvider.notifier).aplicarGameOver();

    // ✅ Depois resetar recursos (que vai ler a saúde zerada e resetar para 100%)
    ref.read(recursosPersonalizadosProvider.notifier).aplicarGameOver();

    // ✅ Voltar XP ao início do nível
    await ref.read(nivelProvider.notifier).voltarInicioNivel();

    if (!mounted) return;

    if (tentarNovamente) {
      // ✅ Reset da sessão de questões
      ref.read(sessaoQuestoesProvider.notifier).resetSessao();

      // ✅ Delay maior para garantir que SharedPreferences foi atualizado
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        // ✅ Resetar estado da tela
        setState(() {
          _selectedOption = null;
          _showFeedback = false;
          _isProcessing = false;
          _timeLeft = 45;
          _currentEmotion = AvatarEmotion.neutro;
          _pendingLevelUp = null;
        });

        // ✅ CORREÇÃO PRINCIPAL: Não chamar _initializeSession() que recarrega tudo
        // Em vez disso, apenas iniciar nova sessão de questões diretamente
        try {
          // Forçar recursos para 100% novamente (garantia)
          ref.read(recursosPersonalizadosProvider.notifier).aplicarGameOver();

          // Iniciar nova sessão de questões
          await ref.read(sessaoQuestoesProvider.notifier).iniciarSessao();

          // Iniciar timer
          _startTimer();

          print('🔄 Nova sessão iniciada após Game Over');
        } catch (e) {
          print('❌ Erro ao reiniciar após Game Over: $e');
          if (mounted) {
            context.go('/modo-selection');
          }
        }
      }
    } else {
      context.go('/modo-selection');
    }
  }

  void _reiniciarSessaoAposCheckpoint() {
    if (!mounted) return;

    setState(() {
      _selectedOption = null;
      _showFeedback = false;
      _isProcessing = false;
      _timeLeft = 45;
      _currentEmotion = AvatarEmotion.neutro;
    });

    // ✅ V7.3: CHECKPOINT repete as MESMAS questões
    // Não busca novas questões, apenas volta para questão 0
    ref.read(sessaoQuestoesProvider.notifier).voltarParaInicio();

    _startTimer();

    print('🔄 CHECKPOINT: Voltando para questão 1 (mesmas questões)');
  }

  void _showFeedbackModal(bool isCorrect, {bool isTimeout = false}) {
    if (!mounted) return;

    final recursos = ref.read(recursosPersonalizadosProvider);
    final sessao = ref.read(sessaoQuestoesProvider);
    final sessaoUsuario = ref.read(sessaoUsuarioProvider);
    final nivelUsuario = ref.read(nivelProvider);

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
        sessaoUsuario: sessaoUsuario,
        nivelUsuario: nivelUsuario,
        currentAvatar: _currentAvatar,
        currentEmotion: _currentEmotion,
        onContinue: _nextQuestion,
      ),
    );
  }

  // ✅ V7.2: Método atualizado para mostrar modal de level up
  void _nextQuestion() async {
    if (!mounted) return;
    Navigator.of(context).pop();

    // ✅ V7.2: Verificar se há level up pendente
    if (_pendingLevelUp != null && _pendingLevelUp!['subiuNivel'] == true) {
      await showLevelUpModal(
        context: context,
        nivelAnterior: _pendingLevelUp!['nivelAnterior'] as int,
        novoNivel: _pendingLevelUp!['novoNivel'] as int,
        tierAnterior: _pendingLevelUp!['tierAnterior'] as NivelTier,
        novoTier: _pendingLevelUp!['novoTier'] as NivelTier,
        desbloqueios: (_pendingLevelUp!['desbloqueios'] as List<dynamic>?)
                ?.cast<Desbloqueio>() ??
            [],
        mensagem: _pendingLevelUp!['mensagem'] as String? ?? 'Parabéns!',
        avatar: _currentAvatar,
      );
      _pendingLevelUp = null;
    }

    final sessao = ref.read(sessaoQuestoesProvider);

    if (sessao.temProximaQuestao) {
      ref.read(sessaoQuestoesProvider.notifier).proximaQuestao();
      setState(() {
        _selectedOption = null;
        _showFeedback = false;
        _isProcessing = false;
        _timeLeft = 45;
        _currentEmotion = AvatarEmotion.neutro;
      });
      _startTimer();
    } else {
      ref.read(sessaoUsuarioProvider.notifier).finalizarSessao();
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

  // ✅ V7.2: Header atualizado com mini barra de XP
  Widget _buildHeaderPrototipo(OnboardingData onboardingData, dynamic sessao) {
    final avatarDisplay = _getAvatarShortDisplay(onboardingData);
    final nivelUsuario = ref.watch(nivelProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
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

          // Info do usuário com nível
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
                // ✅ V7.2: Mini barra de XP e nível
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      nivelUsuario.tier.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nv.${nivelUsuario.nivel}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        constraints: const BoxConstraints(maxWidth: 60),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: nivelUsuario.progresso,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.orange.shade500
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
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

          // Timer
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
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.transparent;

    if (valor <= 20) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
    } else if (valor <= 40) {
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade300;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 2)
            : null,
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
                  color: valor <= 20 ? Colors.red[700] : cor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(nome, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (valor / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: valor <= 20
                      ? Colors.red
                      : (valor <= 40 ? Colors.orange : cor),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestaoComAvatarProtagonista(
      dynamic questao, OnboardingData onboardingData, dynamic sessao) {
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
                    offset: const Offset(0, 4),
                  ),
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
                            color: Colors.green,
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

  List<Widget> _buildAlternativas(dynamic questao) {
    if (questao?.alternativas == null ||
        questao.alternativas.isEmpty ||
        questao.alternativas.length < 2) {
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
                      'Esta questão está com dados corrompidos',
                      style:
                          TextStyle(fontSize: 12, color: Colors.red.shade600),
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
          onPressed: (_showFeedback || _isProcessing)
              ? null
              : () => _selectOption(index),
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
                  child: Text(opcao, style: const TextStyle(fontSize: 15))),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBarraProgresso(dynamic sessao) {
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
}

// ===== MODAL DE FEEDBACK V7.2 =====
class FeedbackPersonalizadoModal extends StatelessWidget {
  final bool acertou;
  final bool isTimeout;
  final int? selectedOption;
  final dynamic questao;
  final Map<String, double> recursos;
  final dynamic sessao;
  final SessaoUsuarioState sessaoUsuario;
  final NivelUsuario nivelUsuario;
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
    required this.sessaoUsuario,
    required this.nivelUsuario,
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
                offset: const Offset(0, 5),
              ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _buildSubtitle(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getExplicacaoTexto() {
    if (questao?.explicacao?.isNotEmpty == true) {
      return questao!.explicacao;
    }
    final respostaIndex = (questao?.respostaCorreta as num?)?.toInt() ?? 0;
    final letra = String.fromCharCode(65 + respostaIndex);
    final materia = questao?.subject ?? 'a matéria';
    return 'A resposta correta é a alternativa $letra. Revise o conteúdo de $materia para entender melhor este conceito.';
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
          Text(
            _getExplicacaoTexto(),
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
          color: acertou ? Colors.green[200]! : Colors.red[200]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                _getRecursoTexto(),
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
            _getRecursoDescricao(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildRecursoItem(
            Icons.flash_on,
            'Energia',
            recursos['energia']?.toInt() ?? 100,
            Colors.yellow[700]!,
          ),
          const SizedBox(height: 8),
          _buildRecursoItem(
            Icons.water_drop,
            'Água',
            recursos['agua']?.toInt() ?? 100,
            Colors.blue[700]!,
          ),
          const SizedBox(height: 8),
          _buildRecursoItem(
            Icons.favorite,
            'Saúde',
            recursos['saude']?.toInt() ?? 100,
            Colors.red[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildRecursoItem(IconData icon, String nome, int valor, Color cor) {
    final isCritico = valor <= 20;

    return Row(
      children: [
        Icon(icon, size: 16, color: isCritico ? Colors.red : cor),
        const SizedBox(width: 8),
        Text(
          nome,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isCritico ? Colors.red : null,
          ),
        ),
        const Spacer(),
        Text(
          '$valor%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isCritico ? Colors.red : cor,
          ),
        ),
        if (isCritico) ...[
          const SizedBox(width: 4),
          const Icon(Icons.warning, size: 14, color: Colors.red),
        ],
      ],
    );
  }

  Widget _buildProgressoCard() {
    final xpGanho = _calcularXpGanho();

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
          _buildProgressoItem('XP Total', '${nivelUsuario.xpTotal}'),
          const SizedBox(height: 8),
          _buildProgressoItem(
            'Questão',
            '${(sessao?.questaoAtual ?? 0) + 1}/${sessao?.totalQuestoes ?? 10}',
          ),
          const SizedBox(height: 8),
          _buildProgressoItem(
            'Precisão',
            '${(sessaoUsuario.precisaoSessao * 100).toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nível',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  Text(
                    nivelUsuario.tier.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${nivelUsuario.nivel}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward, size: 20),
              SizedBox(width: 8),
              Text(
                'Próxima Questão',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
      return 'Recursos Recuperados!';
    } else if (isTimeout) {
      return 'Energia Perdida!';
    } else {
      return 'Água Perdida!';
    }
  }

  String _getRecursoDescricao() {
    if (acertou) {
      return '+5% Água e Energia';
    } else if (isTimeout) {
      return '-20% Energia (tempo esgotou)';
    } else {
      return '-20% Água (resposta incorreta)';
    }
  }

  int _calcularXpGanho() {
    if (isTimeout || !acertou) return 0;

    final dificuldade = questao?.difficulty ?? 'medio';
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        return GameConstants.XP_FACIL_ACERTO;
      case 'medio':
        return GameConstants.XP_MEDIO_ACERTO;
      case 'dificil':
        return GameConstants.XP_DIFICIL_ACERTO;
      default:
        return GameConstants.XP_MEDIO_ACERTO;
    }
  }
}
