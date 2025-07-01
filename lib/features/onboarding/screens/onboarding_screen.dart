// studyquest_onboarding.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// === ENUMS E MODELS ===

enum EducationLevel {
  fundamental6,
  fundamental7,
  fundamental8,
  fundamental9,
  medio1,
  medio2,
  medio3,
  completed,
}

enum StudyGoal {
  improveGrades,
  enemPrep,
  specificUniversity,
  exploreAreas,
  undecided,
}

enum ProfessionalTrail {
  linguagens,
  cienciasNatureza,
  matematicaTecnologia,
  humanas,
  negocios,
  descobrindo,
}

class OnboardingData {
  String? name;
  EducationLevel? educationLevel;
  StudyGoal? studyGoal;
  ProfessionalTrail? interestArea;
  String? dreamUniversity;
  String? studyTime;
  String? mainDifficulty;
  String? studyStyle;
}

final onboardingProvider =
    StateProvider<OnboardingData>((ref) => OnboardingData());

// === CLASSES DE DADOS ===

class EducationLevelData {
  final EducationLevel level;
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  EducationLevelData({
    required this.level,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class StudyGoalData {
  final StudyGoal goal;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  StudyGoalData({
    required this.goal,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}

// === TELA BASE ===

class OnboardingScaffold extends StatelessWidget {
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool canGoBack;

  const OnboardingScaffold({
    super.key,
    required this.child,
    this.onNext,
    this.onBack,
    this.canGoBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canGoBack)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onBack ?? () => context.pop(),
                  child: const Text('Voltar'),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(child: child),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32)),
              child: const Text('Próximo'),
            ),
          ],
        ),
      ),
    );
  }
}

// Labels
String _getEducationLevelLabel(EducationLevel level) {
  switch (level) {
    case EducationLevel.fundamental6:
      return '6º ano';
    case EducationLevel.fundamental7:
      return '7º ano';
    case EducationLevel.fundamental8:
      return '8º ano';
    case EducationLevel.fundamental9:
      return '9º ano';
    case EducationLevel.medio1:
      return '1º ano EM';
    case EducationLevel.medio2:
      return '2º ano EM';
    case EducationLevel.medio3:
      return '3º ano EM';
    case EducationLevel.completed:
      return 'Já terminei o EM';
  }
}

String _getStudyGoalLabel(StudyGoal goal) {
  switch (goal) {
    case StudyGoal.improveGrades:
      return 'Melhorar minhas notas na escola';
    case StudyGoal.enemPrep:
      return 'Me preparar para o ENEM';
    case StudyGoal.specificUniversity:
      return 'Entrar numa universidade específica';
    case StudyGoal.exploreAreas:
      return 'Explorar áreas de interesse';
    case StudyGoal.undecided:
      return 'Ainda não tenho certeza';
  }
}

String _getProfessionalTrailLabel(ProfessionalTrail trail) {
  switch (trail) {
    case ProfessionalTrail.linguagens:
      return '📚 Linguagens e Códigos';
    case ProfessionalTrail.cienciasNatureza:
      return '🧪 Ciências da Natureza';
    case ProfessionalTrail.matematicaTecnologia:
      return '📊 Matemática e Tecnologias';
    case ProfessionalTrail.humanas:
      return '🌍 Ciências Humanas';
    case ProfessionalTrail.negocios:
      return '💼 Negócios e Gestão';
    case ProfessionalTrail.descobrindo:
      return '🤔 Ainda estou descobrindo';
  }
}
// === TELAS ===

// ===== TELA 0 NOME PREMIUM =====

class Tela0Nome extends ConsumerStatefulWidget {
  const Tela0Nome({super.key});

  @override
  ConsumerState<Tela0Nome> createState() => _Tela0NomeState();
}

