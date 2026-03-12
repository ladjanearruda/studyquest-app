// lib/features/questoes/screens/questao_personalizada_screen.dart
// ✅ V9.4 - Sprint 9 Fase 3: Revanche TODOS os erros + Anotação 1:1 + Badge Transformador
// 📅 Atualizado: 27/02/2026
// 🎯 Mudanças:
//    - Revanche aparece para TODOS os erros (anotados ou não)
//    - Modal de feedback mostra anotação existente
//    - Badge Transformador dispara automaticamente
//    - Anotação 1:1 (editar se existe)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../providers/questao_personalizada_provider.dart';
import '../providers/sessao_usuario_provider.dart';
import '../providers/recursos_provider_v71.dart';
import '../widgets/checkpoint_modal.dart';
import '../widgets/gameover_modal.dart';
import '../widgets/revanche_header.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/models/avatar.dart';

// Imports do sistema de níveis
import '../../niveis/models/nivel_model.dart';
import '../../niveis/providers/nivel_provider.dart';
import '../../niveis/widgets/level_up_modal.dart';

// ✅ V9.4: Imports do Diário, Badges e Firebase
import '../../diario/widgets/anotar_erro_modal.dart';
import '../../diario/providers/diary_provider.dart';
import '../../diario/providers/diary_badges_provider.dart';
import '../../diario/widgets/badge_unlock_modal.dart';
import '../../diario/models/diary_entry_model.dart';
import '../../../core/services/firebase_diary_service.dart';
import '../../../core/services/firebase_rest_auth.dart';

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
  bool _isPaused = false;

  Avatar? _currentAvatar;
  AvatarEmotion _currentEmotion = AvatarEmotion.neutro;

  Map<String, dynamic>? _pendingLevelUp;

  // ✅ V9.4: Variáveis para Revanche expandida
  bool _isRevanche = false;
  bool _temAnotacao =
      false; // ✅ V9.4: Se tem anotação (para badge Transformador)
  DiaryEntry?
      _anotacaoExistente; // ✅ V9.4: Anotação existente (para mostrar no modal)
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // NÃO iniciar timer aqui — sessão ainda não foi carregada
    // Timer será iniciado ao final de _initializeSession()
    _initializeSession();
    _loadAvatar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pauseGame();
    } else if (state == AppLifecycleState.resumed && _isPaused) {
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

  // ✅ V9.4: Inicialização com userId e carregamento do diário
  void _initializeSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        // Carregar userId do auth
        final user = await FirebaseRestAuth.getCurrentUser();
        if (user != null) {
          _currentUserId = user.uid;
          print('👤 Usuário carregado: ${user.uid}');
        }

        // ── VERIFICAR SE HÁ SESSÃO PAUSADA ──────────────────────────────
        final sessaoAtual = ref.read(sessaoQuestoesProvider);
        if (sessaoAtual.isAtiva) {
          // Sessão pausada: restaurar tempo e continuar de onde parou
          print('▶️ Retomando sessão pausada: '
              'questão ${sessaoAtual.questaoAtual + 1}/${sessaoAtual.totalQuestoes}, '
              'tempo: ${sessaoAtual.timeLeft}s');

          if (mounted) {
            setState(() => _timeLeft = sessaoAtual.timeLeft);
            await ref.read(diaryProvider.notifier).ensureInitialized();
            await _checkIfRevanche();
            _startTimer();
          }
          return; // Não iniciar nova sessão
        }

        // ── NOVA SESSÃO ──────────────────────────────────────────────────
        // Verificar se havia sessão ativa antes do F5
        // Se sim: recursos já foram carregados do SharedPreferences → não resetar
        // Se não: sessão genuinamente nova → resetar água/energia para 100%
        final prefs = await SharedPreferences.getInstance();
        final sessaoEmProgresso = prefs.getBool(kSessaoAtiva) ?? false;
        print('🔍 [initSession] sessaoEmProgresso=$sessaoEmProgresso');
        if (!sessaoEmProgresso) {
          ref.read(recursosPersonalizadosProvider.notifier).iniciarSessao();
          print('🔄 [initSession] Recursos resetados (sessão nova)');
        } else {
          print('▶️ [initSession] Recursos mantidos (retomando após F5)');
        }
        await ref.read(sessaoQuestoesProvider.notifier).iniciarSessao();

        // ✅ V9.4: Garantir que diário está inicializado
        await ref.read(diaryProvider.notifier).ensureInitialized();

        // ✅ V9.4: Verificar se a primeira questão é revanche
        await _checkIfRevanche();

        // Iniciar timer APÓS sessão carregada (evita mostrar questão errada)
        if (mounted) _startTimer();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar questões: $e')),
          );
        }
      }
    });
  }

  // ✅ V9.4: Verificar se questão atual é revanche (TODOS os erros)
  Future<void> _checkIfRevanche() async {
    final sessao = ref.read(sessaoQuestoesProvider);
    final questao = sessao.questaoAtualObj;

    if (questao != null) {
      final diaryNotifier = ref.read(diaryProvider.notifier);

      // ✅ V9.4: Verificar se é revanche (errou antes - com ou sem anotação)
      final isRevanche = diaryNotifier.isRevanche(questao.id);

      // ✅ V9.4: Verificar se tem anotação (para badge Transformador)
      final temAnotacao = diaryNotifier.temAnotacao(questao.id);

      // ✅ V9.4: Obter anotação existente (para mostrar no modal)
      final anotacao = diaryNotifier.getAnnotationForQuestion(questao.id);

      if (mounted) {
        setState(() {
          _isRevanche = isRevanche;
          _temAnotacao = temAnotacao;
          _anotacaoExistente = anotacao;
        });

        if (isRevanche) {
          print('🔄 REVANCHE detectada: ${questao.id}');
          print('   Tem anotação: $temAnotacao');
        }
      }
    }
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

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
    print('⏸️ Jogo pausado');
  }

  void _resumeGame() {
    if (!_showFeedback && !_isProcessing) {
      setState(() {
        _isPaused = false;
      });
      _startTimer();
      print('▶️ Jogo retomado');
    }
  }

  void _navigateWithPause(String route) {
    _pauseGame();

    if (route == 'ranking') {
      _showRankingModal();
    } else if (route == 'perfil') {
      _showPerfilModal();
    }
  }

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
          _timer?.cancel();
          ref.read(sessaoQuestoesProvider.notifier).salvarTimeLeft(_timeLeft);
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
          _timer?.cancel();
          ref.read(sessaoQuestoesProvider.notifier).salvarTimeLeft(_timeLeft);
          ref.read(currentTabProvider.notifier).state = 4;
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

    final sessao = ref.read(sessaoQuestoesProvider);
    final questao = sessao.questaoAtualObj;

    setState(() {
      _isProcessing = true;
      _showFeedback = true;
      _currentEmotion = AvatarEmotion.determinado;
    });

    // ✅ V9.4: Salvar timeout no Firebase E registrar erro
    if (_currentUserId != null && questao != null) {
      FirebaseDiaryService.saveUserResponse(
        userId: _currentUserId!,
        questionId: questao.id,
        wasCorrect: false,
        selectedAnswer: -1,
        timeSpent: 45,
        subject: questao.subject,
        difficulty: questao.difficulty,
      );

      // ✅ V9.4: Registrar erro no diary provider (para revanche futura)
      ref.read(diaryProvider.notifier).registrarErro(questao.id);
    }

    ref
        .read(sessaoQuestoesProvider.notifier)
        .responderQuestao(-1, isTimeout: true);
    ref
        .read(recursosPersonalizadosProvider.notifier)
        .atualizarRecursos(false, isTimeout: true);

    _showFeedbackAndCheckStatus(false, isTimeout: true);
  }

  // ✅ V9.4: _selectOption com salvamento Firebase, registro de erro e transformação
  void _selectOption(int index) async {
    if (_showFeedback || _isProcessing || _isPaused) return;

    final sessao = ref.read(sessaoQuestoesProvider);
    final questao = sessao.questaoAtualObj;
    final isCorrect = questao != null && index == questao.respostaCorreta;
    final timeSpent = 45 - _timeLeft;

    setState(() {
      _isProcessing = true;
      _selectedOption = index;
      _showFeedback = true;
      _currentEmotion =
          isCorrect ? AvatarEmotion.feliz : AvatarEmotion.determinado;
    });

    _timer?.cancel();

    // Salvar resposta no Firebase
    if (_currentUserId != null && questao != null) {
      FirebaseDiaryService.saveUserResponse(
        userId: _currentUserId!,
        questionId: questao.id,
        wasCorrect: isCorrect,
        selectedAnswer: index,
        timeSpent: timeSpent,
        subject: questao.subject,
        difficulty: questao.difficulty,
      );
      print('💾 Resposta salva: ${questao.id} (${isCorrect ? "✓" : "✗"})');

      // ✅ V9.4: Se ERROU, registrar erro (para revanche futura)
      if (!isCorrect) {
        ref.read(diaryProvider.notifier).registrarErro(questao.id);
      }
    }

    ref.read(sessaoQuestoesProvider.notifier).responderQuestao(index);
    ref
        .read(recursosPersonalizadosProvider.notifier)
        .atualizarRecursos(isCorrect);

    // ✅ V9.4: Verificar se é transformação de erro (revanche COM ANOTAÇÃO acertada!)
    if (isCorrect && _isRevanche && _temAnotacao && questao != null) {
      final diaryNotifier = ref.read(diaryProvider.notifier);
      final xpBonus = await diaryNotifier.transformarErro(questao.id);

      if (xpBonus > 0 && mounted) {
        print('🏆 ERRO TRANSFORMADO! +$xpBonus XP');

        // Adicionar XP bônus ao nível
        await ref.read(nivelProvider.notifier).adicionarXp(xpBonus);

        // ✅ V9.4: Verificar badges de transformação
        ref.read(diaryBadgesProvider.notifier).checkBadges();
      }
    }

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
          _isRevanche = false;
          _temAnotacao = false;
          _anotacaoExistente = null;
        });

        try {
          ref.read(recursosPersonalizadosProvider.notifier).aplicarGameOver();
          await ref.read(sessaoQuestoesProvider.notifier).iniciarSessao();
          await _checkIfRevanche();
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
      _isRevanche = false;
      _temAnotacao = false;
      _anotacaoExistente = null;
    });

    ref.read(sessaoQuestoesProvider.notifier).voltarParaInicio();
    _checkIfRevanche();
    _startTimer();
    print('🔄 CHECKPOINT: Voltando para questão 1 (mesmas questões)');
  }

  // ✅ V9.4: Modal de feedback com anotação existente
  void _showFeedbackModal(bool isCorrect, {bool isTimeout = false}) {
    if (!mounted) return;

    final recursos = ref.read(recursosPersonalizadosProvider);
    final sessao = ref.read(sessaoQuestoesProvider);
    final sessaoUsuario = ref.read(sessaoUsuarioProvider);
    final nivelUsuario = ref.read(nivelProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _FeedbackPersonalizadoModalV94(
        acertou: isCorrect,
        isTimeout: isTimeout,
        isRevanche: _isRevanche,
        temAnotacao: _temAnotacao,
        anotacaoExistente: _anotacaoExistente, // ✅ V9.4: Passar anotação
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

      // ✅ V9.4: Verificar se próxima questão é revanche
      await _checkIfRevanche();

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
      if (mounted) context.go('/questoes-resultado');
    }
  }

  void _showExitConfirmation() {
    _pauseGame();

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
            Text('Sua missão ficará pausada.',
                style: TextStyle(fontSize: 15, color: Colors.grey[800])),
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
                          fontSize: 13, color: Colors.blue[700], height: 1.4),
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
              _resumeGame();
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

  void _goToHome() {
    _timer?.cancel();
    // Salvar tempo restante para restaurar ao voltar
    ref.read(sessaoQuestoesProvider.notifier).salvarTimeLeft(_timeLeft);
    ref.read(currentTabProvider.notifier).state = 0;
    context.go('/home');
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
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderLimpo(OnboardingData onboardingData, dynamic sessao) {
    final nivelUsuario = ref.watch(nivelProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentAvatar != null)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
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
                            fontWeight: FontWeight.bold),
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
                    colors: [Colors.green.shade400, Colors.green.shade600]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  onboardingData.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAvatarShortDisplay(onboardingData),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Questão ${sessao.questaoAtual + 1} de ${sessao.totalQuestoes}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(nivelUsuario.tier.emoji,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text('Nv.${nivelUsuario.nivel}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700])),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        constraints: const BoxConstraints(maxWidth: 60),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: nivelUsuario.progresso,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade500
                              ]),
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

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2))
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
                  color: Colors.green.shade600),
              _buildNavItem(
                  icon: Icons.emoji_events,
                  label: 'Ranking',
                  onTap: () => _navigateWithPause('ranking'),
                  color: Colors.amber.shade600),
              _buildNavItem(
                  icon: Icons.person,
                  label: 'Perfil',
                  onTap: () => _navigateWithPause('perfil'),
                  color: Colors.blue.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color color}) {
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
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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
              child: _buildRecursoItem(Icons.flash_on, 'Energia',
                  recursos['energia'] ?? 100.0, Colors.yellow[700]!)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildRecursoItem(Icons.water_drop, 'Água',
                  recursos['agua'] ?? 100.0, Colors.blue[700]!)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildRecursoItem(Icons.favorite, 'Saúde',
                  recursos['saude'] ?? 100.0, Colors.red[700]!)),
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
              offset: const Offset(0, 2))
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: valor <= 20 ? Colors.red[700] : cor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(nome, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2)),
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

  // ✅ V9.4: Card de questão com visual de revanche
  Widget _buildQuestaoCard(
      dynamic questao, OnboardingData onboardingData, dynamic sessao) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // ✅ V9.4: Borda dourada se revanche (com ou sem anotação)
        border: _isRevanche
            ? Border.all(color: Colors.amber.shade400, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: _isRevanche
                ? Colors.amber.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: _isRevanche ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ V9.4: Header de revanche (mostra XP bônus só se tem anotação)
          if (_isRevanche) RevancheHeader(xpBonus: _temAnotacao ? 15 : 0, temAnotacao: _temAnotacao),

          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentAvatar != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _isRevanche
                            ? Colors.amber.shade300
                            : Colors.green.shade300,
                        _isRevanche
                            ? Colors.orange.shade400
                            : Colors.green.shade500
                      ]),
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
                                onboardingData.name
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade600),
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
                      gradient: LinearGradient(colors: [
                        Colors.green.shade300,
                        Colors.green.shade500
                      ]),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        onboardingData.name?.substring(0, 1).toUpperCase() ??
                            'U',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
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
                                borderRadius: BorderRadius.circular(12)),
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
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(questao.difficulty.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800)),
                          ),
                          // ✅ V9.4: Badge "Tem anotação" se tiver
                          if (_temAnotacao) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('📝', style: TextStyle(fontSize: 10)),
                                  SizedBox(width: 2),
                                  Text('Anotado',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                          'Sobrevivência na Amazônia - Questão ${sessao.questaoAtual + 1}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800)),
                      const SizedBox(height: 12),
                      Text(questao.enunciado,
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87)),
                    ],
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
              Text('Erro ao carregar alternativas')
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
              offset: const Offset(0, 2))
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
}

