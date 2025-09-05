// lib/features/avatar/screens/avatar_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/avatar.dart';
// import '../../../core/models/user_profile.dart'; // Removido - não usado
import '../../onboarding/screens/onboarding_screen.dart';

class AvatarSelectionScreen extends ConsumerStatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  ConsumerState<AvatarSelectionScreen> createState() =>
      _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends ConsumerState<AvatarSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late AnimationController _selectedController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;
  late Animation<double> _selectedAnimation;

  AvatarType? _selectedAvatar;
  bool _isAnimatingSelection = false;

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

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _selectedController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOut,
    ));

    // Animações escalonadas para os 4 cards
    _cardAnimations = List.generate(4, (index) {
      final startInterval = (index * 0.15).clamp(0.0, 0.6);
      final endInterval = (startInterval + 0.4).clamp(0.4, 1.0);

      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cardsController,
        curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
      ));
    });

    _selectedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectedController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _heroController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    _selectedController.dispose();
    super.dispose();
  }

  void _selectAvatar(AvatarType avatarType) async {
    if (_isAnimatingSelection) return;

    setState(() {
      _selectedAvatar = avatarType;
      _isAnimatingSelection = true;
    });

    // Animação de seleção
    await _selectedController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _isAnimatingSelection = false;
    });
  }

  void _confirmSelection() {
    if (_selectedAvatar == null || !mounted) return;

    // Salvar avatar no onboardingProvider
    ref.read(onboardingProvider.notifier).update((state) {
      final newState = OnboardingData();
      newState.name = state.name;
      newState.educationLevel = state.educationLevel;
      newState.studyGoal = state.studyGoal;
      newState.interestArea = state.interestArea;
      newState.dreamUniversity = state.dreamUniversity;
      newState.studyTime = state.studyTime;
      newState.mainDifficulty = state.mainDifficulty;
      newState.studyStyle = state.studyStyle;
      newState.selectedAvatar = _selectedAvatar; // Salvar avatar selecionado
      return newState;
    });

    if (mounted) {
      context.go('/modo-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remover a linha onboarding não utilizada
    // final onboarding = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            _buildProgressHeader(),

            // Conteúdo Principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Hero Section
                    _buildHeroSection(),

                    const SizedBox(height: 32),

                    // Grid de Avatares
                    _buildAvatarGrid(),

                    const SizedBox(height: 24),

                    // Preview do Avatar Selecionado
                    _buildSelectedAvatarPreview(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Botão de Confirmação
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.go('/onboarding/8'),
                icon: Icon(Icons.arrow_back_ios,
                    color: Colors.green[700]!, size: 20),
              ),
              Text(
                'Escolha seu Avatar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700]!,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green[100]!,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _heroAnimation.value),
          child: Opacity(
            opacity: _heroAnimation.value,
            child: Column(
              children: [
                Text('🎭',
                    style: TextStyle(fontSize: 50 * _heroAnimation.value)),
                const SizedBox(height: 16),
                const Text(
                  'Escolha seu Companheiro\nde Aventura!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cada avatar tem características únicas que combinam com seu perfil! 🌟',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarGrid() {
    final avatars = AvatarType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0, // ✅ Mudado de 0.85 para 1.0 (mais compacto)
        mainAxisSpacing: 12, // ✅ Reduzido de 16 para 12
        crossAxisSpacing: 12, // ✅ Reduzido de 16 para 12
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatarType = avatars[index];
        final avatarData = Avatar.fromType(avatarType);
        final isSelected = _selectedAvatar == avatarType;

        return AnimatedBuilder(
          animation: _cardAnimations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - _cardAnimations[index].value)),
              child: Opacity(
                opacity: _cardAnimations[index].value,
                child: _buildAvatarCard(avatarData, isSelected),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarCard(Avatar avatar, bool isSelected) {
    final primaryColor = Color(Avatar.hexToColor(avatar.primaryColor));

    return GestureDetector(
      onTap: () => _selectAvatar(avatar.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.15),
                    primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 15 : 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar Placeholder (será substituído pelas imagens do Programador 2)
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🎭', // Placeholder - será substituído pela imagem real
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: AnimatedBuilder(
                      animation: _selectedAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _selectedAnimation.value,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Nome do Avatar
            Text(
              avatar.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Descrição
            Text(
              avatar.description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.8)
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Características principais (2 primeiras)
            if (avatar.characteristics.length >= 2) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCharacteristicChip(
                    avatar.characteristics[0],
                    primaryColor,
                    isSelected,
                  ),
                  const SizedBox(width: 4),
                  _buildCharacteristicChip(
                    avatar.characteristics[1],
                    primaryColor,
                    isSelected,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicChip(
      String characteristic, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSelected ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        characteristic,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildSelectedAvatarPreview() {
    if (_selectedAvatar == null) return const SizedBox.shrink();

    final avatarData = Avatar.fromType(_selectedAvatar!);
    final primaryColor = Color(Avatar.hexToColor(avatarData.primaryColor));

    return AnimatedOpacity(
      opacity: _selectedAvatar != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withValues(alpha: 0.1),
              primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Você escolheu: ${avatarData.name}!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              avatarData.description,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: avatarData.characteristics.map((characteristic) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    characteristic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final hasSelection = _selectedAvatar != null;

    return Container(
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
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasSelection ? _confirmSelection : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasSelection ? Colors.green[600]! : Colors.grey[400]!,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: hasSelection ? 4 : 0,
              shadowColor: Colors.green[600]!.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hasSelection
                      ? 'Iniciar Aventura com ${Avatar.fromType(_selectedAvatar!).name}! 🚀'
                      : 'Escolha seu avatar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasSelection) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
