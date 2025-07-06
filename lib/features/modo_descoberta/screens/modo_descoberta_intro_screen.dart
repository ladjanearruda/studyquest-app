// lib/features/modo_descoberta/screens/modo_descoberta_intro_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/modo_descoberta_provider.dart';
import '../../onboarding/screens/onboarding_screen.dart';

/// Tela de apresentação do Modo Descoberta
/// Explica o conceito e motiva o usuário a começar
class ModoDescobertaIntroScreen extends ConsumerStatefulWidget {
  final EducationLevel nivelEscolar;

  const ModoDescobertaIntroScreen({
    super.key,
    required this.nivelEscolar,
  });

  @override
  ConsumerState<ModoDescobertaIntroScreen> createState() =>
      _ModoDescobertaIntroScreenState();
}

class _ModoDescobertaIntroScreenState
    extends ConsumerState<ModoDescobertaIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _contentController;
  late AnimationController _ctaController;

  late Animation<double> _heroAnimation;
  late Animation<double> _contentAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _ctaAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    _ctaAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctaController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _heroController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _ctaController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  String _getNivelEscolarTexto() {
    switch (widget.nivelEscolar) {
      case EducationLevel.fundamental6:
        return '6º ano';
      case EducationLevel.fundamental7:
        return '7º ano';
      case EducationLevel.fundamental8:
        return '8º ano';
      case EducationLevel.fundamental9:
        return '9º ano';
      case EducationLevel.medio1:
        return '1º ano EM';
      case EducationLevel.medio2:
        return '2º ano EM';
      case EducationLevel.medio3:
        return '3º ano EM';
      case EducationLevel.completed:
        return 'Ensino Médio Completo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // Header com botão voltar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios,
                        color: Colors.green[700]!, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      'Modo Descoberta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700]!,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Espaço para centralizar
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Hero Section - Ícone animado
                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heroAnimation.value,
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
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                            child: const Center(
                              child: Text('🧭', style: TextStyle(fontSize: 50)),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Título e descrição
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _contentAnimation,
                        child: Column(
                          children: [
                            const Text(
                              'Vamos descobrir\nseu nível!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                      text: '5 questões rápidas do '),
                                  TextSpan(
                                    text: _getNivelEscolarTexto(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                  const TextSpan(
                                      text:
                                          '\npara identificar seu nível atual!'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Cards de benefícios
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _contentAnimation,
                        child: Column(
                          children: [
                            _buildBenefitCard(
                              icon: '⚡',
                              title: '2 minutos',
                              description: 'Rápido e sem pressão',
                              color: Colors.blue[600]!,
                            ),
                            const SizedBox(height: 12),
                            _buildBenefitCard(
                              icon: '🎯',
                              title: 'Súper preciso',
                              description:
                                  'Algoritmo inteligente de nivelamento',
                              color: Colors.green[600]!,
                            ),
                            const SizedBox(height: 12),
                            _buildBenefitCard(
                              icon: '🏆',
                              title: 'Badge especial',
                              description:
                                  'Conquiste a badge "Autoconhecimento"',
                              color: Colors.purple[600]!,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Motivação extra
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _contentAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '🎮',
                                style: TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Preparado para a aventura?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cada questão é uma descoberta sobre você mesmo!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            // Botão CTA
            AnimatedBuilder(
              animation: _ctaAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _ctaAnimation.value)),
                  child: Opacity(
                    opacity: _ctaAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Indicador de tempo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_outlined,
                                  color: Colors.grey[600], size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Tempo estimado: 2 minutos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Botão principal
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _iniciarModoDescoberta,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600]!,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor:
                                    Colors.orange[600]!.withValues(alpha: 0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Começar Descoberta!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.rocket_launch,
                                        size: 20),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required String icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _iniciarModoDescoberta() {
    // Iniciar o teste usando o provider
    ref.read(modoDescobertaProvider.notifier).iniciarTeste(widget.nivelEscolar);

    // Navegar para a primeira questão
    // TODO: Implementar navegação para tela de questões
    context.go('/modo-descoberta/questao');
  }
}
