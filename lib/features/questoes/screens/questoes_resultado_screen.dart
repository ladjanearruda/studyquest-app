// lib/features/questoes/screens/questoes_resultado_screen.dart
// ✅ V9.0 - Sprint 9: Integração com Termômetro Emocional
// 📅 Atualizado: 18/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/questao_personalizada_provider.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../core/models/avatar.dart';
import '../providers/recursos_provider_v71.dart';

// Imports do sistema de níveis
import '../../niveis/models/nivel_model.dart';
import '../../niveis/providers/nivel_provider.dart';

// ✅ V9.0: Import do Termômetro Emocional
import '../../diario/models/diary_emotion_model.dart';

class QuestoesResultadoScreen extends ConsumerStatefulWidget {
  const QuestoesResultadoScreen({super.key});

  @override
  ConsumerState<QuestoesResultadoScreen> createState() =>
      _QuestoesResultadoScreenState();
}

class _QuestoesResultadoScreenState
    extends ConsumerState<QuestoesResultadoScreen> {
  Avatar? _currentAvatar;
  bool _termometroShown = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();

    // ✅ V9.0: Mostrar termômetro emocional após animações iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTermometroEmocional();
    });
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

  // ✅ V9.0: Mostrar modal do Termômetro Emocional
  Future<void> _showTermometroEmocional() async {
    if (_termometroShown) return;
    _termometroShown = true;

    // Aguardar animações da tela de resultado
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final sessao = ref.read(sessaoQuestoesProvider);
    final totalQuestoes = sessao.totalQuestoes;
    final acertos = sessao.acertos.where((a) => a).length;
    final precisao = totalQuestoes > 0 ? (acertos / totalQuestoes) : 0.0;

    final emotion = await _showTermometroModal(context, precisao);

    if (emotion != null && mounted) {
      // TODO: Salvar no Firebase via DiaryProvider
      print('📊 Emoção selecionada: ${emotion.emoji} - ${emotion.label}');
      print('📊 Precisão da sessão: ${(precisao * 100).toInt()}%');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(emotion.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              const Text('Obrigado pelo feedback!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ V9.0: Modal do Termômetro Emocional
  Future<EmotionLevel?> _showTermometroModal(
      BuildContext context, double precisao) async {
    EmotionLevel? selectedEmotion;

    return showModalBottomSheet<EmotionLevel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                      final isSelected = selectedEmotion == emotion;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedEmotion = emotion;
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
                              color: isSelected
                                  ? _getEmotionColor(emotion)
                                  : Colors.transparent,
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
                    }).toList(),
                  ),

                  // Label do selecionado
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: selectedEmotion != null
                        ? Container(
                            key: ValueKey(selectedEmotion),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getEmotionColor(selectedEmotion!)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              selectedEmotion!.label,
                              style: TextStyle(
                                color: _getEmotionColor(selectedEmotion!),
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
                          child: const Text('Pular',
                              style: TextStyle(fontSize: 15)),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Confirmar
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedEmotion != null
                              ? () => Navigator.pop(context, selectedEmotion)
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
                                fontSize: 15, fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    final sessao = ref.watch(sessaoQuestoesProvider);
    final recursos = ref.watch(recursosPersonalizadosProvider);
    final onboardingData = ref.watch(onboardingProvider);
    final nivelUsuario = ref.watch(nivelProvider);

    final totalQuestoes = sessao.totalQuestoes;
    final acertos = sessao.acertos.where((a) => a).length;
    final precisao = totalQuestoes > 0 ? (acertos / totalQuestoes) : 0.0;
    final performance = _getPerformanceLevel(precisao);
    final xpGanhoSessao = _calcularXpSessao(sessao);

    final saudeCritica = (recursos['saude'] ?? 100) <= 30;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [performance.primaryColor, performance.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _buildCompactHeaderComAvatar(performance, onboardingData),
                  const SizedBox(height: 20),
                  if (saudeCritica) ...[
                    _buildAlertaSaudeCritica(recursos['saude'] ?? 0),
                    const SizedBox(height: 16),
                  ],
                  _buildMainResultCard(
                      performance, acertos, totalQuestoes, precisao),
                  const SizedBox(height: 16),
                  _buildNivelCard(nivelUsuario, xpGanhoSessao),
                  const SizedBox(height: 16),
                  _buildRecursosCard(recursos),
                  const SizedBox(height: 16),
                  _buildProximosDesbloqueios(nivelUsuario),
                  const SizedBox(height: 20),
                  _buildActionButtons(context, ref, saudeCritica),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _calcularXpSessao(dynamic sessao) {
    try {
      final acertos = (sessao.acertos as List).where((a) => a == true).length;
      return acertos * 25;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildCompactHeaderComAvatar(
      PerformanceData performance, OnboardingData onboardingData) {
    return Row(
      children: [
        if (_currentAvatar != null)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade500],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  _currentAvatar!.getPath(AvatarEmotion.feliz),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(performance.icon,
                        size: 40, color: performance.primaryColor);
                  },
                ),
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.bounceOut)
        else
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(performance.icon,
                size: 44, color: performance.primaryColor),
          ).animate().scale(duration: 600.ms, curve: Curves.bounceOut),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎉 MISSÃO CONCLUÍDA!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        color: Colors.black26,
                        offset: const Offset(1, 1),
                        blurRadius: 2),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                performance.subtitle,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                performance.motivationalMessage,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ).animate().slideX(begin: 0.5, duration: 500.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildAlertaSaudeCritica(double saude) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade200, size: 28)
              .animate(onPlay: (c) => c.repeat())
              .shake(duration: 1000.ms, delay: 2000.ms),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saúde Crítica: ${saude.toInt()}%',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade100)),
                Text('Se chegar a 0%, você volta ao início do nível!',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade200)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).shake(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildMainResultCard(PerformanceData performance, int acertos,
      int totalQuestoes, double precisao) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: performance.badgeColor,
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(performance.icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(performance.badge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$acertos',
                  style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: performance.primaryColor)),
              Text('/$totalQuestoes',
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Questões Corretas',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          _buildProgressBar(precisao, performance),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 500.ms, delay: 300.ms);
  }

  Widget _buildProgressBar(double precisao, PerformanceData performance) {
    return Column(
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: precisao,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      performance.primaryColor,
                      performance.secondaryColor
                    ]),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ).animate().slideX(
                  begin: -1,
                  duration: 800.ms,
                  delay: 600.ms,
                  curve: Curves.easeOut),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('${(precisao * 100).round()}% de precisão',
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildNivelCard(NivelUsuario nivelUsuario, int xpGanhoSessao) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: _getTierColors(nivelUsuario.tier)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(nivelUsuario.tier.emoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text('Nv.${nivelUsuario.nivel}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nivelUsuario.tier.nome,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('${nivelUsuario.xpTotal} XP total',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              if (xpGanhoSessao > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward,
                          size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 2),
                      Text('+$xpGanhoSessao',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700)),
                    ],
                  ),
                ).animate().scale(
                    delay: 500.ms, duration: 400.ms, curve: Curves.bounceOut),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${nivelUsuario.xpNoNivel}/${nivelUsuario.xpParaProximo} XP',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade700)),
                  Text('${(nivelUsuario.progresso * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 12,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6)),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: nivelUsuario.progresso,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.amber.shade400,
                            Colors.orange.shade500
                          ]),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                  'Faltam ${nivelUsuario.xpFaltando} XP para o nível ${nivelUsuario.nivel + 1}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 500.ms);
  }

  List<Color> _getTierColors(NivelTier tier) {
    switch (tier) {
      case NivelTier.iniciante:
        return [Colors.green.shade400, Colors.green.shade600];
      case NivelTier.aprendiz:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case NivelTier.explorador:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case NivelTier.mestre:
        return [Colors.purple.shade400, Colors.purple.shade600];
      case NivelTier.lenda:
        return [Colors.amber.shade400, Colors.amber.shade700];
    }
  }

  Widget _buildRecursosCard(Map<String, double> recursos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('Recursos Vitais',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Spacer(),
              _buildStatusIndicator(recursos),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildRecursoStat(Icons.flash_on, 'Energia',
                      recursos['energia']?.toInt() ?? 0, Colors.amber)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildRecursoStat(Icons.water_drop, 'Água',
                      recursos['agua']?.toInt() ?? 0, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildRecursoStat(Icons.favorite, 'Saúde',
                      recursos['saude']?.toInt() ?? 0, Colors.red)),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: -0.3, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildStatusIndicator(Map<String, double> recursos) {
    final saude = recursos['saude'] ?? 100;
    String status;
    Color cor;
    IconData icone;

    if (saude >= 70) {
      status = 'Ótimo';
      cor = Colors.green.shade300;
      icone = Icons.thumb_up;
    } else if (saude >= 40) {
      status = 'Atenção';
      cor = Colors.orange.shade300;
      icone = Icons.warning_amber;
    } else {
      status = 'Crítico';
      cor = Colors.red.shade300;
      icone = Icons.dangerous;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: cor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 14),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: cor)),
        ],
      ),
    );
  }

  Widget _buildRecursoStat(IconData icon, String nome, int valor, Color cor) {
    final isCritico = valor <= 30;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border:
            isCritico ? Border.all(color: Colors.red.shade300, width: 2) : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: isCritico ? Colors.red.shade300 : cor, size: 22),
          const SizedBox(height: 6),
          Text('$valor%',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCritico ? Colors.red.shade300 : Colors.white)),
          Text(nome,
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildProximosDesbloqueios(NivelUsuario nivelUsuario) {
    final proximos =
        NivelSystem.proximosDesbloqueios(nivelUsuario.nivel, limite: 2);
    if (proximos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_open, color: Colors.amber.shade300, size: 16),
              const SizedBox(width: 6),
              Text('Próximos Desbloqueios',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade200)),
            ],
          ),
          const SizedBox(height: 8),
          ...proximos.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(d.icone, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${d.titulo} (Nv.${d.nivelRequerido})',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9))),
                    ),
                    Text('${d.nivelRequerido - nivelUsuario.nivel} níveis',
                        style: TextStyle(
                            fontSize: 10, color: Colors.amber.shade300)),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms, duration: 400.ms);
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, bool saudeCritica) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _continuarJornada(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
                  saudeCritica ? Colors.orange.shade700 : Colors.green.shade700,
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(saudeCritica ? Icons.shield : Icons.play_arrow, size: 24),
                const SizedBox(width: 10),
                Text(
                    saudeCritica
                        ? 'Continuar com Cuidado'
                        : 'Continuar Jornada',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.5, delay: 800.ms, duration: 500.ms),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => _novaMissao(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.explore, size: 18),
                      SizedBox(width: 6),
                      Text('Modos',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: Colors.white.withOpacity(0.7), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 18),
                      SizedBox(width: 6),
                      Text('Menu',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ).animate().slideY(begin: 0.5, delay: 900.ms, duration: 500.ms),
      ],
    );
  }

  PerformanceData _getPerformanceLevel(double precisao) {
    if (precisao >= 0.9) {
      return PerformanceData(
        icon: Icons.emoji_events,
        badge: 'MAESTRIA',
        subtitle: 'Performance excepcional!',
        motivationalMessage: 'Você é um verdadeiro mestre da floresta! 🌟',
        primaryColor: Colors.amber.shade600,
        secondaryColor: Colors.orange.shade400,
        badgeColor: Colors.amber.shade700,
      );
    } else if (precisao >= 0.7) {
      return PerformanceData(
        icon: Icons.military_tech,
        badge: 'EXPERT',
        subtitle: 'Muito bem executado!',
        motivationalMessage: 'Continue assim e logo será um mestre!',
        primaryColor: Colors.green.shade600,
        secondaryColor: Colors.teal.shade400,
        badgeColor: Colors.green.shade700,
      );
    } else if (precisao >= 0.5) {
      return PerformanceData(
        icon: Icons.trending_up,
        badge: 'PROGRESSO',
        subtitle: 'Evoluindo constantemente!',
        motivationalMessage: 'Cada erro é uma chance de aprender.',
        primaryColor: Colors.blue.shade600,
        secondaryColor: Colors.indigo.shade400,
        badgeColor: Colors.blue.shade700,
      );
    } else if (precisao >= 0.3) {
      return PerformanceData(
        icon: Icons.school,
        badge: 'APRENDIZ',
        subtitle: 'Jornada de descobertas!',
        motivationalMessage: 'A prática leva à perfeição. Continue!',
        primaryColor: Colors.purple.shade600,
        secondaryColor: Colors.deepPurple.shade400,
        badgeColor: Colors.purple.shade700,
      );
    } else {
      return PerformanceData(
        icon: Icons.nature_people,
        badge: 'EXPLORADOR',
        subtitle: 'Primeiros passos na floresta',
        motivationalMessage: 'Não desista! Todo mestre já foi iniciante.',
        primaryColor: Colors.teal.shade600,
        secondaryColor: Colors.cyan.shade400,
        badgeColor: Colors.teal.shade700,
      );
    }
  }

  void _novaMissao(BuildContext context, WidgetRef ref) {
    ref.read(recursosPersonalizadosProvider.notifier).iniciarSessao();
    ref.read(sessaoQuestoesProvider.notifier).resetSessao();
    context.go('/modo-selection');
  }

  void _continuarJornada(BuildContext context, WidgetRef ref) {
    ref.read(recursosPersonalizadosProvider.notifier).iniciarSessao();
    ref.read(sessaoQuestoesProvider.notifier).resetSessao();
    context.go('/questoes-personalizada');
  }
}

class PerformanceData {
  final IconData icon;
  final String badge;
  final String subtitle;
  final String motivationalMessage;
  final Color primaryColor;
  final Color secondaryColor;
  final Color badgeColor;

  PerformanceData({
    required this.icon,
    required this.badge,
    required this.subtitle,
    required this.motivationalMessage,
    required this.primaryColor,
    required this.secondaryColor,
    required this.badgeColor,
  });
}
