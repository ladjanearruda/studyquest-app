// lib/features/modo_descoberta/screens/modo_descoberta_resultado_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/modo_descoberta_provider.dart';

/// Tela de resultado do Modo Descoberta
/// Mostra nível detectado, badge conquistada e estatísticas
class ModoDescobertaResultadoScreen extends ConsumerStatefulWidget {
  const ModoDescobertaResultadoScreen({super.key});

  @override
  ConsumerState<ModoDescobertaResultadoScreen> createState() =>
      _ModoDescobertaResultadoScreenState();
}

class _ModoDescobertaResultadoScreenState
    extends ConsumerState<ModoDescobertaResultadoScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _contentController;
  late AnimationController _ctaController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _ctaController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _startAnimations() async {
    _celebrationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _ctaController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _contentController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modoDescobertaProvider);
    final resultado = state.resultado;

    if (resultado == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Descoberta Concluída! 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Badge de conquista animada
                    AnimatedBuilder(
                      animation: _celebrationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: Curves.easeOutBack
                              .transform(_celebrationController.value),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange[400]!,
                                  Colors.orange[600]!,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange[300]!
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getEmojiPorNivel(resultado.nivelDetectado),
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Badge conquistada
                    AnimatedBuilder(
                      animation: _contentController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _contentController.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.orange[200]!, width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Badge Conquistada!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  resultado.badgeConquistado,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  resultado.badgeDescricao,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Resultado principal
                    AnimatedBuilder(
                      animation: _contentController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset:
                              Offset(0, 20 * (1 - _contentController.value)),
                          child: Opacity(
                            opacity: _contentController.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Seu nível detectado:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    resultado.resultadoFormatado,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    resultado.mensagemPersonalizada,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),

                                  // Estatísticas
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatCard(
                                        '📊',
                                        'Acertos',
                                        '${resultado.acertos}/${resultado.totalQuestoes}',
                                      ),
                                      _buildStatCard(
                                        '⏱️',
                                        'Tempo',
                                        resultado.tempoFormatado,
                                      ),
                                      _buildStatCard(
                                        '🎯',
                                        'Precisão',
                                        '${resultado.porcentagemAcerto}%',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Próximos passos
                    AnimatedBuilder(
                      animation: _contentController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset:
                              Offset(0, 30 * (1 - _contentController.value)),
                          child: Opacity(
                            opacity: _contentController.value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.green[200]!, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'O que vem agora:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...resultado.sugestoes.take(3).map(
                                        (sugestao) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('✨',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  sugestao,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ),
                                            ],
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

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            // Botão continuar
            AnimatedBuilder(
              animation: _ctaController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _ctaController.value)),
                  child: Opacity(
                    opacity: _ctaController.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _continuarParaOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600]!,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor:
                                Colors.green[600]!.withValues(alpha: 0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continuar Jornada!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('🌟', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continuarParaOnboarding() {
    // Limpar estado do modo descoberta
    ref.read(modoDescobertaProvider.notifier).resetar();

    // Retornar para Tela 8 do onboarding
    context.go('/onboarding/8');
  }

  String _getEmojiPorNivel(NivelDetectado nivel) {
    switch (nivel) {
      case NivelDetectado.iniciante:
        return '🔰';
      case NivelDetectado.iniciantePlus:
        return '🌱';
      case NivelDetectado.intermediario:
        return '📚';
      case NivelDetectado.intermediarioPlus:
        return '🎯';
      case NivelDetectado.avancado:
        return '🏆';
    }
  }
}
