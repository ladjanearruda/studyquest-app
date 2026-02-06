// lib/features/questoes/widgets/checkpoint_modal.dart
// ✅ V7.1 - Modal de Checkpoint (Água ou Energia = 0)
// ✅ CORRIGIDO: Overflow com SingleChildScrollView e altura máxima

import 'package:flutter/material.dart';
import '../../../core/models/avatar.dart';

class CheckpointModal extends StatelessWidget {
  final String recursoZerado; // 'agua' ou 'energia'
  final int xpPerdido;
  final Avatar? avatar;
  final VoidCallback onContinuar;
  final VoidCallback onDesistir;

  const CheckpointModal({
    super.key,
    required this.recursoZerado,
    required this.xpPerdido,
    this.avatar,
    required this.onContinuar,
    required this.onDesistir,
  });

  @override
  Widget build(BuildContext context) {
    final isAgua = recursoZerado == 'agua';
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fixo no topo)
            _buildHeader(isAgua),

            // Conteúdo com scroll
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar
                    _buildAvatar(),

                    const SizedBox(height: 20),

                    // Mensagem principal
                    Text(
                      isAgua ? 'Sua água acabou!' : 'Sua energia esgotou!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Explicação
                    Text(
                      isAgua
                          ? 'Você errou muitas questões seguidas.\nPrecisa recomeçar esta sessão.'
                          : 'O tempo esgotou várias vezes.\nPrecisa recomeçar esta sessão.',
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

  Widget _buildHeader(bool isAgua) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAgua
              ? [Colors.blue[400]!, Colors.blue[600]!]
              : [Colors.orange[400]!, Colors.orange[600]!],
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
            isAgua ? Icons.water_drop : Icons.flash_on,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'CHECKPOINT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            isAgua ? Icons.water_drop : Icons.flash_on,
            color: Colors.white,
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
            colors: [Colors.orange[300]!, Colors.orange[500]!],
          ),
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
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
                  Icons.sentiment_dissatisfied,
                  size: 60,
                  color: Colors.orange[400],
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
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(60),
      ),
      child: Icon(
        Icons.sentiment_dissatisfied,
        size: 60,
        color: Colors.orange[400],
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
              Icon(Icons.info_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'O que acontece:',
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
            'Volta ao início desta sessão',
          ),
          const SizedBox(height: 8),
          _buildConsequenciaItem(
            Icons.remove_circle_outline,
            xpPerdido > 0
                ? 'XP perdido: -$xpPerdido XP'
                : 'XP da sessão: resetado',
          ),
          const SizedBox(height: 8),
          _buildConsequenciaItem(
            Icons.battery_charging_full,
            'Água e Energia: 100%',
          ),
          const SizedBox(height: 8),
          _buildConsequenciaItem(
            Icons.favorite,
            'Saúde: mantida',
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConsequenciaItem(IconData icon, String texto,
      {bool isPositive = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isPositive ? Colors.green[600] : Colors.red[600],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: isPositive ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotoes(BuildContext context) {
    return Column(
      children: [
        // Botão principal - Continuar
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onContinuar,
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
                Icon(Icons.fitness_center, size: 22),
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
        ),

        const SizedBox(height: 12),

        // Botão secundário - Voltar ao menu
        TextButton(
          onPressed: onDesistir,
          child: Text(
            'Voltar ao menu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// ===== FUNÇÃO HELPER PARA MOSTRAR O MODAL =====
Future<bool> showCheckpointModal({
  required BuildContext context,
  required String recursoZerado,
  required int xpPerdido,
  Avatar? avatar,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => CheckpointModal(
      recursoZerado: recursoZerado,
      xpPerdido: xpPerdido,
      avatar: avatar,
      onContinuar: () => Navigator.of(context).pop(true),
      onDesistir: () => Navigator.of(context).pop(false),
    ),
  );

  return result ?? false;
}
