// lib/features/niveis/widgets/nivel_widgets.dart
// ✅ Sprint 7 Parte 2 - Widgets Visuais de Níveis
// 📅 Criado: 06/02/2026

import 'package:flutter/material.dart';
import '../models/nivel_model.dart';

/// Badge compacta do nível (para header)
class NivelBadge extends StatelessWidget {
  final int nivel;
  final NivelTier tier;
  final bool showTierName;
  final double size;

  const NivelBadge({
    super.key,
    required this.nivel,
    required this.tier,
    this.showTierName = false,
    this.size = 1.0, // Multiplicador de tamanho
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * size,
        vertical: 4 * size,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCoresGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16 * size),
        boxShadow: [
          BoxShadow(
            color: _getCoresGradient()[0].withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tier.emoji,
            style: TextStyle(fontSize: 14 * size),
          ),
          SizedBox(width: 4 * size),
          Text(
            'Nv.$nivel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12 * size,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showTierName) ...[
            SizedBox(width: 4 * size),
            Text(
              tier.nome,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10 * size,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _getCoresGradient() {
    switch (tier) {
      case NivelTier.iniciante:
        return [Colors.green[400]!, Colors.green[600]!];
      case NivelTier.aprendiz:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case NivelTier.explorador:
        return [Colors.orange[400]!, Colors.orange[600]!];
      case NivelTier.mestre:
        return [Colors.purple[400]!, Colors.purple[600]!];
      case NivelTier.lenda:
        return [Colors.amber[400]!, Colors.amber[700]!];
    }
  }
}

/// Barra de progresso de XP
class XpProgressBar extends StatelessWidget {
  final int xpAtual;
  final int xpNecessario;
  final double progresso; // 0.0 a 1.0
  final bool showValues;
  final bool showLabel;
  final double height;
  final Color? corBarra;
  final Color? corFundo;

  const XpProgressBar({
    super.key,
    required this.xpAtual,
    required this.xpNecessario,
    required this.progresso,
    this.showValues = true,
    this.showLabel = false,
    this.height = 8,
    this.corBarra,
    this.corFundo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Progresso XP',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        // Barra
        Container(
          height: height,
          decoration: BoxDecoration(
            color: corFundo ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              // Progresso animado
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                widthFactor: progresso.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: corBarra != null
                          ? [corBarra!, corBarra!.withOpacity(0.8)]
                          : [Colors.amber[400]!, Colors.orange[500]!],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (corBarra ?? Colors.amber).withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Valores
        if (showValues)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$xpAtual XP',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$xpNecessario XP',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Widget animado para FractionallySizedBox
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final AlignmentGeometry alignment;
  final double? widthFactor;
  final double? heightFactor;
  final Widget? child;

  const AnimatedFractionallySizedBox({
    super.key,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
    this.child,
    required super.duration,
    super.curve = Curves.linear,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;
  Tween<double>? _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor ?? 0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;

    _heightFactor = visitor(
      _heightFactor,
      widget.heightFactor ?? 0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: widget.alignment,
      widthFactor: _widthFactor?.evaluate(animation),
      heightFactor: _heightFactor?.evaluate(animation),
      child: widget.child,
    );
  }
}

/// Card completo de nível (para tela de resultado ou menu)
class NivelCard extends StatelessWidget {
  final NivelUsuario nivelUsuario;
  final int? xpGanhoSessao;
  final bool showDesbloqueios;

  const NivelCard({
    super.key,
    required this.nivelUsuario,
    this.xpGanhoSessao,
    this.showDesbloqueios = true,
  });

  @override
  Widget build(BuildContext context) {
    final proximosDesbloqueios = NivelSystem.proximosDesbloqueios(
      nivelUsuario.nivel,
      limite: 2,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com badge e tier
          Row(
            children: [
              NivelBadge(
                nivel: nivelUsuario.nivel,
                tier: nivelUsuario.tier,
                showTierName: true,
                size: 1.2,
              ),
              const Spacer(),
              if (xpGanhoSessao != null && xpGanhoSessao! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 2),
                      Text(
                        '$xpGanhoSessao XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Descrição do tier
          Text(
            nivelUsuario.tier.descricao,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 16),

          // Barra de progresso
          XpProgressBar(
            xpAtual: nivelUsuario.xpNoNivel,
            xpNecessario: nivelUsuario.xpParaProximo,
            progresso: nivelUsuario.progresso,
            showLabel: true,
          ),

          const SizedBox(height: 8),

          // Faltam X XP
          Text(
            'Faltam ${nivelUsuario.xpFaltando} XP para o nível ${nivelUsuario.nivel + 1}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),

          // Próximos desbloqueios
          if (showDesbloqueios && proximosDesbloqueios.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Próximos desbloqueios:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ...proximosDesbloqueios.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text(d.icone, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${d.titulo} (Nv.${d.nivelRequerido})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// Mini widget de XP para header (muito compacto)
class MiniXpWidget extends StatelessWidget {
  final int nivel;
  final NivelTier tier;
  final double progresso;

  const MiniXpWidget({
    super.key,
    required this.nivel,
    required this.tier,
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge pequena
          Text(tier.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nv.$nivel',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Mini barra
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progresso.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber[500],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animação de XP ganho (aparece e some)
class XpGainAnimation extends StatefulWidget {
  final int xpGanho;
  final VoidCallback? onComplete;

  const XpGainAnimation({
    super.key,
    required this.xpGanho,
    this.onComplete,
  });

  @override
  State<XpGainAnimation> createState() => _XpGainAnimationState();
}

class _XpGainAnimationState extends State<XpGainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber[500],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                '+${widget.xpGanho} XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
