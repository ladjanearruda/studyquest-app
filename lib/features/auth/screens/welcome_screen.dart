// lib/features/auth/screens/welcome_screen.dart
// Sprint 8 - WelcomeScreen com opções de Login/Registro

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/services/firebase_rest_auth.dart';

/// WelcomeScreen - Tela inicial com opções de autenticação
///
/// Fluxo:
/// 1. Verifica se usuário já está logado
/// 2. Se logado + onboarding completo → /home
/// 3. Se logado + sem onboarding → /onboarding/0
/// 4. Se não logado → mostra opções (Login, Registro, Continuar sem conta)
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isChecking = true;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();

    // Animações
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Verificar status do usuário
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    // Aguardar um pouco para mostrar o splash
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Verificar se já está logado
    final user = await FirebaseRestAuth.getCurrentUser();

    if (user != null) {
      // Usuário existe, verificar onboarding
      final hasOnboarding = await FirebaseRestAuth.hasCompletedOnboarding();

      if (!mounted) return;

      if (hasOnboarding) {
        // Usuário completo → Home
        context.go('/home');
      } else {
        // Usuário sem onboarding → Onboarding
        context.go('/onboarding/0');
      }
    } else {
      // Nenhum usuário → mostrar opções
      setState(() {
        _isChecking = false;
        _showButtons = true;
      });
    }
  }

  Future<void> _handleContinueWithoutAccount() async {
    setState(() => _isChecking = true);

    // Criar conta anônima
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.signInAnonymously();

    if (!mounted) return;

    if (success) {
      context.go('/onboarding/0');
    } else {
      setState(() => _isChecking = false);
      _showError('Erro ao iniciar. Tente novamente.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[800]!,
              Colors.green[600]!,
              Colors.green[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Área principal (logo + texto)
              Expanded(
                flex: 3,
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogoSection(),
                    ),
                  ),
                ),
              ),

              // Área de botões
              Expanded(
                flex: 2,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _showButtons
                        ? _buildButtonsSection()
                        : _buildLoadingSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.school,
                size: 60,
                color: Colors.green[700],
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber[400],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Título
        const Text(
          'StudyQuest',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Subtítulo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '🚀 Sua jornada educacional começa aqui',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withOpacity(0.9),
          ),
          strokeWidth: 3,
        ),
        const SizedBox(height: 20),
        Text(
          _isChecking ? 'Verificando...' : 'Carregando...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botão Entrar
          _buildButton(
            onPressed: () => context.push('/login'),
            text: 'Entrar',
            icon: Icons.login,
            isPrimary: true,
          ),

          const SizedBox(height: 16),

          // Botão Criar Conta
          _buildButton(
            onPressed: () => context.push('/register'),
            text: 'Criar conta grátis',
            icon: Icons.person_add,
            isPrimary: false,
          ),

          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Continuar sem conta
          TextButton(
            onPressed: _isChecking ? null : _handleContinueWithoutAccount,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continuar sem conta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Aviso
          Text(
            'Seus dados ficarão salvos apenas neste dispositivo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.transparent,
          foregroundColor: isPrimary ? Colors.green[700] : Colors.white,
          elevation: isPrimary ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
