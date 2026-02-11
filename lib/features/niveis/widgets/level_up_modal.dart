// lib/features/niveis/widgets/level_up_modal.dart
// ✅ Sprint 7 Parte 2 - Modal de Level Up
// 📅 Criado: 06/02/2026

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/nivel_model.dart';
import '../../../core/models/avatar.dart';

class LevelUpModal extends StatefulWidget {
  final int nivelAnterior;
  final int novoNivel;
  final NivelTier tierAnterior;
  final NivelTier novoTier;
  final List<Desbloqueio> desbloqueios;
  final String mensagem;
  final Avatar? avatar;
  final VoidCallback onContinuar;

  const LevelUpModal({
    super.key,
    required this.nivelAnterior,
    required this.novoNivel,
    required this.tierAnterior,
    required this.novoTier,
    required this.desbloqueios,
    required this.mensagem,
    this.avatar,
    required this.onContinuar,
  });

  @override
  State<LevelUpModal> createState() => _LevelUpModalState();
}

class _LevelUpModalState extends State<LevelUpModal>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool get mudouTier => widget.tierAnterior != widget.novoTier;

  @override
  void initState() {
    super.initState();

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();

    // Animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Modal principal
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildModalContent(),
                ),
              );
            },
          ),

          // Confetti
          Positioned(
            top: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.yellow,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.pink,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
              emissionFrequency: 0.05,
              maxBlastForce: 20,
              minBlastForce: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalContent() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: 400,
        maxHeight: screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header dourado
          _buildHeader(),

          // Conteúdo com scroll
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar feliz
                  _buildAvatar(),

                  const SizedBox(height: 20),

                  // Nível novo
                  _buildNivelDisplay(),

                  const SizedBox(height: 16),

                  // Mensagem motivacional
                  Text(
                    widget.mensagem,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Mudança de tier (se houver)
                  if (mudouTier) ...[
                    const SizedBox(height: 20),
                    _buildMudancaTier(),
                  ],

                  // Desbloqueios (se houver)
                  if (widget.desbloqueios.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDesbloqueios(),
                  ],

                  const SizedBox(height: 24),

                  // Botão continuar
                  _buildBotaoContinuar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: mudouTier
              ? [Colors.purple[400]!, Colors.purple[700]!]
              : [Colors.amber[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_upward, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            mudouTier ? 'NOVO TIER!' : 'LEVEL UP!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_upward, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.avatar != null) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[300]!, Colors.orange[500]!],
          ),
          borderRadius: BorderRadius.circular(70),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: Container(
            width: 120,
            height: 120,
            color: Colors.white,
            child: Image.asset(
              widget.avatar!.getPath(AvatarEmotion.feliz),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.amber[600],
                );
              },
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(70),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.celebration,
        size: 70,
        color: Colors.amber[600],
      ),
    );
  }

  Widget _buildNivelDisplay() {
    return Column(
      children: [
        // Animação de transição de nível
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nível anterior (pequeno, opaco)
            Text(
              '${widget.nivelAnterior}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.arrow_forward,
                size: 32,
                color: Colors.amber[600],
              ),
            ),
            // Nível novo (grande, destacado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.orange[500]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${widget.novoNivel}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Tier atual
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green[200]!, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.novoTier.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                widget.novoTier.nome,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMudancaTier() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[50]!, Colors.purple[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[300]!, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upgrade, color: Colors.purple[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Evolução de Tier!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.tierAnterior.emoji} ${widget.tierAnterior.nome}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: Colors.purple[400],
                ),
              ),
              Text(
                '${widget.novoTier.emoji} ${widget.novoTier.nome}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.novoTier.descricao,
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDesbloqueios() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lock_open, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Novos Desbloqueios!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.desbloqueios.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(d.icone, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.titulo,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            d.descricao,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBotaoContinuar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: widget.onContinuar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 3,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward, size: 22),
            SizedBox(width: 10),
            Text(
              'Continuar Explorando',
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
}

// ===== FUNÇÃO HELPER PARA MOSTRAR O MODAL =====
Future<void> showLevelUpModal({
  required BuildContext context,
  required int nivelAnterior,
  required int novoNivel,
  required NivelTier tierAnterior,
  required NivelTier novoTier,
  required List<Desbloqueio> desbloqueios,
  required String mensagem,
  Avatar? avatar,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.8),
    builder: (context) => LevelUpModal(
      nivelAnterior: nivelAnterior,
      novoNivel: novoNivel,
      tierAnterior: tierAnterior,
      novoTier: novoTier,
      desbloqueios: desbloqueios,
      mensagem: mensagem,
      avatar: avatar,
      onContinuar: () => Navigator.of(context).pop(),
    ),
  );
}
