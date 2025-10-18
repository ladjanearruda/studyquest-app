// lib/features/avatar/screens/avatar_selection_screen.dart - V6.9.3
// ✅ CORRIGIDO: Borda verde quando selecionado (consistente com app)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/avatar.dart';
import '../../../core/models/user_profile.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../providers/avatar_provider.dart';

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

  AvatarType? _selectedType;
  AvatarGender? _selectedGender;
  bool _isAnimatingSelection = false;
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
    _setupAnimations();
    _startAnimations();
  }

  void _initializeUserProfile() {
    _userProfile = UserProfile(
      id: 'user_123',
      name: 'Explorador',
      email: 'user@example.com',
      educationLevel: EducationLevel.medio2,
      primaryGoal: StudyGoal.enemPrep,
      preferredTrail: ProfessionalTrail.cienciasNatureza,
      dailyStudyMinutes: 60,
      difficulties: ['matematica'],
      totalXP: 0,
      currentLevel: 1,
      subjectProgress: {},
    );
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _selectedController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    _cardAnimations = List.generate(4, (index) {
      final startInterval = (index * 0.15).clamp(0.0, 0.6);
      final endInterval = (startInterval + 0.4).clamp(0.4, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        ),
      );
    });
    _selectedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectedController, curve: Curves.elasticOut),
    );
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

  void _selectAvatar(AvatarType type, AvatarGender gender) async {
    if (_isAnimatingSelection) return;
    setState(() {
      _selectedType = type;
      _selectedGender = gender;
      _isAnimatingSelection = true;
    });
    ref.read(avatarProvider(_userProfile).notifier).selectAvatar(type, gender);
    await _selectedController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isAnimatingSelection = false);
  }

  void _confirmSelection() {
    if (_selectedType == null || _selectedGender == null || !mounted) return;
    ref.read(onboardingProvider.notifier).update((state) => state.copyWith(
          selectedAvatarType: _selectedType,
          selectedAvatarGender: _selectedGender,
        ));
    if (mounted) context.go('/modo-selection');
  }

  @override
  Widget build(BuildContext context) {
    final avatarsGrouped = ref.watch(avatarsGroupedByTypeProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                    _buildAvatarGrid(avatarsGrouped),
                    const SizedBox(height: 24),
                    _buildSelectedAvatarPreview(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
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
              Text('Escolha seu Avatar',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700]!)),
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
                      colors: [Colors.green[400]!, Colors.green[600]!]),
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
      builder: (context, child) => Transform.scale(
        scale: 0.8 + (0.2 * _heroAnimation.value),
        child: Opacity(
          opacity: _heroAnimation.value,
          child: Column(
            children: [
              Text('🎭', style: TextStyle(fontSize: 50 * _heroAnimation.value)),
              const SizedBox(height: 16),
              const Text('Escolha seu Companheiro\nde Aventura!',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                  'Cada avatar tem características únicas.\nEscolha o tipo e gênero que mais combina com você!',
                  style:
                      TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid(Map<AvatarType, List<Avatar>> avatarsGrouped) {
    return Column(
      children: AvatarType.values.asMap().entries.map((entry) {
        final index = entry.key;
        final type = entry.value;
        final avatars = avatarsGrouped[type]!;
        return AnimatedBuilder(
          animation: _cardAnimations[index],
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 40 * (1 - _cardAnimations[index].value)),
            child: Opacity(
              opacity: _cardAnimations[index].value,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildTypeSection(type, avatars),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSection(AvatarType type, List<Avatar> avatars) {
    final typeInfo = _getTypeInfo(type);
    final recommendedType =
        ref.watch(avatarProvider(_userProfile)).recommendedAvatarType;
    final isRecommended = type == recommendedType;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isRecommended
                ? typeInfo['color'].withOpacity(0.3)
                : Colors.grey.shade200,
            width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeInfo['color'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeInfo['icon'], color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(typeInfo['title'],
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32))),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeInfo['color'],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('RECOMENDADO',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    Text(typeInfo['subtitle'],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: avatars.map((avatar) {
              final isSelected = _selectedType == avatar.type &&
                  _selectedGender == avatar.gender;
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: avatar == avatars.last ? 0 : 8),
                  child: _buildAvatarCard(avatar, isSelected),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ✅ CORRIGIDO: Borda verde quando selecionado
  Widget _buildAvatarCard(Avatar avatar, bool isSelected) {
    final primaryColor = Color(Avatar.hexToColor(avatar.primaryColor));
    final onboardingData = ref.watch(onboardingProvider);
    final userName = onboardingData.name ?? 'Usuário';

    return GestureDetector(
      onTap: () => _selectAvatar(avatar.type, avatar.gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
                  Colors
                      .green[100]!, // ✅ MUDANÇA: Verde ao invés de primaryColor
                  Colors.green[50]!,
                ])
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? Colors
                      .green[600]! // ✅ MUDANÇA: Verde ao invés de primaryColor
                  : Colors.grey.shade200,
              width: isSelected ? 3 : 1),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.green.withOpacity(0.4) // ✅ MUDANÇA: Verde
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 5,
              offset: Offset(0, isSelected ? 6 : 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                // ✅ CORRIGIDO: Container duplo para sobrepor borda da imagem
                Container(
                  width: isSelected ? 130 : 120,
                  height: isSelected ? 130 : 120,
                  padding: const EdgeInsets.all(4), // Espaço para borda verde
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.green[600]! // Borda verde quando selecionado
                        : Colors
                            .transparent, // Sem borda quando não selecionado
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Fundo branco interno
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatar.getPath(AvatarEmotion.neutro),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              avatar.gender == AvatarGender.masculino
                                  ? '👦'
                                  : '👧',
                              style: const TextStyle(fontSize: 60),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: AnimatedBuilder(
                      animation: _selectedAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _selectedAnimation.value,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green[600]!, // ✅ MUDANÇA: Verde
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(avatar.getFullName(userName),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.green[800]! // ✅ MUDANÇA: Verde
                        : Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(avatar.characteristics.take(2).join(', '),
                style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.green[700]! // ✅ MUDANÇA: Verde
                        : Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAvatarPreview() {
    if (_selectedType == null || _selectedGender == null) {
      return const SizedBox.shrink();
    }

    final avatar = Avatar.fromTypeAndGender(_selectedType!, _selectedGender!);
    final primaryColor = Color(Avatar.hexToColor(avatar.primaryColor));
    final avatarTitle = _getAvatarTitle(_selectedType!, _selectedGender!);

    return AnimatedOpacity(
      opacity: _selectedType != null && _selectedGender != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.green[100]!, // ✅ MUDANÇA: Verde
            Colors.green[50]!,
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.green.withOpacity(0.3)), // ✅ MUDANÇA: Verde
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    child: Image.asset(
                      avatar.getPath(AvatarEmotion.neutro),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person,
                            color: primaryColor, size: 30);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green[600]!, // ✅ MUDANÇA: Verde
                              size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Você escolheu: $avatarTitle!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700]!, // ✅ MUDANÇA: Verde
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        avatar.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[600]!, // ✅ MUDANÇA: Verde
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getAvatarTitle(AvatarType type, AvatarGender gender) {
    final isFeminino = gender == AvatarGender.feminino;
    switch (type) {
      case AvatarType.academico:
        return isFeminino ? 'A Estudiosa' : 'O Estudioso';
      case AvatarType.competitivo:
        return isFeminino ? 'A Determinada' : 'O Determinado';
      case AvatarType.explorador:
        return isFeminino ? 'A Aventureira' : 'O Aventureiro';
      case AvatarType.equilibrado:
        return isFeminino ? 'A Sábia' : 'O Sábio';
    }
  }

  Widget _buildConfirmButton() {
    final hasSelection = _selectedType != null && _selectedGender != null;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
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
              shadowColor: Colors.green[600]!.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hasSelection ? 'Iniciar Aventura!' : 'Escolha seu avatar',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
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

  Map<String, dynamic> _getTypeInfo(AvatarType type) {
    switch (type) {
      case AvatarType.academico:
        return {
          'title': 'Acadêmicos',
          'subtitle': 'Focados no conhecimento',
          'color': const Color(0xFF2E7D55),
          'icon': Icons.school,
        };
      case AvatarType.competitivo:
        return {
          'title': 'Competitivos',
          'subtitle': 'Buscam a vitória',
          'color': const Color(0xFFE74C3C),
          'icon': Icons.emoji_events,
        };
      case AvatarType.explorador:
        return {
          'title': 'Exploradores',
          'subtitle': 'Descobrem novos caminhos',
          'color': const Color(0xFF3498DB),
          'icon': Icons.explore,
        };
      case AvatarType.equilibrado:
        return {
          'title': 'Equilibrados',
          'subtitle': 'Harmonia em tudo',
          'color': const Color(0xFF9B59B6),
          'icon': Icons.balance,
        };
    }
  }
}
