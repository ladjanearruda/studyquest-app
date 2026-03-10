// lib/features/diario/widgets/badge_unlock_modal.dart
// ✅ V9.3 - Sprint 9 Fase 3: Modal de Celebração de Badge
// 📅 Criado: 24/02/2026
// 🎯 Animação épica quando badge é desbloqueada

import 'package:flutter/material.dart';
import '../models/diary_badge_model.dart';

/// Modal de celebração quando uma badge é desbloqueada
class BadgeUnlockModal extends StatefulWidget {
  final DiaryBadge badge;
  final VoidCallback onClose;

  const BadgeUnlockModal({
    super.key,
    required this.badge,
    required this.onClose,
  });

  /// Mostrar o modal
  static Future<void> show({
    required BuildContext context,
    required DiaryBadge badge,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => BadgeUnlockModal(
        badge: badge,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<BadgeUnlockModal> createState() => _BadgeUnlockModalState();
}

class _BadgeUnlockModalState extends State<BadgeUnlockModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de escala (bounce)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animação de rotação
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Animação de brilho
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Animação de partículas
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Iniciar animações
    _scaleController.forward();
    _rotateController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Color get _badgeColor {
    switch (widget.badge.raridade) {
      case BadgeRarity.comum:
        return Colors.green;
      case BadgeRarity.incomum:
        return Colors.blue;
      case BadgeRarity.raro:
        return Colors.purple;
      case BadgeRarity.epico:
        return Colors.orange;
      case BadgeRarity.lendario:
        return const Color(0xFFFFD700);
    }
  }

  List<Color> get _gradientColors {
    switch (widget.badge.raridade) {
      case BadgeRarity.comum:
        return [Colors.green.shade300, Colors.green.shade600];
      case BadgeRarity.incomum:
        return [Colors.blue.shade300, Colors.blue.shade600];
      case BadgeRarity.raro:
        return [Colors.purple.shade300, Colors.purple.shade600];
      case BadgeRarity.epico:
        return [Colors.orange.shade300, Colors.deepOrange.shade600];
      case BadgeRarity.lendario:
        return [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _rotateAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade900,
                      Colors.grey.shade800,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _badgeColor.withOpacity(_glowAnimation.value),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _badgeColor.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: _gradientColors,
                      ).createShader(bounds),
                      child: const Text(
                        '🎉 CONQUISTA DESBLOQUEADA!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Badge com brilho
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow background
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _badgeColor
                                    .withOpacity(0.4 * _glowAnimation.value),
                                _badgeColor.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Badge container
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _badgeColor.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.badge.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Nome da badge
                    Text(
                      widget.badge.nome,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _badgeColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Raridade
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _badgeColor.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        widget.badge.raridadeNome.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _badgeColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Descrição
                    Text(
                      widget.badge.descricao,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade300,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // XP ganho
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade700,
                            Colors.orange.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '⭐',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.badge.xpRecompensa} XP',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão continuar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _badgeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'INCRÍVEL! 🎊',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
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
    );
  }
}

/// Widget para mostrar badge em grade (para tab Conquistas)
class BadgeGridItem extends StatelessWidget {
  final DiaryBadge badge;
  final bool unlocked;
  final DateTime? unlockedAt;
  final VoidCallback? onTap;

  const BadgeGridItem({
    super.key,
    required this.badge,
    required this.unlocked,
    this.unlockedAt,
    this.onTap,
  });

  Color get _badgeColor {
    if (!unlocked) return Colors.grey;

    switch (badge.raridade) {
      case BadgeRarity.comum:
        return Colors.green;
      case BadgeRarity.incomum:
        return Colors.blue;
      case BadgeRarity.raro:
        return Colors.purple;
      case BadgeRarity.epico:
        return Colors.orange;
      case BadgeRarity.lendario:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked ? _badgeColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                unlocked ? _badgeColor.withOpacity(0.3) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji ou cadeado
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? _badgeColor.withOpacity(0.2)
                    : Colors.grey.shade200,
                border: Border.all(
                  color: unlocked ? _badgeColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  unlocked ? badge.emoji : '🔒',
                  style: TextStyle(
                    fontSize: unlocked ? 28 : 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Nome
            Text(
              unlocked ? badge.nome : '???',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: unlocked ? _badgeColor : Colors.grey,
              ),
            ),

            const SizedBox(height: 4),

            // XP ou hint
            if (unlocked)
              Text(
                '+${badge.xpRecompensa} XP',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                badge.hint.length > 25
                    ? '${badge.hint.substring(0, 25)}...'
                    : badge.hint,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Modal de detalhes da badge
class BadgeDetailModal extends StatelessWidget {
  final DiaryBadge badge;
  final bool unlocked;
  final DateTime? unlockedAt;

  const BadgeDetailModal({
    super.key,
    required this.badge,
    required this.unlocked,
    this.unlockedAt,
  });

  static Future<void> show({
    required BuildContext context,
    required DiaryBadge badge,
    required bool unlocked,
    DateTime? unlockedAt,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // ✅ Permite controle de altura
      builder: (context) => BadgeDetailModal(
        badge: badge,
        unlocked: unlocked,
        unlockedAt: unlockedAt,
      ),
    );
  }

  Color get _badgeColor {
    switch (badge.raridade) {
      case BadgeRarity.comum:
        return Colors.green;
      case BadgeRarity.incomum:
        return Colors.blue;
      case BadgeRarity.raro:
        return Colors.purple;
      case BadgeRarity.epico:
        return Colors.orange;
      case BadgeRarity.lendario:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // ✅ Limita altura
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          // ✅ Adiciona scroll
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

              const SizedBox(height: 20),

              // Badge
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? _badgeColor.withOpacity(0.2)
                      : Colors.grey.shade200,
                  border: Border.all(
                    color: unlocked ? _badgeColor : Colors.grey,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    unlocked ? badge.emoji : '🔒',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Nome
              Text(
                unlocked ? badge.nome : '???',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: unlocked ? _badgeColor : Colors.grey,
                ),
              ),

              const SizedBox(height: 6),

              // Raridade
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      (unlocked ? _badgeColor : Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.raridadeNome,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: unlocked ? _badgeColor : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Descrição
              Text(
                badge.descricao,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              // XP ou como desbloquear
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: unlocked ? Colors.amber.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        unlocked ? Colors.amber.shade200 : Colors.grey.shade300,
                  ),
                ),
                child: unlocked
                    ? Column(
                        children: [
                          Text(
                            '+${badge.xpRecompensa} XP conquistados!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          if (unlockedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Desbloqueada em ${_formatDate(unlockedAt!)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Column(
                        children: [
                          const Text(
                            '💡 Como desbloquear:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            badge.hint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Recompensa: +${badge.xpRecompensa} XP',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // Botão fechar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: unlocked ? _badgeColor : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
