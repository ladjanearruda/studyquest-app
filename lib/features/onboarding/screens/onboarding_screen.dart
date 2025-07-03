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
// ===== TELA 1 NÍVEL EDUCACIONAL - VERSÃO LIMPA SEM ERROS =====
// ===== TELA 1 NÍVEL EDUCACIONAL - VERSÃO LIMPA SEM ERROS =====

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
            // PROGRESS HEADER
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
                      SizedBox(width: 48),
                    ],
                  ),
                  SizedBox(height: 12),
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
                    SizedBox(height: 8),

                    // HERO SECTION
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
                                        fontSize: 50 * _heroAnimation.value)),
                                SizedBox(height: 12),
                                Text(
                                  'Em que ano você está?',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32)),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Vamos personalizar sua jornada! 📚',
                                  style: TextStyle(
                                      fontSize: 16,
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

                    SizedBox(height: 20),

                    // GRID 4x2 SEM LIMITAÇÃO DE ALTURA
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.2, // Cards proporcionais
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
                                        padding: EdgeInsets.all(12),
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
                                                      child: Icon(Icons.check,
                                                          color: Colors.white,
                                                          size: 12),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              levelData.subtitle,
                                              style: TextStyle(
                                                fontSize: 13,
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

                    SizedBox(height: 16),

                    // FEEDBACK VISUAL
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
                              child: Icon(Icons.school,
                                  color: Colors.white, size: 20),
                            ),
                            SizedBox(width: 12),
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

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // BOTÃO
            Container(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed:
                    hasSelection ? () => context.go('/onboarding/2') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16),
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
                                                        fontSize: 20,
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
                                                        fontSize: 16,
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
            // ===== CORREÇÃO BOTÃO TELA 2 - SUBSTITUIR O CONTAINER FINAL =====

// PROCURE POR: "Container(" antes do ElevatedButton da Tela 2
// SUBSTITUA TODO O Container do botão por este código:

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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: hasSelection ? 4 : 0,
                    shadowColor: Colors.green[600]!.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasSelection
                            ? 'Rumo ao sonho! 🚀'
                            : 'Escolha seu objetivo',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasSelection ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward, size: 18),
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
// ===== TELA 3 ÁREA DE INTERESSE - PADRÃO CORRETO =====
// SUBSTITUA A CLASSE Tela3AreaInteresse EXISTENTE

class Tela3AreaInteresse extends ConsumerStatefulWidget {
  const Tela3AreaInteresse({super.key});

  @override
  ConsumerState<Tela3AreaInteresse> createState() => _Tela3AreaInteresseState();
}

