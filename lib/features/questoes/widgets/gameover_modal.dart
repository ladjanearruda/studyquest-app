// lib/features/questoes/widgets/gameover_modal.dart
// ✅ V7.1 - Modal de Game Over (Saúde = 0)
// ✅ CORRIGIDO: Overflow com SingleChildScrollView e altura máxima

import 'package:flutter/material.dart';
import '../../../core/models/avatar.dart';

class GameOverModal extends StatelessWidget {
  final int nivelAtual;
  final int xpPerdido;
  final Avatar? avatar;
  final VoidCallback onTentarNovamente;
  final VoidCallback onVoltarMenu;

  const GameOverModal({
    super.key,
    required this.nivelAtual,
    required this.xpPerdido,
    this.avatar,
    required this.onTentarNovamente,
    required this.onVoltarMenu,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.85, // ✅ Limita altura máxima
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header vermelho (fixo no topo)
            _buildHeader(),

            // Conteúdo com scroll
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar triste
                    _buildAvatar(),

                    const SizedBox(height: 20),

                    // Mensagem principal
                    const Text(
                      'Sua saúde zerou!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Explicação
                    Text(
                      'Você acumulou muitos erros e timeouts.\nPrecisa voltar ao início do nível $nivelAtual.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Card de consequências
                    _buildConsequenciasCard(),

                    const SizedBox(height: 20),

                    // Dica motivacional
                    _buildDicaMotivacional(),

                    const SizedBox(height: 24),

                    // Botões
                    _buildBotoes(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.red[700]!],
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
          Icon(
            Icons.favorite_border,
            color: Colors.white.withOpacity(0.8),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'GAME OVER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.favorite_border,
            color: Colors.white.withOpacity(0.8),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatar != null) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[300]!, Colors.red[500]!],
          ),
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child: Container(
            width: 100,
            height: 100,
            color: Colors.white,
            child: Image.asset(
              avatar!.getPath(AvatarEmotion.determinado),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.sentiment_very_dissatisfied,
                  size: 60,
                  color: Colors.red[400],
                );
              },
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(60),
      ),
      child: Icon(
        Icons.sentiment_very_dissatisfied,
        size: 60,
        color: Colors.red[400],
      ),
    );
  }

  Widget _buildConsequenciasCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Consequências:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildConsequenciaItem(
            Icons.replay,
            'Volta ao início do nível $nivelAtual',
          ),
          const SizedBox(height: 8),
          _buildConsequenciaItem(
            Icons.remove_circle_outline,
            'XP do nível: perdido (-$xpPerdido XP)',
          ),
          const SizedBox(height: 8),
          _buildConsequenciaItem(
            Icons.star_outline,
            'Nível mantido: $nivelAtual',
            isNeutral: true,
          ),
          const SizedBox(height: 8),
          _buildConsequenciaItem(
            Icons.battery_charging_full,
            'Todos recursos: 100%',
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConsequenciaItem(IconData icon, String texto,
      {bool isPositive = false, bool isNeutral = false}) {
    Color color;
    if (isPositive) {
      color = Colors.green[600]!;
    } else if (isNeutral) {
      color = Colors.orange[600]!;
    } else {
      color = Colors.red[600]!;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDicaMotivacional() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.amber[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica do Explorador:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Leia com calma e gerencie seu tempo. Cada erro é uma chance de aprender!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[900],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotoes(BuildContext context) {
    return Column(
      children: [
        // Botão principal - Tentar novamente
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onTentarNovamente,
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
                Icon(Icons.refresh, size: 22),
                SizedBox(width: 10),
                Text(
                  'Tentar Novamente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botão secundário - Voltar ao menu
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: onVoltarMenu,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Voltar ao Menu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===== FUNÇÃO HELPER PARA MOSTRAR O MODAL =====
Future<bool> showGameOverModal({
  required BuildContext context,
  required int nivelAtual,
  required int xpPerdido,
  Avatar? avatar,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.8),
    builder: (context) => GameOverModal(
      nivelAtual: nivelAtual,
      xpPerdido: xpPerdido,
      avatar: avatar,
      onTentarNovamente: () => Navigator.of(context).pop(true),
      onVoltarMenu: () => Navigator.of(context).pop(false),
    ),
  );

  return result ?? false;
}
