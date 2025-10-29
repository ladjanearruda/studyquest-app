// lib/features/observatorio/widgets/ranking_card_widget.dart
// Widget Card de Ranking - Gaming Style
// Sprint 7 - Dia 1-2
// ATUALIZADO: Usando avatares reais dos assets (24 PNGs)

import 'package:flutter/material.dart';
import 'package:studyquest_app/core/models/user_score_model.dart';

class RankingCardWidget extends StatefulWidget {
  final UserScore userScore;
  final int position;

  const RankingCardWidget({
    super.key,
    required this.userScore,
    required this.position,
  });

  @override
  State<RankingCardWidget> createState() => _RankingCardWidgetState();
}

class _RankingCardWidgetState extends State<RankingCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isTop1 = widget.position == 1;
    final isTop2 = widget.position == 2;
    final isTop3 = widget.position == 3;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -3 : 0,
          0,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card principal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.1),
                    blurRadius: _isHovered ? 30 : 20,
                    offset: Offset(0, _isHovered ? 8 : 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Rank Number
                  _buildRankNumber(),

                  const SizedBox(width: 15),

                  // Avatar (ATUALIZADO: usando imagem real)
                  _buildAvatar(),

                  const SizedBox(width: 15),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userScore.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _getLevelName(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.userScore.score.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getRankColor(),
                        ),
                      ),
                      const Text(
                        'pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Crown badge para top 1 com animação bounce
            if (isTop1)
              Positioned(
                top: -10,
                left: -10,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - value) * -10),
                      child: Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: const Text(
                          '👑',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Rank Number com cores especiais para top 3
  Widget _buildRankNumber() {
    final isTop1 = widget.position == 1;
    final isTop2 = widget.position == 2;
    final isTop3 = widget.position == 3;

    Color color;
    if (isTop1) {
      color = const Color(0xFFFFD700); // Dourado
    } else if (isTop2) {
      color = const Color(0xFFC0C0C0); // Prata
    } else if (isTop3) {
      color = const Color(0xFFCD7F32); // Bronze
    } else {
      color = const Color(0xFF667eea); // Roxo padrão
    }

    return SizedBox(
      width: 40,
      child: Text(
        '${widget.position}º',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Avatar com imagem real dos assets
  /// Formato: assets/images/avatars/[tipo]/[genero]/[tipo]_[genero]_neutro.png
  Widget _buildAvatar() {
    final avatarPath = _getAvatarImagePath();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getRankColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRankColor().withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          avatarPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback: CircleAvatar com gradiente e iniciais
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  widget.userScore.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Retorna o caminho da imagem do avatar
  /// Formato: assets/images/avatars/[tipo]/[genero]/[tipo]_[genero]_neutro.png
  String _getAvatarImagePath() {
    final avatarType = widget.userScore.avatarType;

    // Parse do avatarType: 'academico_masculino' -> ['academico', 'masculino']
    final parts = avatarType.split('_');

    if (parts.length != 2) {
      // Fallback para equilibrado masculino se formato inválido
      return 'assets/images/avatars/equilibrado/masculino/equilibrado_masculino_neutro.png';
    }

    final tipo = parts[0]; // academico, competitivo, equilibrado, explorador
    final genero = parts[1]; // masculino, feminino
    final estado = 'neutro'; // neutro, feliz, determinado

    return 'assets/images/avatars/$tipo/$genero/${tipo}_${genero}_$estado.png';
  }

  /// Nome do nível baseado no currentLevel
  String _getLevelName() {
    // TODO: Integrar com sistema de níveis (Sprint 7 Dia 6-7)
    // Por enquanto, mostrar accuracy
    return 'Precisão ${widget.userScore.accuracy.toStringAsFixed(0)}%';
  }

  /// Cor do rank baseado na posição
  Color _getRankColor() {
    if (widget.position == 1) return const Color(0xFFFFD700); // Ouro
    if (widget.position == 2) return const Color(0xFFC0C0C0); // Prata
    if (widget.position == 3) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF667eea); // Roxo
  }
}
