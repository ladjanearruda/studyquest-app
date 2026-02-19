// lib/features/auth/screens/forgot_password_screen.dart
// Sprint 8 - Tela de Recuperação de Senha

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/firebase_rest_auth.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authNotifier = ref.read(authProvider.notifier);
    final success =
        await authNotifier.sendPasswordReset(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      _showError('Erro ao enviar email. Verifique se o email está correto.');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.green[100]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Botão Voltar
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon:
                          Icon(Icons.arrow_back_ios, color: Colors.green[700]),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Conteúdo principal
                  _emailSent ? _buildSuccessContent() : _buildFormContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        // Header
        _buildHeader(),

        const SizedBox(height: 40),

        // Formulário
        _buildForm(),

        const SizedBox(height: 24),

        // Botão Enviar
        _buildSendButton(),

        const SizedBox(height: 24),

        // Voltar para login
        _buildBackToLogin(),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const SizedBox(height: 60),

        // Ícone de sucesso
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 60,
            color: Colors.green[600],
          ),
        ),

        const SizedBox(height: 32),

        // Título
        Text(
          'Email enviado!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),

        const SizedBox(height: 16),

        // Descrição
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Enviamos um link de recuperação para:\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Instruções
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verifique também a pasta de spam',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Botão voltar para login
        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 22),
                SizedBox(width: 8),
                Text(
                  'Voltar para Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Não recebeu?
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: Text(
            'Não recebeu? Tentar novamente',
            style: TextStyle(
              fontSize: 15,
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Ícone
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_reset,
            size: 50,
            color: Colors.green[600],
          ),
        ),
        const SizedBox(height: 24),

        // Título
        Text(
          'Esqueceu a senha?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 12),

        // Subtítulo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Digite seu email e enviaremos um link para criar uma nova senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 16),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite seu email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Email inválido';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'seu@email.com',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.green[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green[600]!, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.green[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Enviar link de recuperação',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/login'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 18, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              'Voltar para o login',
              style: TextStyle(
                fontSize: 15,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