class _Tela0NomeState extends ConsumerState<Tela0Nome>
    with TickerProviderStateMixin {
  late TextEditingController nameController;
  late AnimationController _avatarController;
  late AnimationController _inputController;
  late Animation<double> _avatarAnimation;
  late Animation<double> _inputAnimation;

  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingProvider);
    nameController = TextEditingController(text: onboarding.name ?? '');

    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _inputController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _avatarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeOut),
    );

    _inputAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _avatarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _inputController.forward();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    _avatarController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final hasName = onboarding.name?.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      Text(
                        'Passo 1 de 8',
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        width:
                            MediaQuery.of(context).size.width * (1 / 8) * 0.86,
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _avatarAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * _avatarAnimation.value),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green[300]!,
                                    Colors.green[500]!
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green[200]!
                                        .withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person,
                                  size: 60, color: Colors.white),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        '👋 Olá, futuro explorador!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Como você gostaria de ser chamado\nnas suas aventuras educacionais?',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      AnimatedBuilder(
                        animation: _inputAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 15 * (1 - _inputAnimation.value)),
                            child: Opacity(
                              opacity: _inputAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green[100]!
                                          .withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: nameController,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: 'Digite seu nome ou apelido',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[400]!, fontSize: 16),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100]!,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.edit,
                                          color: Colors.green[600]!, size: 20),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: Colors.green[400]!, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                  ),
                                  onChanged: (value) {
                                    ref
                                        .read(onboardingProvider.notifier)
                                        .update((state) {
                                      final newState = OnboardingData();
                                      newState.name = value.trim().isEmpty
                                          ? null
                                          : value.trim();
                                      newState.educationLevel =
                                          state.educationLevel;
                                      newState.studyGoal = state.studyGoal;
                                      newState.interestArea =
                                          state.interestArea;
                                      newState.dreamUniversity =
                                          state.dreamUniversity;
                                      newState.studyTime = state.studyTime;
                                      newState.mainDifficulty =
                                          state.mainDifficulty;
                                      newState.studyStyle = state.studyStyle;
                                      return newState;
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      AnimatedOpacity(
                        opacity: hasName ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green[50]!,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.green[200]!, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green[600]!, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hasName
                                      ? 'Perfeito, ${onboarding.name}! Pronto para a aventura?'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.green[700]!,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (hasName)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.green[100]!, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.green[600]!, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Próximo: Descobrir seu nível!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasName ? () => context.go('/onboarding/1') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasName ? Colors.green[600]! : Colors.grey[400]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: hasName ? 4 : 0,
                    shadowColor: Colors.green[600]!.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasName ? 'Vamos começar! 🚀' : 'Digite seu nome',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasName ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ===== TELA 1 NÍVEL EDUCACIONAL PREMIUM 4x2 =====

class Tela1NivelEducacional extends ConsumerStatefulWidget {
  const Tela1NivelEducacional({super.key});

  @override
  ConsumerState<Tela1NivelEducacional> createState() =>
      _Tela1NivelEducacionalState();
}

class _Tela1NivelEducacionalState extends ConsumerState<Tela1NivelEducacional>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _gridController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;

  final List<EducationLevelData> _levels = [
    EducationLevelData(
        level: EducationLevel.fundamental6,
        emoji: '📚',
        title: '6º ano',
        subtitle: 'Fundamental II',
        color: Colors.blue),
    EducationLevelData(
        level: EducationLevel.fundamental7,
        emoji: '📖',
        title: '7º ano',
        subtitle: 'Fundamental II',
        color: Colors.indigo),
    EducationLevelData(
        level: EducationLevel.fundamental8,
        emoji: '✏️',
        title: '8º ano',
        subtitle: 'Fundamental II',
        color: Colors.purple),
    EducationLevelData(
        level: EducationLevel.fundamental9,
        emoji: '📝',
        title: '9º ano',
        subtitle: 'Última etapa!',
        color: Colors.deepPurple),
    EducationLevelData(
        level: EducationLevel.medio1,
        emoji: '🎓',
        title: '1º ano EM',
        subtitle: 'Ensino Médio',
        color: Colors.orange),
    EducationLevelData(
        level: EducationLevel.medio2,
        emoji: '🚀',
        title: '2º ano EM',
        subtitle: 'Ensino Médio',
        color: Colors.deepOrange),
    EducationLevelData(
        level: EducationLevel.medio3,
        emoji: '🎯',
        title: '3º ano EM',
        subtitle: 'Reta final!',
        color: Colors.red),
    EducationLevelData(
        level: EducationLevel.completed,
        emoji: '🎉',
        title: 'Formado(a)',
        subtitle: 'Já terminei!',
        color: Colors.green),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _gridController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    _cardAnimations = List.generate(_levels.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _gridController, curve: Curves.easeOut),
      );
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _heroController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _gridController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final hasSelection = onboarding.educationLevel != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/0'),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.green[700]!, size: 20),
                      ),
                      Text(
                        'Passo 2 de 8',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700]!),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.green[100]!,
                        borderRadius: BorderRadius.circular(4)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        width:
                            MediaQuery.of(context).size.width * (2 / 8) * 0.86,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.green[400]!, Colors.green[600]!]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.95 + (0.05 * _heroAnimation.value),
                          child: Opacity(
                            opacity: _heroAnimation.value,
                            child: Column(
                              children: [
                                Text('🎓',
                                    style: TextStyle(
                                        fontSize: 40 * _heroAnimation.value)),
                                const SizedBox(height: 8),
                                const Text(
                                  'Em que ano você está?',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32)),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Vamos personalizar sua jornada! 📚',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      height: 1.2),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ✅ GRID 4x2 (4 COLUNAS, 2 LINHAS) - A ESTRELA!
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 COLUNAS!
                        childAspectRatio: 0.9,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _levels.length,
                      itemBuilder: (context, index) {
                        final levelData = _levels[index];
                        final isSelected =
                            onboarding.educationLevel == levelData.level;

                        return AnimatedBuilder(
                          animation: _cardAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  0, 20 * (1 - _cardAnimations[index].value)),
                              child: Opacity(
                                opacity: _cardAnimations[index].value,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? levelData.color.withValues(alpha: 0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? levelData.color
                                          : Colors.grey[200]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? levelData.color
                                                .withValues(alpha: 0.2)
                                            : Colors.black
                                                .withValues(alpha: 0.03),
                                        blurRadius: isSelected ? 8 : 4,
                                        offset: Offset(0, isSelected ? 3 : 1),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        ref
                                            .read(onboardingProvider.notifier)
                                            .update((state) {
                                          final newState = OnboardingData();
                                          newState.name = state.name;
                                          newState.educationLevel =
                                              levelData.level;
                                          newState.studyGoal = state.studyGoal;
                                          newState.interestArea =
                                              state.interestArea;
                                          newState.dreamUniversity =
                                              state.dreamUniversity;
                                          newState.studyTime = state.studyTime;
                                          newState.mainDifficulty =
                                              state.mainDifficulty;
                                          newState.studyStyle =
                                              state.studyStyle;
                                          return newState;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  width: isSelected ? 42 : 38,
                                                  height: isSelected ? 42 : 38,
                                                  decoration: BoxDecoration(
                                                    color: levelData.color
                                                        .withValues(
                                                            alpha: 0.15),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child:
                                                        AnimatedDefaultTextStyle(
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      style: TextStyle(
                                                          fontSize: isSelected
                                                              ? 20
                                                              : 18),
                                                      child:
                                                          Text(levelData.emoji),
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Positioned(
                                                    top: -2,
                                                    right: -2,
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      width: 18,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color: levelData.color,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2),
                                                      ),
                                                      child: const Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 12),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              levelData.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? levelData.color
                                                    : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              levelData.subtitle,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? levelData.color
                                                        .withValues(alpha: 0.8)
                                                    : Colors.grey[600]!,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    AnimatedOpacity(
                      opacity: hasSelection ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[50]!,
                              Colors.green[100]!.withValues(alpha: 0.3)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.green[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.green[600]!,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.school,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hasSelection
                                    ? 'Perfeito! Agora vamos descobrir seus objetivos! 🎯'
                                    : '',
                                style: TextStyle(
                                  color: Colors.green[700]!,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ✅ BOTÃO ULTRA-COMPACTO para mini-mini
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: ElevatedButton(
                onPressed:
                    hasSelection ? () => context.go('/onboarding/2') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: hasSelection ? 3 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasSelection
                          ? 'Vamos aos objetivos! 🎯'
                          : 'Selecione seu nível',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ===== TELA 2 OBJETIVOS PREMIUM =====

class Tela2ObjetivoPrincipal extends ConsumerStatefulWidget {
  const Tela2ObjetivoPrincipal({super.key});

  @override
  ConsumerState<Tela2ObjetivoPrincipal> createState() =>
      _Tela2ObjetivoPrincipalState();
}

class _Tela2ObjetivoPrincipalState extends ConsumerState<Tela2ObjetivoPrincipal>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;

  final List<StudyGoalData> _goals = [
    StudyGoalData(
      goal: StudyGoal.improveGrades,
      emoji: '📈',
      title: 'Melhorar Notas',
      subtitle: 'Subir de nível na escola',
      color: Colors.blue,
      description: 'Quero tirar notas melhores e me destacar nas matérias',
    ),
    StudyGoalData(
      goal: StudyGoal.enemPrep,
      emoji: '🎯',
      title: 'Preparação ENEM',
      subtitle: 'Rumo à aprovação',
      color: Colors.orange,
      description: 'Meu foco é mandar bem no ENEM e conquistar minha vaga',
    ),
    StudyGoalData(
      goal: StudyGoal.specificUniversity,
      emoji: '🏛️',
      title: 'Universidade Específica',
      subtitle: 'Sonho grande definido',
      color: Colors.purple,
      description: 'Tenho uma universidade dos sonhos e vou conquistá-la',
    ),
    StudyGoalData(
      goal: StudyGoal.exploreAreas,
      emoji: '🧭',
      title: 'Explorar Áreas',
      subtitle: 'Descobrir paixões',
      color: Colors.teal,
      description:
          'Quero conhecer diferentes áreas e descobrir o que me motiva',
    ),
    StudyGoalData(
      goal: StudyGoal.undecided,
      emoji: '🤔',
      title: 'Ainda Decidindo',
      subtitle: 'Vamos descobrir juntos',
      color: Colors.grey,
      description: 'Não tenho certeza ainda, mas quero evoluir estudando',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _cardsController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    _cardAnimations = List.generate(_goals.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
      );
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _heroController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final hasSelection = onboarding.studyGoal != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/1'),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.green[700]!, size: 20),
                      ),
                      Text(
                        'Passo 3 de 8',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700]!),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.green[100]!,
                        borderRadius: BorderRadius.circular(4)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        width:
                            MediaQuery.of(context).size.width * (3 / 8) * 0.86,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.green[400]!, Colors.green[600]!]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _heroAnimation.value),
                          child: Opacity(
                            opacity: _heroAnimation.value,
                            child: Column(
                              children: [
                                Text('🌟',
                                    style: TextStyle(
                                        fontSize: 60 * _heroAnimation.value)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Qual seu sonho?',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32)),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Todo grande explorador tem um objetivo.\nVamos descobrir o seu! 🚀',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goalData = _goals[index];
                        final isSelected =
                            onboarding.studyGoal == goalData.goal;

                        return AnimatedBuilder(
                          animation: _cardAnimations[index],
                          builder: (context, child) {
                            final adjustedValue =
                                _cardAnimations[index].value; // SEM DELAY

                            return Transform.translate(
                              offset: Offset(50 * (1 - adjustedValue), 0),
                              child: Opacity(
                                opacity: adjustedValue, // OPACIDADE NORMAL
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? goalData.color
                                              .withValues(alpha: 0.15)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? goalData.color
                                            : Colors.grey[200]!,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? goalData.color
                                                  .withValues(alpha: 0.3)
                                              : Colors.black
                                                  .withValues(alpha: 0.05),
                                          blurRadius: isSelected ? 20 : 8,
                                          offset: Offset(0, isSelected ? 8 : 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          ref
                                              .read(onboardingProvider.notifier)
                                              .update((state) {
                                            final newState = OnboardingData();
                                            newState.name = state.name;
                                            newState.educationLevel =
                                                state.educationLevel;
                                            newState.studyGoal = goalData.goal;
                                            newState.interestArea =
                                                state.interestArea;
                                            newState.dreamUniversity =
                                                state.dreamUniversity;
                                            newState.studyTime =
                                                state.studyTime;
                                            newState.mainDifficulty =
                                                state.mainDifficulty;
                                            newState.studyStyle =
                                                state.studyStyle;
                                            return newState;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: goalData.color
                                                          .withValues(
                                                              alpha: 0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          goalData.emoji,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      24)),
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Positioned(
                                                      top: -2,
                                                      right: -2,
                                                      child: Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: goalData.color,
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2),
                                                        ),
                                                        child: const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 14),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      goalData.title,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? goalData.color
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      goalData.subtitle,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: goalData.color
                                                            .withValues(
                                                                alpha: 0.7),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      goalData.description,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Colors.grey[600]!,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Icon(
                                                  isSelected
                                                      ? Icons
                                                          .radio_button_checked
                                                      : Icons
                                                          .radio_button_unchecked,
                                                  color: isSelected
                                                      ? goalData.color
                                                      : Colors.grey[400]!,
                                                  size: 24,
                                                ),
                                              ),
                                            ],
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
                      },
                    ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      opacity: hasSelection ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[50]!,
                              Colors.green[100]!.withValues(alpha: 0.3)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.green[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.green[600]!,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.celebration,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hasSelection
                                    ? 'Excelente escolha! Seu sonho vai virar realidade! 🌟'
                                    : '',
                                style: TextStyle(
                                  color: Colors.green[700]!,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Container(
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      hasSelection ? () => context.go('/onboarding/3') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: hasSelection ? 6 : 0,
                    shadowColor: Colors.green[600]!.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasSelection
                            ? 'Rumo ao sonho! 🚀'
                            : 'Escolha seu objetivo',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasSelection ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ===== TELAS 3-7 RESTANTES =====

class Tela3AreaInteresse extends ConsumerWidget {
  const Tela3AreaInteresse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    return OnboardingScaffold(
      onBack: () => context.go('/onboarding/2'),
      onNext: onboarding.interestArea != null
          ? () => context.go('/onboarding/4')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Que área mais desperta seu interesse?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Escolha a área que mais combina com você:',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ProfessionalTrail.values.map((area) {
                  final label = _getProfessionalTrailLabel(area);
                  final isSelected = onboarding.interestArea == area;

                  return InkWell(
                    onTap: () {
                      ref.read(onboardingProvider.notifier).update((state) {
                        final newState = OnboardingData();
                        newState.name = state.name;
                        newState.educationLevel = state.educationLevel;
                        newState.studyGoal = state.studyGoal;
                        newState.interestArea = area;
                        newState.dreamUniversity = state.dreamUniversity;
                        newState.studyTime = state.studyTime;
                        newState.mainDifficulty = state.mainDifficulty;
                        newState.studyStyle = state.studyStyle;
                        return newState;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF2E7D32) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Tela4UniversidadeSonho extends ConsumerWidget {
  const Tela4UniversidadeSonho({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final universidades = [
      'USP',
      'UNICAMP',
      'UFRJ',
      'UnB',
      'UFMG',
      'UFRGS',
      'UFPE',
      'UFBA',
      'UFSC',
      'UFC',
      'UFPR',
      'UFAM',
      'ITA',
      'IME',
      'UERJ',
      'PUC-Rio',
      'Ainda não decidi',
      'Prefiro não informar',
      'Quero estudar no exterior',
      'Faculdade da minha região'
    ];

    return OnboardingScaffold(
      onBack: () => context.go('/onboarding/3'),
      onNext: onboarding.dreamUniversity != null
          ? () => context.go('/onboarding/5')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tem alguma universidade dos sonhos?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Escolha a universidade que você gostaria de estudar:',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: universidades
                    .map((uni) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: RadioListTile<String>(
                            title:
                                Text(uni, style: const TextStyle(fontSize: 16)),
                            value: uni,
                            groupValue: onboarding.dreamUniversity,
                            activeColor: const Color(0xFF2E7D32),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            onChanged: (value) {
                              ref
                                  .read(onboardingProvider.notifier)
                                  .update((state) {
                                final newState = OnboardingData();
                                newState.name = state.name;
                                newState.educationLevel = state.educationLevel;
                                newState.studyGoal = state.studyGoal;
                                newState.interestArea = state.interestArea;
                                newState.dreamUniversity = value;
                                newState.studyTime = state.studyTime;
                                newState.mainDifficulty = state.mainDifficulty;
                                newState.studyStyle = state.studyStyle;
                                return newState;
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Tela5TempoEstudo extends ConsumerWidget {
  const Tela5TempoEstudo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final opcoes = [
      '15-30 minutos',
      '30-60 minutos',
      '1-2 horas',
      'Mais de 2 horas'
    ];

    return OnboardingScaffold(
      onBack: () => context.go('/onboarding/4'),
      onNext: onboarding.studyTime != null
          ? () => context.go('/onboarding/6')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quanto tempo pode estudar por dia?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...opcoes.map((opt) => RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: onboarding.studyTime,
                onChanged: (value) {
                  ref.read(onboardingProvider.notifier).update((state) {
                    final newState = OnboardingData();
                    newState.name = state.name;
                    newState.educationLevel = state.educationLevel;
                    newState.studyGoal = state.studyGoal;
                    newState.interestArea = state.interestArea;
                    newState.dreamUniversity = state.dreamUniversity;
                    newState.studyTime = value;
                    newState.mainDifficulty = state.mainDifficulty;
                    newState.studyStyle = state.studyStyle;
                    return newState;
                  });
                },
              )),
        ],
      ),
    );
  }
}

class Tela6Dificuldade extends ConsumerWidget {
  const Tela6Dificuldade({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final dificuldades = [
      'Matemática',
      'Português e Literatura',
      'Física',
      'Química',
      'Biologia',
      'História',
      'Geografia',
      'Inglês',
      'Interpretação de texto',
      'Resolução de problemas',
      'Memorização de conteúdo',
      'Foco e concentração',
      'Motivação para estudar',
      'Organização dos estudos',
      'Ansiedade em provas'
    ];

    return OnboardingScaffold(
      onBack: () => context.go('/onboarding/5'),
      onNext: onboarding.mainDifficulty != null
          ? () => context.go('/onboarding/7')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Qual sua maior dificuldade hoje?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Escolha o que mais te desafia nos estudos:',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: dificuldades
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: RadioListTile<String>(
                            title:
                                Text(d, style: const TextStyle(fontSize: 16)),
                            value: d,
                            groupValue: onboarding.mainDifficulty,
                            activeColor: const Color(0xFF2E7D32),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            onChanged: (value) {
                              ref
                                  .read(onboardingProvider.notifier)
                                  .update((state) {
                                final newState = OnboardingData();
                                newState.name = state.name;
                                newState.educationLevel = state.educationLevel;
                                newState.studyGoal = state.studyGoal;
                                newState.interestArea = state.interestArea;
                                newState.dreamUniversity =
                                    state.dreamUniversity;
                                newState.studyTime = state.studyTime;
                                newState.mainDifficulty = value;
                                newState.studyStyle = state.studyStyle;
                                return newState;
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Tela7EstiloEstudo extends ConsumerWidget {
  const Tela7EstiloEstudo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final estilos = [
      'Sozinho(a) e no meu ritmo',
      'Competindo com outros',
      'Em grupos de estudo',
      'Com metas e desafios'
    ];

    return OnboardingScaffold(
      onBack: () => context.go('/onboarding/6'),
      onNext: onboarding.studyStyle != null
          ? () => context.go('/onboarding/complete')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Como prefere estudar?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Escolha o estilo que mais combina com você:',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: estilos
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: RadioListTile<String>(
                          title: Text(e, style: const TextStyle(fontSize: 16)),
                          value: e,
                          groupValue: onboarding.studyStyle,
                          activeColor: const Color(0xFF2E7D32),
                          onChanged: (value) {
                            ref
                                .read(onboardingProvider.notifier)
                                .update((state) {
                              final newState = OnboardingData();
                              newState.name = state.name;
                              newState.educationLevel = state.educationLevel;
                              newState.studyGoal = state.studyGoal;
                              newState.interestArea = state.interestArea;
                              newState.dreamUniversity = state.dreamUniversity;
                              newState.studyTime = state.studyTime;
                              newState.mainDifficulty = state.mainDifficulty;
                              newState.studyStyle = value;
                              return newState;
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
// ===== TELAS FINAIS =====

class OnboardingComplete extends ConsumerWidget {
  const OnboardingComplete({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 100),
            const SizedBox(height: 20),
            Text(
              'Oi, ${onboarding.name}! 👋',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('Seu perfil foi criado com sucesso!',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seu perfil StudyQuest:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildProfileItem('Nível:',
                      _getEducationLevelLabel(onboarding.educationLevel!)),
                  _buildProfileItem(
                      'Objetivo:', _getStudyGoalLabel(onboarding.studyGoal!)),
                  _buildProfileItem('Área de interesse:',
                      _getProfessionalTrailLabel(onboarding.interestArea!)),
                  _buildProfileItem('Universidade:',
                      onboarding.dreamUniversity ?? 'Não informado'),
                  _buildProfileItem('Tempo de estudo:',
                      onboarding.studyTime ?? 'Não informado'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/trail/forest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Começar minha aventura! 🌳',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class ForestTrailScreen extends StatelessWidget {
  const ForestTrailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Floresta Amazônica'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.forest, size: 60, color: Color(0xFF2E7D32)),
                  SizedBox(height: 12),
                  Text('Sobrevivência na Floresta',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text(
                      'Você precisa sobreviver na Amazônia resolvendo desafios matemáticos!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seus recursos vitais:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  _ResourceBar(label: '💧 Água', percentage: 100),
                  SizedBox(height: 8),
                  _ResourceBar(label: '🔥 Energia', percentage: 100),
                  SizedBox(height: 8),
                  _ResourceBar(label: '❤️ Saúde', percentage: 100),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Primeira questão em desenvolvimento! 🚧'),
                        backgroundColor: Color(0xFF2E7D32)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Começar Aventura! 🌳',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResourceBar extends StatelessWidget {
  final String label;
  final double percentage;

  const _ResourceBar({required this.label, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${percentage.toInt()}%',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
              color: Colors.grey[300]!, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(4))),
          ),
        ),
      ],
    );
  }
}