// ===== MODAL DE FEEDBACK V9.4 - COM ANOTAÇÃO EXISTENTE =====
class _FeedbackPersonalizadoModalV94 extends ConsumerStatefulWidget {
  final bool acertou;
  final bool isTimeout;
  final bool isRevanche;
  final bool temAnotacao;
  final DiaryEntry? anotacaoExistente;
  final int? selectedOption;
  final dynamic questao;
  final Map<String, double> recursos;
  final dynamic sessao;
  final SessaoUsuarioState sessaoUsuario;
  final NivelUsuario nivelUsuario;
  final Avatar? currentAvatar;
  final AvatarEmotion currentEmotion;
  final VoidCallback onContinue;

  const _FeedbackPersonalizadoModalV94({
    required this.acertou,
    this.isTimeout = false,
    this.isRevanche = false,
    this.temAnotacao = false,
    this.anotacaoExistente,
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
  ConsumerState<_FeedbackPersonalizadoModalV94> createState() =>
      _FeedbackPersonalizadoModalV94State();
}

class _FeedbackPersonalizadoModalV94State
    extends ConsumerState<_FeedbackPersonalizadoModalV94> {
  bool _annotationSaved = false;
  bool _showingBadge = false;

  @override
  void initState() {
    super.initState();
    // Verificar badges pendentes do momento de revanche (Transformador)
    if (widget.acertou && widget.isRevanche && widget.temAnotacao) {
      _showNextPendingBadge();
    }
  }

  /// Mostra o próximo badge pendente se houver, aguardando qualquer modal fechar.
  Future<void> _showNextPendingBadge() async {
    // Aguarda 1 frame para garantir que modais anteriores fecharam
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _showingBadge) return;

    final notifier = ref.read(diaryBadgesProvider.notifier);
    final badge = notifier.getNextPendingBadge();
    if (badge == null) return;

    setState(() => _showingBadge = true);
    await BadgeUnlockModal.show(context: context, badge: badge);
    notifier.removePendingBadge(badge.id);
    if (mounted) {
      setState(() => _showingBadge = false);
      // Verificar se há mais
      _showNextPendingBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta badges novas em tempo real (cobre anotação nova E revanche)
    ref.listen<DiaryBadgesState>(diaryBadgesProvider, (previous, next) {
      final hadPending = previous?.pendingUnlock.isNotEmpty ?? false;
      final hasPending = next.pendingUnlock.isNotEmpty;
      if (!hadPending && hasPending && !_showingBadge) {
        _showNextPendingBadge();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ V9.4: Card de ERRO TRANSFORMADO
                      if (widget.acertou &&
                          widget.isRevanche &&
                          widget.temAnotacao)
                        _buildErroTransformadoCard(),

                      // ✅ V9.4: Mostrar anotação existente na revanche
                      if (widget.isRevanche && widget.anotacaoExistente != null)
                        _buildAnotacaoExistenteCard(),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _buildExplicacaoCard()),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: _buildRecursosCard()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: !widget.acertou
                                ? _buildAnotarCard()
                                : _buildProgressoCard(),
                          ),
                          if (!widget.acertou) ...[
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: _buildProgressoCard()),
                          ],
                        ],
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
    final isTransformacao =
        widget.acertou && widget.isRevanche && widget.temAnotacao;

    Color headerColor;
    String titulo;
    String subtitulo;
    IconData icone;

    if (isTransformacao) {
      headerColor = Colors.amber.shade500;
      titulo = '🏆 ERRO TRANSFORMADO!';
      subtitulo = 'Você venceu a revanche!';
      icone = Icons.emoji_events;
    } else if (widget.isRevanche && widget.acertou) {
      headerColor = Colors.orange.shade400;
      titulo = '🔄 Revanche Vencida!';
      subtitulo = 'Você acertou dessa vez!';
      icone = Icons.refresh;
    } else if (widget.acertou) {
      headerColor = Colors.green.shade400;
      titulo = 'Excelente!';
      subtitulo = _buildSubtitle();
      icone = Icons.check_circle;
    } else if (widget.isTimeout) {
      headerColor = Colors.orange.shade400;
      titulo = 'Tempo Esgotado!';
      subtitulo = _buildSubtitle();
      icone = Icons.schedule;
    } else {
      headerColor = Colors.red.shade400;
      titulo = widget.isRevanche ? '🔄 Errou de novo...' : 'Quase lá!';
      subtitulo = _buildSubtitle();
      icone = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (widget.currentAvatar != null)
            ClipOval(
              child: Container(
                width: 60,
                height: 60,
                color: Colors.white,
                child: Image.asset(
                  widget.currentAvatar!.getPath(widget.currentEmotion),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    icone,
                    color: headerColor,
                    size: 32,
                  ),
                ),
              ),
            )
          else
            Icon(icone, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitulo,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          if (isTransformacao)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '+15 XP',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final respostaCorreta = widget.questao?.respostaCorreta ?? 0;
    final idx = respostaCorreta is int
        ? respostaCorreta
        : (respostaCorreta as num).toInt();
    final letraCorreta = String.fromCharCode(65 + idx);

    if (widget.isTimeout) return 'O tempo esgotou | Correta: $letraCorreta';

    final suaResposta = widget.selectedOption != null
        ? String.fromCharCode(65 + widget.selectedOption!)
        : 'Nenhuma';
    return 'Sua resposta: $suaResposta | Correta: $letraCorreta';
  }

  Widget _buildErroTransformadoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          const Text(
            'Lição Dominada!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Você transformou seu erro em aprendizado',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Movida para Hall da Fama!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnotacaoExistenteCard() {
    final anotacao = widget.anotacaoExistente!;
    final isErro = !widget.acertou;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isErro ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isErro ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isErro ? '📝' : '✅', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isErro
                      ? 'Sua anotação anterior:'
                      : 'Sua anotação (dominada!):',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isErro ? Colors.orange.shade800 : Colors.green.shade800,
                  ),
                ),
              ),
              if (isErro)
                TextButton.icon(
                  onPressed: _openEditarAnotacao,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const Divider(height: 16),
          if (anotacao.userNote.isNotEmpty) ...[
            Text(
              '💡 O que aprendi:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              anotacao.userNote,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
          ],
          if (anotacao.userStrategy.isNotEmpty) ...[
            Text(
              '🎯 Minha estratégia:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              anotacao.userStrategy,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
          if (isErro) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Revise sua estratégia e tente de novo!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExplicacaoCard() {
    String explicacao = widget.questao?.explicacao ?? '';
    if (explicacao.isEmpty) {
      final idx = (widget.questao?.respostaCorreta as num?)?.toInt() ?? 0;
      final letra = String.fromCharCode(65 + idx);
      explicacao = 'A resposta correta é a alternativa $letra.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700], size: 18),
              const SizedBox(width: 6),
              const Text(
                'Explicação',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explicacao,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursosCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.acertou ? Colors.green[200]! : Colors.red[200]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                widget.acertou ? Icons.trending_up : Icons.trending_down,
                color: widget.acertou ? Colors.green[600] : Colors.red[600],
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.acertou
                      ? 'Recursos Recuperados!'
                      : (widget.isTimeout
                          ? 'Energia Perdida!'
                          : 'Água Perdida!'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: widget.acertou ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRecursoRow(Icons.flash_on, 'Energia',
              widget.recursos['energia']?.toInt() ?? 100, Colors.yellow[700]!),
          _buildRecursoRow(Icons.water_drop, 'Água',
              widget.recursos['agua']?.toInt() ?? 100, Colors.blue[700]!),
          _buildRecursoRow(Icons.favorite, 'Saúde',
              widget.recursos['saude']?.toInt() ?? 100, Colors.red[700]!),
        ],
      ),
    );
  }

  Widget _buildRecursoRow(IconData icon, String nome, int valor, Color cor) {
    final critico = valor <= 20;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: critico ? Colors.red : cor),
          const SizedBox(width: 6),
          Text(nome,
              style:
                  TextStyle(fontSize: 12, color: critico ? Colors.red : null)),
          const Spacer(),
          Text(
            '$valor%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: critico ? Colors.red : cor,
            ),
          ),
          if (critico) ...[
            const SizedBox(width: 4),
            const Icon(Icons.warning, size: 12, color: Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 18),
              const SizedBox(width: 6),
              Text(
                'Progresso',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatRow('XP Total', '${widget.nivelUsuario.xpTotal}'),
          _buildStatRow(
            'Questão',
            '${(widget.sessao?.questaoAtual ?? 0) + 1}/${widget.sessao?.totalQuestoes ?? 10}',
          ),
          _buildStatRow(
            'Precisão',
            '${(widget.sessaoUsuario.precisaoSessao * 100).toStringAsFixed(0)}%',
          ),
          _buildStatRow(
            'Nível',
            '${widget.nivelUsuario.tier.emoji} ${widget.nivelUsuario.nivel}',
          ),
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
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnotarCard() {
    // ✅ V9.4: Se é revanche com anotação existente, oferecer editar
    if (widget.isRevanche && widget.anotacaoExistente != null) {
      return const SizedBox(); // Já mostramos no card de anotação existente
    }

    if (_annotationSaved) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          children: [
            const Text('✅', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anotação salva!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    '+25 XP ganhos 🎉',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plantar essa lição?',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Anote no Diário e ganhe +25 XP',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAnotarModal,
              icon: const Icon(Icons.edit_note, size: 16),
              label: const Text('Anotar no Diário',
                  style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAnotarModal() async {
    final questao = widget.questao;
    if (questao == null) return;

    final respostaCorretaIdx = (questao.respostaCorreta as num?)?.toInt() ?? 0;
    final letraCorreta = String.fromCharCode(65 + respostaCorretaIdx);
    String textoCorreto = letraCorreta;

    try {
      if (questao.alternativas != null &&
          questao.alternativas.length > respostaCorretaIdx) {
        textoCorreto =
            '($letraCorreta) ${questao.alternativas[respostaCorretaIdx]}';
      }
    } catch (e) {
      textoCorreto = letraCorreta;
    }

    String textoUsuario = 'Nenhuma';
    if (widget.isTimeout) {
      textoUsuario = 'Tempo esgotado';
    } else if (widget.selectedOption != null && widget.selectedOption! >= 0) {
      final letraUsuario = String.fromCharCode(65 + widget.selectedOption!);
      try {
        if (questao.alternativas != null &&
            questao.alternativas.length > widget.selectedOption!) {
          textoUsuario =
              '($letraUsuario) ${questao.alternativas[widget.selectedOption!]}';
        } else {
          textoUsuario = letraUsuario;
        }
      } catch (e) {
        textoUsuario = letraUsuario;
      }
    }

    final annotation = await AnotarErroModal.show(
      context: context,
      questionId: questao.id,
      questionText: questao.enunciado ?? 'Questão',
      correctAnswer: textoCorreto,
      userAnswer: textoUsuario,
      subject: questao.subject ?? 'Geral',
      explicacao: questao.explicacao,
    );

    if (annotation != null) {
      // ✅ V9.4: Usar addOrUpdateAnnotation (1:1)
      final xpGanho =
          await ref.read(diaryProvider.notifier).addOrUpdateAnnotation(
                annotation,
                questionId: questao.id,
              );

      if (xpGanho > 0) {
        setState(() {
          _annotationSaved = true;
        });

        // Adicionar XP
        await ref.read(nivelProvider.notifier).adicionarXp(xpGanho);

        // Verificar badges de anotação (o ref.listen no build() vai reagir automaticamente)
        ref.read(diaryBadgesProvider.notifier).checkBadges();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text('Lição plantada! +$xpGanho XP'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _openEditarAnotacao() async {
    // Abre o modal de anotar - que vai fazer update se já existe
    await _openAnotarModal();
  }

  Widget _buildBotaoContinuar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _showingBadge ? null : widget.onContinue,
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              _showingBadge ? 'Aguarde...' : 'Próxima Questão',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== 🏆 MODAL DE RANKING (mantido igual) =====
class _RankingModalContent extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onViewFull;

  const _RankingModalContent({required this.onClose, required this.onViewFull});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade500
                      ]),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.emoji_events,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ranking',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Text('Jogo pausado',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildRankingPreviewItem(
                      1, '🥇', 'Lucas Silva', 2500, Colors.amber),
                  _buildRankingPreviewItem(
                      2, '🥈', 'Maria Santos', 2350, Colors.grey.shade400),
                  _buildRankingPreviewItem(
                      3, '🥉', 'Pedro Costa', 2100, Colors.orange.shade300),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200)),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Center(
                              child: Text('#7',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sua posição',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                              Text('Continue jogando para subir!',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
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
                            borderRadius: BorderRadius.circular(12))),
                    child: Text('Ver Completo',
                        style: TextStyle(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold)),
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
                            borderRadius: BorderRadius.circular(12))),
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
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15))),
          Text('$points pts',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                  fontSize: 15)),
        ],
      ),
    );
  }
}