class _Tela3AreaInteresseState extends ConsumerState<Tela3AreaInteresse>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _buttonsController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _buttonAnimations;

  final List<ProfessionalTrailData> _areas = [
    ProfessionalTrailData(
      trail: ProfessionalTrail.linguagens,
      emoji: '📚',
      title: 'Linguagens',
      subtitle: 'Códigos & Textos',
      description: 'Português, Literatura, Inglês e comunicação',
      color: Colors.blue,
    ),
    ProfessionalTrailData(
      trail: ProfessionalTrail.cienciasNatureza,
      emoji: '🧪',
      title: 'Ciências',
      subtitle: 'Natureza & Vida',
      description: 'Biologia, Química, Física e meio ambiente',
      color: Colors.green,
    ),
    ProfessionalTrailData(
      trail: ProfessionalTrail.matematicaTecnologia,
      emoji: '📊',
      title: 'Matemática',
      subtitle: 'Números & Tech',
      description: 'Cálculos, programação e tecnologia',
      color: Colors.orange,
    ),
    ProfessionalTrailData(
      trail: ProfessionalTrail.humanas,
      emoji: '🌍',
      title: 'Humanas',
      subtitle: 'Sociedade & Cultura',
      description: 'História, Geografia, Filosofia e sociedade',
      color: Colors.purple,
    ),
    ProfessionalTrailData(
      trail: ProfessionalTrail.negocios,
      emoji: '💼',
      title: 'Negócios',
      subtitle: 'Gestão & Economia',
      description: 'Administração, economia e empreendedorismo',
      color: Colors.teal,
    ),
    ProfessionalTrailData(
      trail: ProfessionalTrail.descobrindo,
      emoji: '🤔',
      title: 'Descobrindo',
      subtitle: 'Explorar juntos',
      description: 'Ainda não sei, quero conhecer tudo um pouco',
      color: Colors.grey,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _buttonsController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    _buttonAnimations = List.generate(_areas.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _buttonsController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    // Iniciar animações
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _buttonsController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final hasSelection = onboarding.interestArea != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER - CORRIGIDO SEM BARRA EXTRA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/2'),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.green[700]!, size: 20),
                      ),
                      Text(
                        'Passo 4 de 8',
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
                            MediaQuery.of(context).size.width * (4 / 8) * 0.86,
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

            // ✅ CONTEÚDO PRINCIPAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ✅ HERO SECTION ANIMADO
                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _heroAnimation.value),
                          child: Opacity(
                            opacity: _heroAnimation.value,
                            child: Column(
                              children: [
                                Text('🎯',
                                    style: TextStyle(
                                        fontSize: 60 * _heroAnimation.value)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Qual área desperta\nseu interesse?',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Escolha sua paixão acadêmica! 🌟',
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

                    // ✅ BOTÕES EM LINHA HORIZONTAL PREMIUM
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _areas.length,
                      itemBuilder: (context, index) {
                        final areaData = _areas[index];
                        final isSelected =
                            onboarding.interestArea == areaData.trail;

                        return AnimatedBuilder(
                          animation: _buttonAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  50 * (1 - _buttonAnimations[index].value), 0),
                              child: Opacity(
                                opacity: _buttonAnimations[index].value,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                areaData.color
                                                    .withValues(alpha: 0.1),
                                                areaData.color
                                                    .withValues(alpha: 0.05),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? areaData.color
                                            : Colors.grey.shade200,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? areaData.color
                                                  .withValues(alpha: 0.25)
                                              : Colors.black
                                                  .withValues(alpha: 0.03),
                                          blurRadius: isSelected ? 12 : 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref
                                              .read(onboardingProvider.notifier)
                                              .update((state) {
                                            final newState = OnboardingData();
                                            newState.name = state.name;
                                            newState.educationLevel =
                                                state.educationLevel;
                                            newState.studyGoal =
                                                state.studyGoal;
                                            newState.interestArea =
                                                areaData.trail;
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
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              // Emoji + Check Icon
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      color: areaData.color
                                                          .withValues(
                                                              alpha: 0.15),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          areaData.emoji,
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
                                                      child: AnimatedScale(
                                                        scale: isSelected
                                                            ? 1.0
                                                            : 0.0,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        child: Container(
                                                          width: 24,
                                                          height: 24,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                areaData.color,
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2),
                                                          ),
                                                          child: const Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white,
                                                              size: 14),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),

                                              const SizedBox(width: 16),

                                              // Texto principal
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      areaData.title,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? areaData.color
                                                            : const Color(
                                                                0xFF2E7D32),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      areaData.subtitle,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? areaData.color
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : Colors
                                                                .grey.shade600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      areaData.description,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors
                                                            .grey.shade600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Radio button - CONSISTENTE COM TELA 2
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
                                                      ? areaData.color
                                                      : Colors.grey.shade400,
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

                    // ✅ FEEDBACK VISUAL DE SUCESSO
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
                              child: const Icon(Icons.explore,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hasSelection
                                    ? 'Ótima escolha! Agora vamos às universidades! 🎓'
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

            // ✅ BOTÃO FOOTER - PADRONIZADO COM OUTRAS TELAS
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
                      hasSelection ? () => context.go('/onboarding/4') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: hasSelection ? 4 : 0,
                    shadowColor: Colors.green[600]!.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasSelection ? 'Próxima etapa! 🎓' : 'Escolha uma área',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasSelection ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward, size: 18),
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

// ===== CLASSE DE DADOS =====
class ProfessionalTrailData {
  final ProfessionalTrail trail;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  ProfessionalTrailData({
    required this.trail,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}

// ===== TELA 4 UNIVERSIDADE DOS SONHOS PREMIUM =====
// SUBSTITUA A CLASSE Tela4UniversidadeSonho EXISTENTE

class Tela4UniversidadeSonho extends ConsumerStatefulWidget {
  const Tela4UniversidadeSonho({super.key});

  @override
  ConsumerState<Tela4UniversidadeSonho> createState() =>
      _Tela4UniversidadeSonhoState();
}

class _Tela4UniversidadeSonhoState extends ConsumerState<Tela4UniversidadeSonho>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;

  final List<UniversityData> _universities = [
    // ===== UNIVERSIDADES FEDERAIS (ORDEM ALFABÉTICA) =====
    UniversityData(
      name: 'UFAM',
      fullName: 'Universidade Federal do Amazonas',
      emoji: '🌿',
      category: 'Federal',
      color: Colors.green[700]!,
    ),
    UniversityData(
      name: 'UFBA',
      fullName: 'Universidade Federal da Bahia',
      emoji: '🥥',
      category: 'Federal',
      color: Colors.amber,
    ),
    UniversityData(
      name: 'UFC',
      fullName: 'Universidade Federal do Ceará',
      emoji: '☀️',
      category: 'Federal',
      color: Colors.deepOrange,
    ),
    UniversityData(
      name: 'UFCG',
      fullName: 'Universidade Federal de Campina Grande',
      emoji: '💻',
      category: 'Federal',
      color: Colors.deepPurple[600]!,
    ),
    UniversityData(
      name: 'UFMG',
      fullName: 'Universidade Federal de Minas Gerais',
      emoji: '⛰️',
      category: 'Federal',
      color: Colors.brown,
    ),
    UniversityData(
      name: 'UFPE',
      fullName: 'Universidade Federal de Pernambuco',
      emoji: '🌴',
      category: 'Federal',
      color: Colors.orange,
    ),
    UniversityData(
      name: 'UFPR',
      fullName: 'Universidade Federal do Paraná',
      emoji: '🌲',
      category: 'Federal',
      color: Colors.lightGreen,
    ),
    UniversityData(
      name: 'UFRGS',
      fullName: 'Universidade Federal do Rio Grande do Sul',
      emoji: '🌱',
      category: 'Federal',
      color: Colors.green,
    ),
    UniversityData(
      name: 'UFRJ',
      fullName: 'Universidade Federal do Rio de Janeiro',
      emoji: '🌊',
      category: 'Federal',
      color: Colors.cyan,
    ),
    UniversityData(
      name: 'UFSC',
      fullName: 'Universidade Federal de Santa Catarina',
      emoji: '🏝️',
      category: 'Federal',
      color: Colors.teal,
    ),
    UniversityData(
      name: 'UnB',
      fullName: 'Universidade de Brasília',
      emoji: '🏛️',
      category: 'Federal',
      color: Colors.purple,
    ),
    UniversityData(
      name: 'UNICAMP',
      fullName: 'Universidade Estadual de Campinas',
      emoji: '🔬',
      category: 'Federal',
      color: Colors.indigo,
    ),
    UniversityData(
      name: 'UNIFESP',
      fullName: 'Universidade Federal de São Paulo',
      emoji: '🏥',
      category: 'Federal',
      color: Colors.red,
    ),
    UniversityData(
      name: 'USP',
      fullName: 'Universidade de São Paulo',
      emoji: '🏛️',
      category: 'Federal',
      color: Colors.blue,
    ),

    // ===== UNIVERSIDADES ESTADUAIS (ORDEM ALFABÉTICA) =====
    UniversityData(
      name: 'FAMERP',
      fullName: 'Faculdade de Medicina de São José do Rio Preto',
      emoji: '⚕️',
      category: 'Estadual',
      color: Colors.pink,
    ),
    UniversityData(
      name: 'UERJ',
      fullName: 'Universidade do Estado do Rio de Janeiro',
      emoji: '🏙️',
      category: 'Estadual',
      color: Colors.deepPurple,
    ),

    // ===== INSTITUIÇÕES MILITARES (ORDEM ALFABÉTICA) =====
    UniversityData(
      name: 'IME',
      fullName: 'Instituto Militar de Engenharia',
      emoji: '🎯',
      category: 'Militar',
      color: Colors.teal[700]!,
    ),
    UniversityData(
      name: 'ITA',
      fullName: 'Instituto Tecnológico de Aeronáutica',
      emoji: '✈️',
      category: 'Militar',
      color: Colors.blueGrey,
    ),

    // ===== UNIVERSIDADES PRIVADAS (ORDEM ALFABÉTICA) =====
    UniversityData(
      name: 'Albert Einstein',
      fullName: 'Instituto Israelita Albert Einstein',
      emoji: '⚗️',
      category: 'Privada',
      color: Colors.cyan[700]!,
    ),
    UniversityData(
      name: 'FGV',
      fullName: 'Fundação Getúlio Vargas',
      emoji: '💼',
      category: 'Privada',
      color: Colors.brown[700]!,
    ),
    UniversityData(
      name: 'Insper',
      fullName: 'Instituto de Ensino e Pesquisa',
      emoji: '📊',
      category: 'Privada',
      color: Colors.blue[800]!,
    ),
    UniversityData(
      name: 'Mackenzie',
      fullName: 'Universidade Presbiteriana Mackenzie',
      emoji: '🏫',
      category: 'Privada',
      color: Colors.orange[700]!,
    ),
    UniversityData(
      name: 'PUC-Rio',
      fullName: 'Pontifícia Universidade Católica do Rio',
      emoji: '⛪',
      category: 'Privada',
      color: Colors.indigo[700]!,
    ),
    UniversityData(
      name: 'PUC-RS',
      fullName: 'Pontifícia Universidade Católica do RS',
      emoji: '⛪',
      category: 'Privada',
      color: Colors.purple[700]!,
    ),
    UniversityData(
      name: 'PUC-SP',
      fullName: 'Pontifícia Universidade Católica de SP',
      emoji: '⛪',
      category: 'Privada',
      color: Colors.deepPurple,
    ),
    UniversityData(
      name: 'Santa Casa SP',
      fullName: 'Santa Casa de São Paulo',
      emoji: '🏥',
      category: 'Privada',
      color: Colors.red[700]!,
    ),

    // ===== OPÇÕES ESPECIAIS (ORDEM ALFABÉTICA) =====
    UniversityData(
      name: 'Ainda não decidi',
      fullName: 'Estou explorando as opções',
      emoji: '🤔',
      category: 'Especial',
      color: Colors.grey,
    ),
    UniversityData(
      name: 'Prefiro não informar',
      fullName: 'Não quero compartilhar agora',
      emoji: '🔒',
      category: 'Especial',
      color: Colors.grey[600]!,
    ),
    UniversityData(
      name: 'Universidade da minha região',
      fullName: 'Prefiro ficar perto de casa',
      emoji: '🏠',
      category: 'Especial',
      color: Colors.lightGreen,
    ),
    UniversityData(
      name: 'Universidade no exterior',
      fullName: 'Quero estudar fora do Brasil',
      emoji: '🌍',
      category: 'Especial',
      color: Colors.amber,
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

    _cardAnimations = List.generate(_universities.length, (index) {
      // Corrigir o intervalo para evitar assertion error
      final double startInterval = (index * 0.03).clamp(0.0, 0.8);
      final double endInterval = (startInterval + 0.2).clamp(0.2, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        ),
      );
    });

    // Iniciar animações
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
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
    final hasSelection = onboarding.dreamUniversity != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER - PADRÃO CONSISTENTE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/3'),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.green[700]!, size: 20),
                      ),
                      Text(
                        'Passo 5 de 8',
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
                            MediaQuery.of(context).size.width * (5 / 8) * 0.86,
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

            // ✅ CONTEÚDO PRINCIPAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ✅ HERO SECTION ANIMADO
                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _heroAnimation.value),
                          child: Opacity(
                            opacity: _heroAnimation.value,
                            child: Column(
                              children: [
                                Text('🎓',
                                    style: TextStyle(
                                        fontSize: 50 * _heroAnimation.value)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Qual sua universidade\ndos sonhos?',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Todo grande sonho começa com um objetivo! 🌟',
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

                    // ✅ LISTA DE UNIVERSIDADES
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _universities.length,
                      itemBuilder: (context, index) {
                        final universityData = _universities[index];
                        final isSelected =
                            onboarding.dreamUniversity == universityData.name;

                        return AnimatedBuilder(
                          animation: _cardAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  30 * (1 - _cardAnimations[index].value), 0),
                              child: Opacity(
                                opacity: _cardAnimations[index].value,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                universityData.color
                                                    .withValues(alpha: 0.1),
                                                universityData.color
                                                    .withValues(alpha: 0.05),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? universityData.color
                                            : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? universityData.color
                                                  .withValues(alpha: 0.2)
                                              : Colors.black
                                                  .withValues(alpha: 0.03),
                                          blurRadius: isSelected ? 8 : 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref
                                              .read(onboardingProvider.notifier)
                                              .update((state) {
                                            final newState = OnboardingData();
                                            newState.name = state.name;
                                            newState.educationLevel =
                                                state.educationLevel;
                                            newState.studyGoal =
                                                state.studyGoal;
                                            newState.interestArea =
                                                state.interestArea;
                                            newState.dreamUniversity =
                                                universityData.name;
                                            newState.studyTime =
                                                state.studyTime;
                                            newState.mainDifficulty =
                                                state.mainDifficulty;
                                            newState.studyStyle =
                                                state.studyStyle;
                                            return newState;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // Emoji + Categoria
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: universityData.color
                                                      .withValues(alpha: 0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                      universityData.emoji,
                                                      style: const TextStyle(
                                                          fontSize: 20)),
                                                ),
                                              ),

                                              const SizedBox(width: 16),

                                              // Texto principal
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            universityData.name,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: isSelected
                                                                  ? universityData
                                                                      .color
                                                                  : Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: universityData
                                                                .color
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            universityData
                                                                .category,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  universityData
                                                                      .color,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      universityData.fullName,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey.shade600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Radio button
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
                                                      ? universityData.color
                                                      : Colors.grey.shade400,
                                                  size: 20,
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

                    // ✅ FEEDBACK VISUAL DE SUCESSO
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
                                    ? 'Excelente meta! Vamos descobrir quanto tempo você tem! ⏰'
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

            // ✅ BOTÃO FOOTER - PADRÃO CONSISTENTE
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
                      hasSelection ? () => context.go('/onboarding/5') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: hasSelection ? 4 : 0,
                    shadowColor: Colors.green[600]!.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasSelection
                            ? 'Vamos ao tempo de estudo! ⏰'
                            : 'Escolha sua universidade',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasSelection ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward, size: 18),
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

// ===== CLASSE DE DADOS PARA UNIVERSIDADES =====
class UniversityData {
  final String name;
  final String fullName;
  final String emoji;
  final String category;
  final Color color;

  UniversityData({
    required this.name,
    required this.fullName,
    required this.emoji,
    required this.category,
    required this.color,
  });
}

// ===== TELA 5 TEMPO DE ESTUDO PREMIUM =====
// SUBSTITUA A CLASSE Tela5TempoEstudo EXISTENTE

class Tela5TempoEstudo extends ConsumerStatefulWidget {
  const Tela5TempoEstudo({super.key});

  @override
  ConsumerState<Tela5TempoEstudo> createState() => _Tela5TempoEstudoState();
}

class _Tela5TempoEstudoState extends ConsumerState<Tela5TempoEstudo>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;

  final List<StudyTimeData> _timeOptions = [
    StudyTimeData(
      time: '15-30 minutos',
      emoji: '⚡',
      title: '15-30 min',
      subtitle: 'Sessões rápidas',
      description: 'Perfeito para quem tem rotina corrida',
      recommendation: 'Ideal para revisões e conceitos básicos',
      color: Colors.green,
    ),
    StudyTimeData(
      time: '30-60 minutos',
      emoji: '🎯',
      title: '30-60 min',
      subtitle: 'Foco moderado',
      description: 'Tempo ideal para a maioria dos estudantes',
      recommendation: 'Permite aprofundar temas e fazer exercícios',
      color: Colors.blue,
    ),
    StudyTimeData(
      time: '1-2 horas',
      emoji: '🔥',
      title: '1-2 horas',
      subtitle: 'Estudo intenso',
      description: 'Para quem quer acelerar o aprendizado',
      recommendation: 'Questões complexas e simulados completos',
      color: Colors.orange,
    ),
    StudyTimeData(
      time: 'Mais de 2 horas',
      emoji: '🏆',
      title: 'Mais de 2h',
      subtitle: 'Dedicação máxima',
      description: 'Para conquistas extraordinárias',
      recommendation: 'Simulados extensos e revisão completa',
      color: Colors.purple,
    ),
    StudyTimeData(
      time: 'Varia conforme o dia',
      emoji: '📅',
      title: 'Tempo flexível',
      subtitle: 'Agenda variável',
      description: 'Alguns dias mais, outros menos',
      recommendation: 'Sistema adaptará o conteúdo dinamicamente',
      color: Colors.teal,
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

    _cardAnimations = List.generate(_timeOptions.length, (index) {
      final double startInterval = (index * 0.15).clamp(0.0, 0.6);
      final double endInterval = (startInterval + 0.4).clamp(0.4, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        ),
      );
    });

    // Iniciar animações
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
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
    final hasSelection = onboarding.studyTime != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER - PADRÃO CONSISTENTE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/4'),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.green[700]!, size: 20),
                      ),
                      Text(
                        'Passo 6 de 8',
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
                            MediaQuery.of(context).size.width * (6 / 8) * 0.86,
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

            // ✅ CONTEÚDO PRINCIPAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ✅ HERO SECTION ANIMADO
                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _heroAnimation.value),
                          child: Opacity(
                            opacity: _heroAnimation.value,
                            child: Column(
                              children: [
                                Text('⏰',
                                    style: TextStyle(
                                        fontSize: 50 * _heroAnimation.value)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Quanto tempo você tem\npara estudar por dia?',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Vamos personalizar sua jornada de acordo com seu tempo! 📚',
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

                    // ✅ LISTA DE OPÇÕES DE TEMPO
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _timeOptions.length,
                      itemBuilder: (context, index) {
                        final timeData = _timeOptions[index];
                        final isSelected =
                            onboarding.studyTime == timeData.time;

                        return AnimatedBuilder(
                          animation: _cardAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  40 * (1 - _cardAnimations[index].value), 0),
                              child: Opacity(
                                opacity: _cardAnimations[index].value,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                timeData.color
                                                    .withValues(alpha: 0.1),
                                                timeData.color
                                                    .withValues(alpha: 0.05),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? timeData.color
                                            : Colors.grey.shade200,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? timeData.color
                                                  .withValues(alpha: 0.25)
                                              : Colors.black
                                                  .withValues(alpha: 0.03),
                                          blurRadius: isSelected ? 12 : 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref
                                              .read(onboardingProvider.notifier)
                                              .update((state) {
                                            final newState = OnboardingData();
                                            newState.name = state.name;
                                            newState.educationLevel =
                                                state.educationLevel;
                                            newState.studyGoal =
                                                state.studyGoal;
                                            newState.interestArea =
                                                state.interestArea;
                                            newState.dreamUniversity =
                                                state.dreamUniversity;
                                            newState.studyTime = timeData.time;
                                            newState.mainDifficulty =
                                                state.mainDifficulty;
                                            newState.studyStyle =
                                                state.studyStyle;
                                            return newState;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              // Emoji + Indicador visual
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: timeData.color
                                                      .withValues(alpha: 0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(timeData.emoji,
                                                      style: const TextStyle(
                                                          fontSize: 26)),
                                                ),
                                              ),

                                              const SizedBox(width: 16),

                                              // Texto principal
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      timeData.title,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? timeData.color
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      timeData.subtitle,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? timeData.color
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : Colors
                                                                .grey.shade600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      timeData.description,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors
                                                            .grey.shade600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: timeData.color
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        timeData.recommendation,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: timeData.color,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Radio button
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
                                                      ? timeData.color
                                                      : Colors.grey.shade400,
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

                    // ✅ FEEDBACK VISUAL DE SUCESSO
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
                              child: const Icon(Icons.schedule,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hasSelection
                                    ? 'Perfeito! Agora vamos descobrir suas dificuldades! 🎯'
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

            // ✅ BOTÃO FOOTER - PADRÃO CONSISTENTE
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
                      hasSelection ? () => context.go('/onboarding/6') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: hasSelection ? 4 : 0,
                    shadowColor: Colors.green[600]!.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasSelection
                            ? 'Vamos às dificuldades! 🎯'
                            : 'Escolha seu tempo',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasSelection ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward, size: 18),
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

// ===== CLASSE DE DADOS PARA TEMPO DE ESTUDO =====
class StudyTimeData {
  final String time;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final String recommendation;
  final Color color;

  StudyTimeData({
    required this.time,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.recommendation,
    required this.color,
  });
}

// ===== TELA 6 DIFICULDADES DUPLA SELEÇÃO PREMIUM =====
// SUBSTITUA A CLASSE Tela6Dificuldade EXISTENTE

class Tela6Dificuldade extends ConsumerStatefulWidget {
  const Tela6Dificuldade({super.key});

  @override
  ConsumerState<Tela6Dificuldade> createState() => _Tela6DificuldadeState();
}

class _Tela6DificuldadeState extends ConsumerState<Tela6Dificuldade>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;

  String? selectedSubject;
  String? selectedBehavior;

  final List<DifficultySubjectData> _subjects = [
    DifficultySubjectData(
      subject: 'Português e Literatura',
      emoji: '📖',
      title: 'Português',
      color: Colors.purple,
    ),
    DifficultySubjectData(
      subject: 'Matemática',
      emoji: '🔢',
      title: 'Matemática',
      color: Colors.red,
    ),
    DifficultySubjectData(
      subject: 'Física',
      emoji: '⚛️',
      title: 'Física',
      color: Colors.blue,
    ),
    DifficultySubjectData(
      subject: 'Química',
      emoji: '⚗️',
      title: 'Química',
      color: Colors.orange,
    ),
    DifficultySubjectData(
      subject: 'Biologia',
      emoji: '🧬',
      title: 'Biologia',
      color: Colors.green,
    ),
    DifficultySubjectData(
      subject: 'História',
      emoji: '📚',
      title: 'História',
      color: Colors.amber,
    ),
    DifficultySubjectData(
      subject: 'Geografia',
      emoji: '🌍',
      title: 'Geografia',
      color: Colors.brown,
    ),
    DifficultySubjectData(
      subject: 'Inglês',
      emoji: '🇺🇸',
      title: 'Inglês',
      color: Colors.indigo,
    ),
    DifficultySubjectData(
      subject: 'Não tenho dificuldade específica em matérias',
      emoji: '✨',
      title: 'Sem dificuldade',
      color: Colors.green[300]!,
    ),
  ];

  final List<DifficultyBehaviorData> _behaviors = [
    DifficultyBehaviorData(
      behavior: 'Foco e concentração',
      emoji: '🎯',
      title: 'Concentração',
      description: 'Manter atenção durante os estudos',
      color: Colors.blue[300]!,
    ),
    DifficultyBehaviorData(
      behavior: 'Memorização e fixação',
      emoji: '🧠',
      title: 'Memorização',
      description: 'Reter e relembrar informações',
      color: Colors.purple[300]!,
    ),
    DifficultyBehaviorData(
      behavior: 'Motivação para estudar',
      emoji: '💪',
      title: 'Motivação',
      description: 'Manter ânimo e disposição',
      color: Colors.green[300]!,
    ),
    DifficultyBehaviorData(
      behavior: 'Ansiedade em provas',
      emoji: '😰',
      title: 'Ansiedade',
      description: 'Nervosismo em avaliações',
      color: Colors.red[300]!,
    ),
    DifficultyBehaviorData(
      behavior: 'Raciocínio lógico',
      emoji: '🧩',
      title: 'Lógica',
      description: 'Resolução de problemas complexos',
      color: Colors.cyan[300]!,
    ),
    DifficultyBehaviorData(
      behavior: 'Organização dos estudos',
      emoji: '📅',
      title: 'Organização',
      description: 'Planejar e estruturar estudos',
      color: Colors.orange[300]!,
    ),
    DifficultyBehaviorData(
      behavior: 'Interpretação de texto',
      emoji: '🔍',
      title: 'Interpretação',
      description: 'Compreender textos e enunciados',
      color: Colors.teal[300]!,
    ),
    DifficultyBehaviorData(
      behavior: 'Não tenho dificuldades comportamentais',
      emoji: '✨',
      title: 'Sem dificuldade',
      description: 'Me sinto confiante nesses aspectos',
      color: Colors.green[300]!,
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

    _cardAnimations = List.generate(2, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(index * 0.3, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    // Iniciar animações
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  void _saveSelection() {
    final combinedDifficulty =
        selectedSubject != null && selectedBehavior != null
            ? '$selectedSubject + $selectedBehavior'
            : selectedSubject ?? selectedBehavior ?? '';

    ref.read(onboardingProvider.notifier).update((state) {
      final newState = OnboardingData();
      newState.name = state.name;
      newState.educationLevel = state.educationLevel;
      newState.studyGoal = state.studyGoal;
      newState.interestArea = state.interestArea;
      newState.dreamUniversity = state.dreamUniversity;
      newState.studyTime = state.studyTime;
      newState.mainDifficulty = combinedDifficulty;
      newState.studyStyle = state.studyStyle;
      return newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedSubject != null && selectedBehavior != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/5'),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.green[700]!, size: 20),
                      ),
                      Text(
                        'Passo 7 de 8',
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
                            MediaQuery.of(context).size.width * (7 / 8) * 0.86,
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

            // ✅ CONTEÚDO PRINCIPAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ✅ HERO SECTION
                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _heroAnimation.value),
                          child: Opacity(
                            opacity: _heroAnimation.value,
                            child: Column(
                              children: [
                                Text('🎯',
                                    style: TextStyle(
                                        fontSize: 50 * _heroAnimation.value)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Onde você sente\nmais dificuldade?',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Escolha uma matéria E um aspecto comportamental! 🧠',
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

                    // ✅ SEÇÃO 1: MATÉRIAS
                    AnimatedBuilder(
                      animation: _cardAnimations[0],
                      builder: (context, child) {
                        return Transform.translate(
                          offset:
                              Offset(0, 30 * (1 - _cardAnimations[0].value)),
                          child: Opacity(
                            opacity: _cardAnimations[0].value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.school,
                                            color: Colors.blue, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        '1️⃣ Qual matéria é mais desafiadora?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _subjects.map((subject) {
                                      final isSelected =
                                          selectedSubject == subject.subject;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedSubject = subject.subject;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? subject.color
                                                    .withValues(alpha: 0.2)
                                                : Colors.grey[100]!,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? subject.color
                                                  : Colors.grey[300]!,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(subject.emoji,
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                              const SizedBox(width: 6),
                                              Text(
                                                subject.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? subject.color
                                                      : Colors.black87,
                                                ),
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(width: 4),
                                                Icon(Icons.check,
                                                    color: subject.color,
                                                    size: 16),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ✅ SEÇÃO 2: ASPECTOS COMPORTAMENTAIS
                    AnimatedBuilder(
                      animation: _cardAnimations[1],
                      builder: (context, child) {
                        return Transform.translate(
                          offset:
                              Offset(0, 30 * (1 - _cardAnimations[1].value)),
                          child: Opacity(
                            opacity: _cardAnimations[1].value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.purple
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.psychology,
                                            color: Colors.purple, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        '2️⃣ Qual aspecto comportamental?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Column(
                                    children: _behaviors.map((behavior) {
                                      final isSelected =
                                          selectedBehavior == behavior.behavior;
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedBehavior =
                                                  behavior.behavior;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? behavior.color
                                                      .withValues(alpha: 0.2)
                                                  : Colors.grey[50]!,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? behavior.color
                                                    : Colors.grey[200]!,
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(behavior.emoji,
                                                    style: const TextStyle(
                                                        fontSize: 18)),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        behavior.title,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight.w600,
                                                          color: isSelected
                                                              ? behavior.color
                                                              : Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        behavior.description,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[600]!,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  isSelected
                                                      ? Icons
                                                          .radio_button_checked
                                                      : Icons
                                                          .radio_button_unchecked,
                                                  color: isSelected
                                                      ? behavior.color
                                                      : Colors.grey[400]!,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ✅ FEEDBACK COMBINADO
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
                              child: const Icon(Icons.psychology,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hasSelection
                                    ? 'Perfeito! Combinação identificada: $selectedSubject + $selectedBehavior! 🎯'
                                    : '',
                                style: TextStyle(
                                  color: Colors.green[700]!,
                                  fontSize: 16,
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

            // ✅ BOTÃO FOOTER
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
                  onPressed: hasSelection
                      ? () {
                          _saveSelection();
                          context.go('/onboarding/7');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: hasSelection ? 4 : 0,
                    shadowColor: Colors.green[600]!.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasSelection
                            ? 'Última etapa! 🏁'
                            : 'Escolha matéria E aspecto',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasSelection ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.arrow_forward, size: 18),
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

// ===== CLASSES DE DADOS =====
class DifficultySubjectData {
  final String subject;
  final String emoji;
  final String title;
  final Color color;

  DifficultySubjectData({
    required this.subject,
    required this.emoji,
    required this.title,
    required this.color,
  });
}

class DifficultyBehaviorData {
  final String behavior;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  DifficultyBehaviorData({
    required this.behavior,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

// ===== TELA 7 ESTILO DE ESTUDO PREMIUM - FINAL =====
// SUBSTITUA A CLASSE Tela7EstiloEstudo EXISTENTE

class Tela7EstiloEstudo extends ConsumerStatefulWidget {
  const Tela7EstiloEstudo({super.key});

  @override
  ConsumerState<Tela7EstiloEstudo> createState() => _Tela7EstiloEstudoState();
}

class _Tela7EstiloEstudoState extends ConsumerState<Tela7EstiloEstudo>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;

  final List<StudyStyleData> _styles = [
    StudyStyleData(
      style: 'Sozinho(a) e no meu ritmo',
      emoji: '🧘‍♂️',
      title: 'Solo Focus',
      subtitle: 'Autonomia Total',
      description:
          'Prefiro estudar sozinho, controlando meu próprio ritmo e ambiente',
      benefits: [
        'Concentração máxima',
        'Ritmo personalizado',
        'Ambiente controlado'
      ],
      gameFeatures: 'Modo single-player com progressão individual',
      color: Colors.blue,
    ),
    StudyStyleData(
      style: 'Competindo com outros',
      emoji: '🏆',
      title: 'Competidor',
      subtitle: 'Motivação pela Disputa',
      description: 'Me motivo comparando meu desempenho com outros estudantes',
      benefits: ['Motivação extra', 'Benchmarking', 'Espírito competitivo'],
      gameFeatures: 'Rankings, torneios e challenges contra outros jogadores',
      color: Colors.red,
    ),
    StudyStyleData(
      style: 'Em grupos de estudo',
      emoji: '👥',
      title: 'Colaborativo',
      subtitle: 'Aprendizado Social',
      description: 'Aprendo melhor discutindo e trocando ideias com colegas',
      benefits: [
        'Troca de experiências',
        'Motivação mútua',
        'Diferentes perspectivas'
      ],
      gameFeatures: 'Grupos cooperativos e chat de estudos',
      color: Colors.green,
    ),
    StudyStyleData(
      style: 'Com metas e desafios',
      emoji: '🎯',
      title: 'Goal-Oriented',
      subtitle: 'Foco em Objetivos',
      description: 'Me organizo melhor com metas claras e desafios específicos',
      benefits: [
        'Direcionamento claro',
        'Senso de progresso',
        'Motivação por conquistas'
      ],
      gameFeatures: 'Sistema de missões, badges e objetivos diários',
      color: Colors.purple,
    ),
    StudyStyleData(
      style: 'Explorador curioso',
      emoji: '🔍',
      title: 'Explorer',
      subtitle: 'Descoberta Livre',
      description:
          'Gosto de explorar temas livremente e seguir minha curiosidade',
      benefits: [
        'Aprendizado natural',
        'Conexões criativas',
        'Motivação intrínseca'
      ],
      gameFeatures: 'Modo exploração com trilhas abertas e descobertas',
      color: Colors.orange,
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

    _cardAnimations = List.generate(_styles.length, (index) {
      final double startInterval = (index * 0.15).clamp(0.0, 0.6);
      final double endInterval = (startInterval + 0.4).clamp(0.4, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        ),
      );
    });

    // Iniciar animações
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
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
    final hasSelection = onboarding.studyStyle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER - FINAL!
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/6'),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.green[700]!, size: 20),
                      ),
                      Text(
                        'Passo 8 de 8',
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
                            MediaQuery.of(context).size.width * 0.86, // 100%!
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

            // ✅ CONTEÚDO PRINCIPAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ✅ HERO SECTION FINAL
                    AnimatedBuilder(
                      animation: _heroAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * _heroAnimation.value),
                          child: Opacity(
                            opacity: _heroAnimation.value,
                            child: Column(
                              children: [
                                Text('🎨',
                                    style: TextStyle(
                                        fontSize: 50 * _heroAnimation.value)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Como você prefere\nestudar?',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Última pergunta! Vamos personalizar sua experiência! 🚀',
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

                    // ✅ LISTA DE ESTILOS DE ESTUDO
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _styles.length,
                      itemBuilder: (context, index) {
                        final styleData = _styles[index];
                        final isSelected =
                            onboarding.studyStyle == styleData.style;

                        return AnimatedBuilder(
                          animation: _cardAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  40 * (1 - _cardAnimations[index].value), 0),
                              child: Opacity(
                                opacity: _cardAnimations[index].value,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                styleData.color
                                                    .withValues(alpha: 0.1),
                                                styleData.color
                                                    .withValues(alpha: 0.05),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? styleData.color
                                            : Colors.grey.shade200,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? styleData.color
                                                  .withValues(alpha: 0.25)
                                              : Colors.black
                                                  .withValues(alpha: 0.03),
                                          blurRadius: isSelected ? 12 : 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          ref
                                              .read(onboardingProvider.notifier)
                                              .update((state) {
                                            final newState = OnboardingData();
                                            newState.name = state.name;
                                            newState.educationLevel =
                                                state.educationLevel;
                                            newState.studyGoal =
                                                state.studyGoal;
                                            newState.interestArea =
                                                state.interestArea;
                                            newState.dreamUniversity =
                                                state.dreamUniversity;
                                            newState.studyTime =
                                                state.studyTime;
                                            newState.mainDifficulty =
                                                state.mainDifficulty;
                                            newState.studyStyle =
                                                styleData.style;
                                            return newState;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Header do card
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: styleData.color
                                                          .withValues(
                                                              alpha: 0.15),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          styleData.emoji,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      26)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          styleData.title,
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isSelected
                                                                ? styleData
                                                                    .color
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                        ),
                                                        Text(
                                                          styleData.subtitle,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isSelected
                                                                ? styleData
                                                                    .color
                                                                    .withValues(
                                                                        alpha:
                                                                            0.8)
                                                                : Colors.grey
                                                                    .shade600,
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
                                                          ? styleData.color
                                                          : Colors
                                                              .grey.shade400,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 16),

                                              // Descrição
                                              Text(
                                                styleData.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                  height: 1.4,
                                                ),
                                              ),

                                              const SizedBox(height: 12),

                                              // Benefícios
                                              Row(
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      color: styleData.color
                                                          .withValues(
                                                              alpha: 0.7),
                                                      size: 16),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      styleData.benefits
                                                          .join(' • '),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: styleData.color
                                                            .withValues(
                                                                alpha: 0.8),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 12),

                                              // Features do game
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: styleData.color
                                                      .withValues(alpha: 0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.videogame_asset,
                                                        color: styleData.color,
                                                        size: 16),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        styleData.gameFeatures,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              styleData.color,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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

                    // ✅ FEEDBACK FINAL DE SUCESSO
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
                                    ? 'Perfil completo! Sua jornada personalizada está pronta! 🎉'
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

            // ✅ BOTÃO FINAL - COMEÇAR AVENTURA!
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
                  onPressed: hasSelection
                      ? () => context.go('/onboarding/complete')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelection ? Colors.green[600]! : Colors.grey[400]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                            ? 'Começar minha aventura! 🌟'
                            : 'Escolha seu estilo',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: hasSelection ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.rocket_launch, size: 20),
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

// ===== CLASSE DE DADOS PARA ESTILOS DE ESTUDO =====
class StudyStyleData {
  final String style;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<String> benefits;
  final String gameFeatures;
  final Color color;

  StudyStyleData({
    required this.style,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.benefits,
    required this.gameFeatures,
    required this.color,
  });
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

// ===== TELA 8 - REDESIGN UX COMPLETO =====
// ===== TELA 8 - REDESIGN PREMIUM + PREPARAÇÃO LEONARDO AI =====
// Corrige: Cards desbalanceados, CTA perdido, layout responsivo
// Prepara: Espaços para avatares gerados e backgrounds do Leonardo AI

class Tela8FinalizacaoPremium extends ConsumerStatefulWidget {
  const Tela8FinalizacaoPremium({super.key});

  @override
  ConsumerState<Tela8FinalizacaoPremium> createState() =>
      _Tela8FinalizacaoPremiumState();
}

class _Tela8FinalizacaoPremiumState
    extends ConsumerState<Tela8FinalizacaoPremium>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _contentController;
  late AnimationController _ctaController;

  late Animation<double> _celebrationAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _ctaAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _ctaController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOutBack,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    _ctaAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ctaController,
      curve: Curves.easeOut,
    ));

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _celebrationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _ctaController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _contentController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // 📊 PROGRESS HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/7'),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.green[700]!,
                          size: 20,
                        ),
                      ),
                      Text(
                        'Passo 8 de 8',
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
                            MediaQuery.of(context).size.width * 0.86, // 100%!
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[400]!,
                              Colors.green[600]!,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🎨 CONTEÚDO PRINCIPAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // 🎉 CELEBRAÇÃO PREMIUM
                    AnimatedBuilder(
                      animation: _celebrationAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _celebrationAnimation.value.clamp(0.0, 1.0),
                          child: Opacity(
                            opacity:
                                _celebrationAnimation.value.clamp(0.0, 1.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00C851)
                                        .withValues(alpha: 0.15),
                                    const Color(0xFF007BFF)
                                        .withValues(alpha: 0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF00C851)
                                      .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C851)
                                        .withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🎉',
                                          style: TextStyle(fontSize: 32)),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          'Parabéns, ${onboarding.name}!',
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00C851),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('🎉',
                                          style: TextStyle(fontSize: 32)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Seu perfil de estudos foi criado com sucesso!\nVocê está pronto para sua jornada de aprendizado! 🚀',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF007BFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // 📊 LAYOUT RESPONSIVO COM CARDS BALANCEADOS
                    AnimatedBuilder(
                      animation: _contentAnimation,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _slideAnimation,
                          child: Opacity(
                            opacity: _contentAnimation.value.clamp(0.0, 1.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 600) {
                                  // 📱 MOBILE: Coluna única
                                  return Column(
                                    children: [
                                      _buildProfileCard(onboarding),
                                      const SizedBox(height: 24),
                                      _buildAvatarCard(),
                                    ],
                                  );
                                } else {
                                  // 💻 DESKTOP: Duas colunas BALANCEADAS
                                  return IntrinsicHeight(
                                    // 🔑 CHAVE PARA MESMA ALTURA!
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                            child:
                                                _buildProfileCard(onboarding)),
                                        const SizedBox(width: 24),
                                        Expanded(child: _buildAvatarCard()),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // 🗺️ TRILHAS EM DESTAQUE
                    AnimatedBuilder(
                      animation: _contentAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            30 * (1 - _contentAnimation.value.clamp(0.0, 1.0)),
                          ),
                          child: Opacity(
                            opacity: _contentAnimation.value.clamp(0.0, 1.0),
                            child: _buildTrailsSection(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // 🚀 CTA PRIMÁRIO IMPACTANTE
            AnimatedBuilder(
              animation: _ctaAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0, 50 * (1 - _ctaAnimation.value.clamp(0.0, 1.0))),
                  child: Opacity(
                    opacity: _ctaAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 🏆 ÍCONES MOTIVACIONAIS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMotivationIcon('🏆', 'Conquistas'),
                              _buildMotivationIcon('⭐', 'Experiência'),
                              _buildMotivationIcon('🎯', 'Objetivos'),
                              _buildMotivationIcon('🎮', 'Diversão'),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 🚀 BOTÃO SUPER IMPACTANTE
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () => _finalizarOnboarding(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C851),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                                shadowColor: const Color(0xFF00C851)
                                    .withValues(alpha: 0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar Minha Aventura!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('🌟', style: TextStyle(fontSize: 24)),
                                ],
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
          ],
        ),
      ),
    );
  }

  // 📊 PERFIL CARD BALANCEADO
  Widget _buildProfileCard(OnboardingData onboarding) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00C851).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ IMPORTANTE PARA INTRINSIC HEIGHT
        children: [
          // Header do card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C851).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF00C851),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Seu Perfil de Estudos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C851),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Conteúdo do perfil
          _buildProfileItem(
              '📚', 'Nível', _getEducationLevelText(onboarding.educationLevel)),
          _buildProfileItem(
              '🎯', 'Objetivo', _getStudyGoalText(onboarding.studyGoal)),
          _buildProfileItem(
              '🧭', 'Interesse', _getInterestAreaText(onboarding.interestArea)),
          _buildProfileItem(
              '📖', 'Estilo', onboarding.studyStyle ?? 'Não informado'),

          // ✅ Espaçador para igualar altura
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 🎨 AVATAR CARD BALANCEADO + PREPARADO PARA LEONARDO AI
  Widget _buildAvatarCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF007BFF).withValues(alpha: 0.1),
            const Color(0xFF6F42C1).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF007BFF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ IMPORTANTE
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🎮', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Seu Avatar Está Sendo Criado...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007BFF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🎨 CONTEÚDO PRINCIPAL CENTRALIZADO - PREPARADO PARA LEONARDO AI
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ CONTAINER PARA FUTURO AVATAR LEONARDO AI
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF007BFF),
                          const Color(0xFF6F42C1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007BFF).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child:
                        // 🔮 FUTURO: Substituir por Image.network(leonardoAvatarUrl)
                        const Icon(Icons.person, size: 60, color: Colors.white),

                    // 🎨 QUANDO IMPLEMENTAR LEONARDO AI:
                    // ClipOval(
                    //   child: Image.network(
                    //     userProfile.leonardoAvatarUrl ?? defaultAvatarUrl,
                    //     fit: BoxFit.cover,
                    //     loadingBuilder: (context, child, progress) {
                    //       return progress == null ? child : CircularProgressIndicator();
                    //     },
                    //   ),
                    // ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Baseado no seu perfil, vamos personalizar sua experiência de aprendizado!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF007BFF),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ✅ Padding inferior para igualar altura
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 🗺️ TRILHAS SECTION - PREPARADO PARA BACKGROUNDS LEONARDO AI
  Widget _buildTrailsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🗺️', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Trilhas de Aventura Disponíveis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C851),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Layout responsivo para trilhas
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  children: [
                    _buildTrailCard(
                      '🌲',
                      'Floresta Amazônica',
                      'Sobrevivência e Matemática',
                      const Color(0xFF00C851),
                      'Explore a maior floresta do mundo!',
                    ),
                    const SizedBox(height: 16),
                    _buildTrailCard(
                      '🌊',
                      'Oceano Profundo',
                      'Exploração e Descobertas',
                      const Color(0xFF007BFF),
                      'Mergulhe nas profundezas marinhas!',
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: _buildTrailCard(
                        '🌲',
                        'Floresta\nAmazônica',
                        'Sobrevivência e\nMatemática',
                        const Color(0xFF00C851),
                        'Explore a maior floresta do mundo!',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTrailCard(
                        '🌊',
                        'Oceano\nProfundo',
                        'Exploração e\nDescobertas',
                        const Color(0xFF007BFF),
                        'Mergulhe nas profundezas marinhas!',
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 🎨 TRAIL CARD - PREPARADO PARA BACKGROUNDS LEONARDO AI
  Widget _buildTrailCard(String emoji, String title, String subtitle,
      Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        // 🔮 FUTURO LEONARDO AI BACKGROUND:
        // image: DecorationImage(
        //   image: NetworkImage(trailBackgroundUrl),
        //   fit: BoxFit.cover,
        //   colorFilter: ColorFilter.mode(
        //     color.withValues(alpha: 0.8),
        //     BlendMode.multiply,
        //   ),
        // ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📊 PROFILE ITEM
  Widget _buildProfileItem(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF00C851).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]!,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800]!,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏆 MOTIVATION ICON
  Widget _buildMotivationIcon(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF00C851).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00C851),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 🔧 HELPER METHODS
  String _getEducationLevelText(EducationLevel? level) {
    switch (level) {
      case EducationLevel.fundamental6:
        return '6º ano Fundamental';
      case EducationLevel.fundamental7:
        return '7º ano Fundamental';
      case EducationLevel.fundamental8:
        return '8º ano Fundamental';
      case EducationLevel.fundamental9:
        return '9º ano Fundamental';
      case EducationLevel.medio1:
        return '1º ano Médio';
      case EducationLevel.medio2:
        return '2º ano Médio';
      case EducationLevel.medio3:
        return '3º ano Médio';
      case EducationLevel.completed:
        return 'Ensino Médio Completo';
      default:
        return 'Não informado';
    }
  }

  String _getStudyGoalText(StudyGoal? goal) {
    switch (goal) {
      case StudyGoal.improveGrades:
        return 'Melhorar notas';
      case StudyGoal.enemPrep:
        return 'Preparação ENEM';
      case StudyGoal.specificUniversity:
        return 'Universidade específica';
      case StudyGoal.exploreAreas:
        return 'Explorar áreas';
      case StudyGoal.undecided:
        return 'Ainda decidindo';
      default:
        return 'Não informado';
    }
  }

  String _getInterestAreaText(ProfessionalTrail? area) {
    switch (area) {
      case ProfessionalTrail.linguagens:
        return 'Linguagens';
      case ProfessionalTrail.cienciasNatureza:
        return 'Ciências da Natureza';
      case ProfessionalTrail.matematicaTecnologia:
        return 'Matemática e Tecnologia';
      case ProfessionalTrail.humanas:
        return 'Ciências Humanas';
      case ProfessionalTrail.negocios:
        return 'Negócios';
      case ProfessionalTrail.descobrindo:
        return 'Ainda descobrindo';
      default:
        return 'Não informado';
    }
  }

  void _finalizarOnboarding(BuildContext context) {
    // 🚀 NAVEGAR PARA HOME/TRILHAS
    context.go('/home');
  }
}
