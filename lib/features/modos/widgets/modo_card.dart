// lib/features/modos/widgets/modo_card.dart
// StudyQuest V6.2 - Card dos Modos de Jogo

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/modo_jogo.dart';
import '../providers/modo_provider.dart';

class ModoCard extends ConsumerStatefulWidget {
  final ModoJogo modo;
  final VoidCallback? onTap;

  const ModoCard({
    super.key,
    required this.modo,
    this.onTap,
  });

  @override
  ConsumerState<ModoCard> createState() => _ModoCardState();
}

class _ModoCardState extends ConsumerState<ModoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modoState = ref.watch(modoProvider);
    final isSelected = modoState.modoSelecionado?.tipo == widget.modo.tipo;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTap: () {
                  ref.read(modoProvider.notifier).selecionarModo(widget.modo);
                  widget.onTap?.call();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _buildGradient(isSelected),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white
                              .withValues(alpha: _isHovered ? 0.3 : 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: _isHovered ? 0.3 : 0.2),
                        blurRadius: _isHovered ? 20 : 10,
                        offset: Offset(0, _isHovered ? 8 : 4),
                      ),
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header com ícone e badges
                            _buildHeader(isSelected),

                            const SizedBox(height: 16),

                            // Título e algoritmo
                            _buildTitle(),

                            const SizedBox(height: 12),

                            // Descrição
                            _buildDescription(),

                            const SizedBox(height: 16),

                            // Características
                            _buildCaracteristicas(),

                            const SizedBox(height: 20),

                            // Botão de ação
                            _buildActionButton(isSelected),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ícone do modo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(widget.modo.corPrimariaInt).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.modo.icone,
            style: const TextStyle(fontSize: 32),
          ),
        ),

        // Badges
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.modo.isRecomendado)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'RECOMENDADO',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            if (widget.modo.isSessaoExtra)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⏱️ Sessão Extra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.modo.nome,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.modo.algoritmo,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.modo.descricao,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.9),
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCaracteristicas() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: widget.modo.caracteristicas.map((caracteristica) {
        final isHighlight = caracteristica == 'Recomendado' ||
            caracteristica == 'Algoritmo inteligente';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlight
                ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: isHighlight
                ? Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5))
                : null,
          ),
          child: Text(
            caracteristica,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight
                  ? const Color(0xFFFFD700)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(bool isSelected) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ref.read(modoProvider.notifier).selecionarModo(widget.modo);
          widget.onTap?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(widget.modo.corPrimariaInt),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: isSelected ? 8 : 4,
          shadowColor: Color(widget.modo.corPrimariaInt).withValues(alpha: 0.4),
        ),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Text(
            widget.modo.botaoTexto,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _buildGradient(bool isSelected) {
    final baseColor = Color(widget.modo.corPrimariaInt);

    if (isSelected) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withValues(alpha: 0.3),
          baseColor.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withValues(alpha: 0.15),
        baseColor.withValues(alpha: 0.08),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