// ===== 👤 MODAL DE PERFIL (mantido igual) =====
class _PerfilModalContent extends StatelessWidget {
  final String userName;
  final int nivel;
  final int xpTotal;
  final NivelTier tier;
  final Avatar? avatar;
  final VoidCallback onClose;
  final VoidCallback onViewFull;

  const _PerfilModalContent(
      {required this.userName,
      required this.nivel,
      required this.xpTotal,
      required this.tier,
      this.avatar,
      required this.onClose,
      required this.onViewFull});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.green.shade400,
                        Colors.teal.shade500
                      ]),
                      borderRadius: BorderRadius.circular(30)),
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
                                        fontWeight: FontWeight.bold))),
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
                                  fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const Text('Jogo pausado',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.amber.shade100,
                          Colors.orange.shade100
                        ]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade300)),
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
                                Text('Nível $nivel',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                Text(tier.nome,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.w500)),
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
                            Text('$xpTotal XP Total',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    _buildStatCard('🎯', 'Precisão', '85%'),
                    const SizedBox(width: 12),
                    _buildStatCard('🔥', 'Sequência', '3 dias')
                  ]),
                ],
              ),
            ),
          ),
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
                            borderRadius: BorderRadius.circular(12))),
                    child: Text('Ver Completo',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold)),
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
                            borderRadius: BorderRadius.circular(12))),
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
            border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
