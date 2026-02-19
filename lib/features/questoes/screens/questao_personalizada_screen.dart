// lib/features/questoes/screens/questao_personalizada_screen.dart
// ✅ V8.1 - Sprint 8: Bottom Nav com 3 botões (Sair, Ranking, Perfil)
// 📅 Atualizado: 17/02/2026

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
import '../../home/screens/home_screen.dart'; // ✅ V8.2: Para currentTabProvider
import '../../../core/models/avatar.dart';

// Imports do sistema de níveis
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
    extends ConsumerState<QuestaoPersonalizadaScreen>
    with WidgetsBindingObserver {
  int? _selectedOption;
  Timer? _timer;
  int _timeLeft = 45;
  bool _showFeedback = false;
  bool _isProcessing = false;
  bool _isPaused = false; // ✅ V8.1: Controle de pausa

  Avatar? _currentAvatar;
  AvatarEmotion _currentEmotion = AvatarEmotion.neutro;

  Map<String, dynamic>? _pendingLevelUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ Para detectar quando volta
    _startTimer();
    _initializeSession();
    _loadAvatar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // ✅ V8.1: Detectar quando o app volta ao foco (retorna de outra tela)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPaused) {
      _resumeGame();
    }
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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0 && !_showFeedback && !_isPaused && mounted) {
        setState(() => _timeLeft--);
      } else if (_timeLeft == 0 && !_showFeedback && !_isPaused && mounted) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  // ✅ V8.1: Pausar o jogo
  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
    print('⏸️ Jogo pausado');
  }

  // ✅ V8.1: Retomar o jogo
  void _resumeGame() {
    if (!_showFeedback && !_isProcessing) {
      setState(() {
        _isPaused = false;
      });
      _startTimer();
      print('▶️ Jogo retomado');
    }
  }

  // ✅ V8.2: Abrir modal de Ranking ou Perfil (não sai do jogo)
  void _navigateWithPause(String route) {
    _pauseGame();

    if (route == 'ranking') {
      _showRankingModal();
    } else if (route == 'perfil') {
      _showPerfilModal();
    }
  }

  // ✅ V8.2: Modal de Ranking
  void _showRankingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RankingModalContent(
        onClose: () {
          Navigator.pop(context);
          _resumeGame();
        },
        onViewFull: () {
          Navigator.pop(context);
          ref.read(currentTabProvider.notifier).state = 2;
          context.go('/home');
        },
      ),
    ).whenComplete(() {
      // Se fechou de outra forma (swipe down, tap fora)
      if (mounted && _isPaused) {
        _resumeGame();
      }
    });
  }

  // ✅ V8.2: Modal de Perfil
  void _showPerfilModal() {
    final onboardingData = ref.read(onboardingProvider);
    final nivelUsuario = ref.read(nivelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PerfilModalContent(
        userName: onboardingData.name ?? 'Explorador',
        nivel: nivelUsuario.nivel,
        xpTotal: nivelUsuario.xpTotal,
        tier: nivelUsuario.tier,
        avatar: _currentAvatar,
        onClose: () {
          Navigator.pop(context);
          _resumeGame();
        },
        onViewFull: () {
          Navigator.pop(context);
          ref.read(currentTabProvider.notifier).state = 3;
          context.go('/home');
        },
      ),
    ).whenComplete(() {
      if (mounted && _isPaused) {
        _resumeGame();
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

  void _selectOption(int index) async {
    if (_showFeedback || _isProcessing || _isPaused) return;

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

    ref.read(sessaoQuestoesProvider.notifier).responderQuestao(index);
    ref
        .read(recursosPersonalizadosProvider.notifier)
        .atualizarRecursos(isCorrect);

    if (isCorrect && questao != null) {
      final acertosConsecutivos = _contarAcertosConsecutivos();
      final resultado =
          await ref.read(nivelProvider.notifier).adicionarXpQuestao(
                acertou: true,
                dificuldade: questao.difficulty,
                streakAtual: acertosConsecutivos,
              );

      if (resultado['subiuNivel'] == true) {
        _pendingLevelUp = resultado;
        print(
            '🎉 LEVEL UP PENDENTE: ${resultado['nivelAnterior']} → ${resultado['novoNivel']}');
      }
    }

    _showFeedbackAndCheckStatus(isCorrect);
  }

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

    if (recursosNotifier.deveAtivarGameOver) {
      await _handleGameOver();
      return;
    }

    if (recursosNotifier.deveAtivarCheckpoint) {
      final continuar = await _handleCheckpoint();
      if (!continuar) {
        if (mounted) {
          _goToHome();
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

    ref.read(sessaoUsuarioProvider.notifier).aplicarGameOver();
    ref.read(recursosPersonalizadosProvider.notifier).aplicarGameOver();
    await ref.read(nivelProvider.notifier).voltarInicioNivel();

    if (!mounted) return;

    if (tentarNovamente) {
      ref.read(sessaoQuestoesProvider.notifier).resetSessao();
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _selectedOption = null;
          _showFeedback = false;
          _isProcessing = false;
          _timeLeft = 45;
          _currentEmotion = AvatarEmotion.neutro;
          _pendingLevelUp = null;
          _isPaused = false;
        });

        try {
          ref.read(recursosPersonalizadosProvider.notifier).aplicarGameOver();
          await ref.read(sessaoQuestoesProvider.notifier).iniciarSessao();
          _startTimer();
          print('🔄 Nova sessão iniciada após Game Over');
        } catch (e) {
          print('❌ Erro ao reiniciar após Game Over: $e');
          if (mounted) {
            _goToHome();
          }
        }
      }
    } else {
      _goToHome();
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
      _isPaused = false;
    });

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

  void _nextQuestion() async {
    if (!mounted) return;
    Navigator.of(context).pop();

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

  // ✅ V8.4: Dialog de confirmação para ir ao Início (pausar sessão)
  void _showExitConfirmation() {
    _pauseGame(); // Pausa enquanto mostra o dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.home, color: Colors.green[700], size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Ir para o Início?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sua missão ficará pausada.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Para continuar depois:\nJogar → Continuar Sessão',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _resumeGame(); // Retoma o jogo
            },
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Continuar Jogando'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _goToHome();
            },
            icon: const Icon(Icons.home, size: 18),
            label: const Text('Ir para Início'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ V8.3: Ir para Home na aba Início (NÃO reseta sessão - permite continuar)
  void _goToHome() {
    // NÃO resetar sessão - usuário pode continuar depois na aba Jogar

    // Definir a aba ANTES de navegar
    ref.read(currentTabProvider.notifier).state = 0; // Aba Início

    // Navegar para /home
    context.go('/home');
  }

  Widget _buildExitInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
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
          child: Column(
            children: [
              // ✅ Conteúdo scrollável
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeaderLimpo(onboardingData, sessao),
                      _buildRecursosVitais(recursos),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildQuestaoCard(questao, onboardingData, sessao),
                            const SizedBox(height: 20),
                            ..._buildAlternativas(questao),
                            const SizedBox(height: 20),
                            _buildBarraProgresso(sessao),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ V8.1: Bottom Navigation fixa
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ V8.1: Header LIMPO (sem ícone home)
  Widget _buildHeaderLimpo(OnboardingData onboardingData, dynamic sessao) {
    final nivelUsuario = ref.watch(nivelProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          if (_currentAvatar != null)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(28),
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

          // Info do usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAvatarShortDisplay(onboardingData),
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
                ),
                const SizedBox(height: 4),
                // Mini barra de nível
                Row(
                  children: [
                    Text(nivelUsuario.tier.emoji,
                        style: const TextStyle(fontSize: 12)),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _isPaused
                  ? Colors.grey[200]
                  : (_timeLeft <= 10 ? Colors.red[100] : Colors.orange[100]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPaused ? Icons.pause : Icons.access_time,
                  size: 18,
                  color: _isPaused
                      ? Colors.grey[600]
                      : (_timeLeft <= 10
                          ? Colors.red[700]
                          : Colors.orange[700]),
                ),
                const SizedBox(width: 4),
                Text(
                  _isPaused ? 'Pausado' : '${_timeLeft}s',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isPaused
                        ? Colors.grey[600]
                        : (_timeLeft <= 10
                            ? Colors.red[700]
                            : Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ V8.1: Bottom Navigation com 3 botões
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Início',
                onTap: _showExitConfirmation,
                color: Colors.green.shade600,
              ),
              _buildNavItem(
                icon: Icons.emoji_events,
                label: 'Ranking',
                onTap: () => _navigateWithPause('ranking'),
                color: Colors.amber.shade600,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Perfil',
                onTap: () => _navigateWithPause('perfil'),
                color: Colors.blue.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecursosVitais(Map<String, double> recursos) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildRecursoItem(
              Icons.flash_on,
              'Energia',
              recursos['energia'] ?? 100.0,
              Colors.yellow[700]!,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildRecursoItem(
              Icons.water_drop,
              'Água',
              recursos['agua'] ?? 100.0,
              Colors.blue[700]!,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildRecursoItem(
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

  Widget _buildRecursoItem(
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

  Widget _buildQuestaoCard(
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
          // Avatar na questão
          if (_currentAvatar != null)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade500],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipOval(
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.white,
                  child: Image.asset(
                    _currentAvatar!.getPath(_currentEmotion),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          onboardingData.name?.substring(0, 1).toUpperCase() ??
                              'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade500],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  onboardingData.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),

          // Conteúdo da questão
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
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

                // Título
                Text(
                  'Sobrevivência na Amazônia - Questão ${sessao.questaoAtual + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Enunciado
                Text(
                  questao.enunciado,
                  style: const TextStyle(
                    fontSize: 14,
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
          child: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text('Erro ao carregar alternativas'),
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
          onPressed: (_showFeedback || _isProcessing || _isPaused)
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

// ===== MODAL DE FEEDBACK =====
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
                  errorBuilder: (_, __, ___) => Icon(
                    acertou ? Icons.check_circle : Icons.cancel,
                    color: acertou ? Colors.green : Colors.red,
                    size: 32,
                  ),
                ),
              ),
            )
          else
            Icon(
              isTimeout
                  ? Icons.schedule
                  : (acertou ? Icons.check_circle : Icons.cancel),
              color: Colors.white,
              size: 40,
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

  String _buildSubtitle() {
    final respostaCorreta = questao?.respostaCorreta ?? 0;
    final idx = respostaCorreta is int
        ? respostaCorreta
        : (respostaCorreta as num).toInt();
    final letraCorreta = String.fromCharCode(65 + idx);

    if (isTimeout) return 'O tempo esgotou | Correta: $letraCorreta';

    final suaResposta = selectedOption != null
        ? String.fromCharCode(65 + selectedOption!)
        : 'Nenhuma';
    return 'Sua resposta: $suaResposta | Correta: $letraCorreta';
  }

  Widget _buildExplicacaoCard() {
    String explicacao = questao?.explicacao ?? '';
    if (explicacao.isEmpty) {
      final idx = (questao?.respostaCorreta as num?)?.toInt() ?? 0;
      final letra = String.fromCharCode(65 + idx);
      explicacao = 'A resposta correta é a alternativa $letra.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Explicação',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(explicacao, style: const TextStyle(fontSize: 14, height: 1.5)),
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
                acertou
                    ? 'Recursos Recuperados!'
                    : (isTimeout ? 'Energia Perdida!' : 'Água Perdida!'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: acertou ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecursoRow(Icons.flash_on, 'Energia',
              recursos['energia']?.toInt() ?? 100, Colors.yellow[700]!),
          _buildRecursoRow(Icons.water_drop, 'Água',
              recursos['agua']?.toInt() ?? 100, Colors.blue[700]!),
          _buildRecursoRow(Icons.favorite, 'Saúde',
              recursos['saude']?.toInt() ?? 100, Colors.red[700]!),
        ],
      ),
    );
  }

  Widget _buildRecursoRow(IconData icon, String nome, int valor, Color cor) {
    final critico = valor <= 20;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: critico ? Colors.red : cor),
          const SizedBox(width: 8),
          Text(nome, style: TextStyle(color: critico ? Colors.red : null)),
          const Spacer(),
          Text(
            '$valor%',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: critico ? Colors.red : cor),
          ),
          if (critico) ...[
            const SizedBox(width: 4),
            const Icon(Icons.warning, size: 14, color: Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressoCard() {
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
              Text('Progresso',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.amber[800])),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatRow('XP Total', '${nivelUsuario.xpTotal}'),
          _buildStatRow('Questão',
              '${(sessao?.questaoAtual ?? 0) + 1}/${sessao?.totalQuestoes ?? 10}'),
          _buildStatRow('Precisão',
              '${(sessaoUsuario.precisaoSessao * 100).toStringAsFixed(0)}%'),
          _buildStatRow(
              'Nível', '${nivelUsuario.tier.emoji} ${nivelUsuario.nivel}'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800])),
        ],
      ),
    );
  }

  Widget _buildBotaoContinuar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onContinue,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Próxima Questão',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ),
    );
  }
}

// ===== 🏆 MODAL DE RANKING (V8.2) =====
class _RankingModalContent extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onViewFull;

  const _RankingModalContent({
    required this.onClose,
    required this.onViewFull,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade500],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.emoji_events,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ranking',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Jogo pausado',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Conteúdo do Ranking (Preview)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Top 3 Preview
                  _buildRankingPreviewItem(
                      1, '🥇', 'Lucas Silva', 2500, Colors.amber),
                  _buildRankingPreviewItem(
                      2, '🥈', 'Maria Santos', 2350, Colors.grey.shade400),
                  _buildRankingPreviewItem(
                      3, '🥉', 'Pedro Costa', 2100, Colors.orange.shade300),

                  const SizedBox(height: 16),

                  // Sua posição
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              '#7',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sua posição',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Continue jogando para subir!',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.trending_up, color: Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botões
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewFull,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.amber.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Ver Completo',
                      style: TextStyle(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onClose,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Voltar ao Jogo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
          ),
        ],
      ),
    );
  }

  Widget _buildRankingPreviewItem(
      int position, String medal, String name, int points, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== 👤 MODAL DE PERFIL (V8.2) =====
class _PerfilModalContent extends StatelessWidget {
  final String userName;
  final int nivel;
  final int xpTotal;
  final NivelTier tier;
  final Avatar? avatar;
  final VoidCallback onClose;
  final VoidCallback onViewFull;

  const _PerfilModalContent({
    required this.userName,
    required this.nivel,
    required this.xpTotal,
    required this.tier,
    this.avatar,
    required this.onClose,
    required this.onViewFull,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.teal.shade500],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: avatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            avatar!.getPath(AvatarEmotion.feliz),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'Jogo pausado',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Conteúdo do Perfil (Preview)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Card de Nível
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade100, Colors.orange.shade100],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(tier.emoji,
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nível $nivel',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  tier.nome,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '$xpTotal XP Total',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats rápidos
                  Row(
                    children: [
                      _buildStatCard('🎯', 'Precisão', '85%'),
                      const SizedBox(width: 12),
                      _buildStatCard('🔥', 'Sequência', '3 dias'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botões
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewFull,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.green.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Ver Completo',
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onClose,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Voltar ao Jogo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
