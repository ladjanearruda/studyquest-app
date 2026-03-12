import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/avatar.dart';
import 'dart:convert';
import 'dart:math' as math;

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
  String? behavioralAspect; // 🆕 CAMPO NOVO ADICIONADO
  String? studyStyle;
  AvatarType? selectedAvatarType;
  AvatarGender? selectedAvatarGender;

  // Construtor padrão (mantém compatibilidade)
  OnboardingData();

  // ===== SERIALIZAÇÃO =====

  Map<String, dynamic> toJson() => {
        'name': name,
        'educationLevel': educationLevel?.name,
        'studyGoal': studyGoal?.name,
        'interestArea': interestArea?.name,
        'dreamUniversity': dreamUniversity,
        'studyTime': studyTime,
        'mainDifficulty': mainDifficulty,
        'behavioralAspect': behavioralAspect,
        'studyStyle': studyStyle,
        'selectedAvatarType': selectedAvatarType?.name,
        'selectedAvatarGender': selectedAvatarGender?.name,
      };

  static OnboardingData fromJson(Map<String, dynamic> json) {
    final data = OnboardingData();
    data.name = json['name'] as String?;
    data.educationLevel = json['educationLevel'] != null
        ? EducationLevel.values.firstWhere(
            (e) => e.name == json['educationLevel'],
            orElse: () => EducationLevel.medio1,
          )
        : null;
    data.studyGoal = json['studyGoal'] != null
        ? StudyGoal.values.firstWhere(
            (e) => e.name == json['studyGoal'],
            orElse: () => StudyGoal.improveGrades,
          )
        : null;
    data.interestArea = json['interestArea'] != null
        ? ProfessionalTrail.values.firstWhere(
            (e) => e.name == json['interestArea'],
            orElse: () => ProfessionalTrail.cienciasNatureza,
          )
        : null;
    data.dreamUniversity = json['dreamUniversity'] as String?;
    data.studyTime = json['studyTime'] as String?;
    data.mainDifficulty = json['mainDifficulty'] as String?;
    data.behavioralAspect = json['behavioralAspect'] as String?;
    data.studyStyle = json['studyStyle'] as String?;
    data.selectedAvatarType = json['selectedAvatarType'] != null
        ? AvatarType.values.firstWhere(
            (e) => e.name == json['selectedAvatarType'],
            orElse: () => AvatarType.explorador,
          )
        : null;
    data.selectedAvatarGender = json['selectedAvatarGender'] != null
        ? AvatarGender.values.firstWhere(
            (e) => e.name == json['selectedAvatarGender'],
            orElse: () => AvatarGender.masculino,
          )
        : null;
    return data;
  }

  // ✅ NOVO: Método copyWith para atualizações seguras
  OnboardingData copyWith({
    String? name,
    EducationLevel? educationLevel,
    StudyGoal? studyGoal,
    ProfessionalTrail? interestArea,
    String? dreamUniversity,
    String? studyTime,
    String? mainDifficulty,
    String? behavioralAspect, // 🆕 PARÂMETRO NOVO

    String? studyStyle,
    AvatarType? selectedAvatarType,
    AvatarGender? selectedAvatarGender,
  }) {
    final newState = OnboardingData();
    newState.name = name ?? this.name;
    newState.educationLevel = educationLevel ?? this.educationLevel;
    newState.studyGoal = studyGoal ?? this.studyGoal;
    newState.interestArea = interestArea ?? this.interestArea;
    newState.dreamUniversity = dreamUniversity ?? this.dreamUniversity;
    newState.studyTime = studyTime ?? this.studyTime;
    newState.mainDifficulty = mainDifficulty ?? this.mainDifficulty;
    newState.behavioralAspect =
        behavioralAspect ?? this.behavioralAspect; // 🆕 LINHA NOVA

    newState.studyStyle = studyStyle ?? this.studyStyle;
    newState.selectedAvatarType = selectedAvatarType ?? this.selectedAvatarType;
    newState.selectedAvatarGender =
        selectedAvatarGender ?? this.selectedAvatarGender;
    return newState;
  }
}

// ===== ENUMS PARA MODO DESCOBERTA (ADICIONAR NO TOPO DO ARQUIVO) =====

enum MetodoNivelamento { manual, descoberta }

enum NivelHabilidade {
  iniciante('Iniciante', '🌱', 'Aprendendo o básico'),
  intermediario('Intermediário', '🌿', 'Já domino algumas coisas'),
  avancado('Avançado', '🌳', 'Estou bem preparado(a)');

  const NivelHabilidade(this.nome, this.emoji, this.descricao);
  final String nome;
  final String emoji;
  final String descricao;
}

// ===== PROVIDER COM PERSISTÊNCIA =====

const _kOnboardingDataKey = 'studyquest_onboarding_data';

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(OnboardingData()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kOnboardingDataKey);
      if (raw != null) {
        final data = OnboardingData.fromJson(json.decode(raw) as Map<String, dynamic>);
        state = data;
        print('📦 Onboarding restaurado do SharedPreferences (nome: ${data.name})');
      }
    } catch (e) {
      print('⚠️ Erro ao carregar onboarding: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kOnboardingDataKey, json.encode(state.toJson()));
    } catch (e) {
      print('⚠️ Erro ao salvar onboarding: $e');
    }
  }

  /// Compatível com o padrão StateProvider: `ref.read(onboardingProvider.notifier).update((s) => ...)`
  void update(OnboardingData Function(OnboardingData) updater) {
    state = updater(state);
    _saveToPrefs();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>(
  (ref) => OnboardingNotifier(),
);

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
                        'Passo 1 de 9',
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
                                      return state.copyWith(
                                        name: value.trim().isEmpty
                                            ? null
                                            : value.trim(),
                                      );
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
// ===== TELA 1 NÍVEL EDUCACIONAL - VERSÃO CORRIGIDA SEM OVERFLOW =====

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
                        'Passo 2 de 9',
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
                                const SizedBox(height: 12),
                                const Text(
                                  'Em que ano você está?',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32)),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
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

                    const SizedBox(height: 20),

                    // ✅ GRID 4x2 MANTIDO + PROTEÇÃO OVERFLOW
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 48,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width > 600
                              ? MediaQuery.of(context).size.width -
                                  48 // Desktop: largura total
                              : 600, // Mobile: largura mínima para grid
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // ✅ MANTÉM 4 COLUNAS
                              childAspectRatio:
                                  1.15, // ✅ REDUZIDO DE 1.2 → 1.15 (cards mais baixos)
                              mainAxisSpacing: 10, // ✅ REDUZIDO DE 12 → 10
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
                                        0,
                                        20 *
                                            (1 - _cardAnimations[index].value)),
                                    child: Opacity(
                                      opacity: _cardAnimations[index].value,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? levelData.color
                                                  .withValues(alpha: 0.1)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                              blurRadius: isSelected
                                                  ? 6
                                                  : 4, // ✅ REDUZIDO DE 8 → 6
                                              offset: Offset(
                                                  0,
                                                  isSelected
                                                      ? 2
                                                      : 1), // ✅ REDUZIDO DE 3 → 2
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            onTap: () {
                                              ref
                                                  .read(onboardingProvider
                                                      .notifier)
                                                  .update((state) {
                                                final newState =
                                                    OnboardingData();
                                                newState.name = state.name;
                                                newState.educationLevel =
                                                    levelData.level;
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
                                                    state.studyStyle;
                                                return newState;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  10), // ✅ REDUZIDO DE 12 → 10
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize
                                                    .min, // ✅ FORÇA TAMANHO MÍNIMO
                                                children: [
                                                  Stack(
                                                    children: [
                                                      AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        width: isSelected
                                                            ? 38
                                                            : 34, // ✅ REDUZIDO
                                                        height: isSelected
                                                            ? 38
                                                            : 34, // ✅ REDUZIDO
                                                        decoration:
                                                            BoxDecoration(
                                                          color: levelData.color
                                                              .withValues(
                                                                  alpha: 0.15),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child:
                                                              AnimatedDefaultTextStyle(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        200),
                                                            style: TextStyle(
                                                                fontSize: isSelected
                                                                    ? 18
                                                                    : 16), // ✅ REDUZIDO
                                                            child: Text(
                                                                levelData
                                                                    .emoji),
                                                          ),
                                                        ),
                                                      ),
                                                      if (isSelected)
                                                        Positioned(
                                                          top: -2,
                                                          right: -2,
                                                          child:
                                                              AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        200),
                                                            width:
                                                                16, // ✅ REDUZIDO DE 18
                                                            height:
                                                                16, // ✅ REDUZIDO DE 18
                                                            decoration:
                                                                BoxDecoration(
                                                              color: levelData
                                                                  .color,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 2),
                                                            ),
                                                            child: const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size:
                                                                    10), // ✅ REDUZIDO DE 12
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                          6), // ✅ REDUZIDO DE 8
                                                  Flexible(
                                                    // ✅ ADICIONA FLEXIBLE
                                                    child: Text(
                                                      levelData.title,
                                                      style: TextStyle(
                                                        fontSize:
                                                            14, // ✅ REDUZIDO DE 16
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? levelData.color
                                                            : Colors.black87,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                          1), // ✅ REDUZIDO DE 2
                                                  Flexible(
                                                    // ✅ ADICIONA FLEXIBLE
                                                    child: Text(
                                                      levelData.subtitle,
                                                      style: TextStyle(
                                                        fontSize:
                                                            11, // ✅ REDUZIDO DE 13
                                                        color: isSelected
                                                            ? levelData.color
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : Colors.grey[600]!,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
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
                        ),
                      ),
                    ),

                    const SizedBox(height: 12), // ✅ REDUZIDO DE 16

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

                    const SizedBox(height: 16), // ✅ REDUZIDO DE 20
                  ],
                ),
              ),
            ),

            // BOTÃO
            Container(
              padding: const EdgeInsets.all(20.0), // ✅ REDUZIDO DE 24
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

// // ===== TELA 2 OBJETIVOS PREMIUM - VERSÃO CORRIGIDA =====
// 🎯 CORREÇÕES APLICADAS:
// ✅ Cores únicas (sem duplicatas lilás) - conforme protótipo
// ✅ CTA padrão falando da próxima tela
// ✅ Corrigido withOpacity() deprecated
// ✅ Botão igual outras telas

class Tela2ObjetivoPrincipal extends ConsumerStatefulWidget {
  const Tela2ObjetivoPrincipal({super.key});

  @override
  ConsumerState<Tela2ObjetivoPrincipal> createState() =>
      _Tela2ObjetivoPrincipalState();
}

class _Tela2ObjetivoPrincipalState extends ConsumerState<Tela2ObjetivoPrincipal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ✅ CORREÇÃO: Variável agora sincroniza com provider
  String? selectedGoal;

  @override
  void initState() {
    super.initState();

    // ✅ CORREÇÃO 1: Sincronizar com provider ao inicializar
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.studyGoal != null) {
      selectedGoal = onboardingState.studyGoal.toString().split('.').last;
    }

    // Inicializar animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ CORREÇÃO 2: Método de seleção atualizado
  void _selectGoal(StudyGoal goal) {
    setState(() {
      selectedGoal = goal.toString().split('.').last;
    });

    // ✅ CORREÇÃO: Salvar no provider imediatamente
    ref.read(onboardingProvider.notifier).update((state) {
      return state.copyWith(
        studyGoal: goal,
      );
    });
  }

  // ✅ CORREÇÃO 3: Verificação de seleção corrigida
  bool get hasSelection => selectedGoal != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER PADRONIZADO (igual outras telas)
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
                        'Passo 3 de 9',
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
                            MediaQuery.of(context).size.width * (3 / 9) * 0.86,
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

            // CONTEÚDO PRINCIPAL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // TÍTULO E SUBTÍTULO
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '🎯 Qual é seu principal\nobjetivo?',
                            style: TextStyle(
                              fontSize: 28, // ✅ H1 padrão das outras telas
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Escolha seu foco principal. Você poderá explorar outros objetivos depois!',
                            style: TextStyle(
                              fontSize: 16, // ✅ Body padrão das outras telas
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ✅ LISTA DE OBJETIVOS (CORES ÚNICAS - CONFORME PROTÓTIPO)
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: _goals.map((goal) {
                            final isSelected = selectedGoal ==
                                goal.goal.toString().split('.').last;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? goal.color.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? goal.color
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? goal.color.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: isSelected ? 8 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () => _selectGoal(goal.goal),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    children: [
                                      // ÍCONE/EMOJI (48x48px mínimo para touch)
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? goal.color
                                              : Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            goal.emoji,
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 24),

                                      // TEXTOS
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              goal.title,
                                              style: TextStyle(
                                                fontSize:
                                                    20, // ✅ cardTitle = 20px
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? goal.color
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              goal.subtitle,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              goal.description,
                                              style: TextStyle(
                                                fontSize: 16, // ✅ body1 = 16px
                                                fontWeight: FontWeight.w400,
                                                color: isSelected
                                                    ? goal.color
                                                        .withValues(alpha: 0.8)
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ✅ RADIO BUTTON (seleção única)
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? goal.color
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? goal.color
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ FEEDBACK DE SUCESSO (igual outras telas)
                    AnimatedOpacity(
                      opacity: hasSelection ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: hasSelection
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green[50]!,
                                    Colors.green[100]!.withValues(alpha: 0.3)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.green[200]!, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.green[600]!,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Perfeito! Objetivo definido! 🎯',
                                      style: TextStyle(
                                        color: Colors.green[700]!,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ✅ BOTÃO PRINCIPAL PADRONIZADO (igual outras telas)
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
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
                            ? 'Vamos às áreas! 🧭' // ✅ Fala da próxima tela (igual outras)
                            : 'Escolha seu objetivo principal',
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

  // ✅ DADOS DOS OBJETIVOS (mantém como estava)
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
      subtitle: 'Foco no vestibular',
      color: Colors.purple,
      description: 'Tenho uma universidade dos sonhos e vou conquistar!',
    ),
    StudyGoalData(
      goal: StudyGoal.exploreAreas,
      emoji: '🔍',
      title: 'Explorar Áreas',
      subtitle: 'Descobrir vocações',
      color: Colors.green,
      description:
          'Quero conhecer diferentes áreas para descobrir minha paixão',
    ),
    StudyGoalData(
      goal: StudyGoal.undecided,
      emoji: '🤔',
      title: 'Ainda não sei',
      subtitle: 'Vou descobrindo',
      color: Colors.grey,
      description: 'Ainda estou explorando minhas opções e interesses',
    ),
  ];
}

// CLASSE DE DADOS PARA OS CARDS
class GoalData {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  GoalData({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

// ===== TELAS 3-7 RESTANTES =====
// ===== TELA 3 ÁREA DE INTERESSE - UX REFINADA =====
// ✅ APLICADO: Pesquisa UX + Tipografia melhorada + Layout responsivo
// ✅ CORRIGIDO: fontSize descriptions 13→16px + espaçamentos + cores

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

  // ✅ CORREÇÃO: Adicionar estado local (padrão Tela 2)
  ProfessionalTrail? _selectedArea;

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
      color: Colors.grey[600]!,
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

    // ✅ CORREÇÃO: Inicializar estado local com provider (padrão Tela 2)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboarding = ref.read(onboardingProvider);
      if (onboarding.interestArea != null && mounted) {
        setState(() {
          _selectedArea = onboarding.interestArea;
        });
      }
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
    // ✅ CORREÇÃO: Usar estado local (padrão Tela 2)
    final hasSelection = _selectedArea != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER PADRONIZADO
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
                        'Passo 4 de 9',
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
                                Text('🧭',
                                    style: TextStyle(
                                        fontSize: 50 * _heroAnimation.value)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Qual área desperta\nseu interesse?',
                                  style: TextStyle(
                                    fontSize: 26, // ✅ H1 PADRÃO
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Escolha sua direção acadêmica! 🌟', // ✅ TEXTO ATUALIZADO
                                  style: TextStyle(
                                      fontSize: 16, // ✅ BODY1 PADRÃO
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

                    // ✅ LISTA DE ÁREAS (LAYOUT VERTICAL MANTIDO)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _areas.length,
                      itemBuilder: (context, index) {
                        final areaData = _areas[index];
                        // ✅ CORREÇÃO: Usar estado local (padrão Tela 2)
                        final isSelected = _selectedArea == areaData.trail;

                        return AnimatedBuilder(
                          animation: _buttonAnimations[index],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  40 * (1 - _buttonAnimations[index].value), 0),
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
                                          setState(() {
                                            _selectedArea = areaData.trail;
                                          });

                                          ref
                                              .read(onboardingProvider.notifier)
                                              .update((state) {
                                            return state.copyWith(
                                              interestArea: areaData.trail,
                                            );
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              // ✅ EMOJI + CHECK ICON
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

                                              // ✅ TEXTO PRINCIPAL (FONTES CORRIGIDAS)
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      areaData.title,
                                                      style: TextStyle(
                                                        fontSize:
                                                            20, // ✅ CARD TITLE PADRÃO
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
                                                        fontSize:
                                                            15, // ✅ SUBTITLE PADRÃO
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
                                                        fontSize:
                                                            16, // ✅ CORRIGIDO: 13→16px
                                                        color: Colors
                                                            .grey.shade600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // ✅ RADIO BUTTON
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

                    // 1️⃣ CORREÇÃO DO FEEDBACK DE SUCESSO:
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
                                    ? 'Ótima escolha! Agora vamos definir sua universidade dos sonhos! 🏛️' // ✅ CORRIGIDO
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

            // ✅ BOTÃO FOOTER PADRONIZADO
            // 2️⃣ CORREÇÃO DO BOTÃO PRINCIPAL:
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
                        hasSelection
                            ? 'Vamos às universidades! 🏛️' // ✅ CORRIGIDO - PADRÃO
                            : 'Escolha uma área',
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
// ===== TELA 4 UNIVERSIDADE DOS SONHOS - PROTÓTIPO UX PREMIUM =====
// ✅ Seguindo padrões das Telas 1, 2, 3 e 8
// ✅ Aplicando recomendações da pesquisa UX
// ✅ Cores individuais por universidade (harmonioso)
// ✅ Lista completa com categorização visual
// ✅ Layout responsivo e animações suaves

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

  // ✅ LISTA COMPLETA EM ORDEM ALFABÉTICA DENTRO DE CADA CATEGORIA
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
      fullName: 'Estou explorando as opções disponíveis',
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    // ✅ ANIMAÇÃO ESCALONADA PARA LISTA
    _cardAnimations = List.generate(_universities.length, (index) {
      final double startInterval = (index * 0.02).clamp(0.0, 0.8);
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
            // ✅ PROGRESS HEADER PADRONIZADO (igual Telas 1, 2, 3)
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
                        'Passo 5 de 9',
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

                    // ✅ HERO SECTION ANIMADO (padrão das outras telas)
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
                                    fontSize: 26, // ✅ H1 padrão
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Todo grande sonho começa com um objetivo! 🌟',
                                  style: TextStyle(
                                    fontSize: 16, // ✅ Body1 padrão
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
                    ),

                    const SizedBox(height: 32),

                    // ✅ LISTA DE UNIVERSIDADES COM CORES INDIVIDUAIS
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
                                            return state.copyWith(
                                              dreamUniversity:
                                                  universityData.name,
                                            );
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // ✅ EMOJI + CATEGORIA COM COR INDIVIDUAL
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

                                              // ✅ TEXTO PRINCIPAL
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
                                                        // ✅ TAG CATEGORIA COM COR DA UNIVERSIDADE
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
                                                        fontSize:
                                                            14, // ✅ UX: Legibilidade
                                                        color: Colors
                                                            .grey.shade600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // ✅ RADIO BUTTON COM COR INDIVIDUAL
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

                    // ✅ FEEDBACK VISUAL DE SUCESSO (padrão das outras telas)
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
                                shape: BoxShape.circle,
                              ),
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

            // ✅ BOTÃO FOOTER PADRONIZADO (igual outras telas)
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
// ===== TELA 5 TEMPO DE ESTUDO - PROTÓTIPO UX PREMIUM =====
// ✅ Seguindo padrões das Telas 1, 2, 3, 4 e 8
// ✅ Aplicando melhorias da pesquisa UX
// ✅ fontSize description 13 → 15px (legibilidade)
// ✅ Cards detalhados com informações completas
// ✅ Layout responsivo e animações suaves

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

  // ✅ OPÇÕES DE TEMPO COM TAGS HÍBRIDAS (GAMIFICAÇÃO EDUCACIONAL SÉRIA)
  final List<StudyTimeData> _timeOptions = [
    StudyTimeData(
      time: '15-30 minutos',
      emoji: '⚡',
      title: '15-30 min',
      subtitle: 'Sessões estratégicas',
      description:
          'Perfeito para quem tem rotina corrida e quer aproveitar pequenos intervalos',
      recommendation: 'Sessões estratégicas - revisões de alta retenção',
      color: Colors.green,
    ),
    StudyTimeData(
      time: '30-60 minutos',
      emoji: '🎯',
      title: '30-60 min',
      subtitle: 'Zona de domínio',
      description:
          'Tempo ideal para a maioria dos estudantes - equilibra profundidade e concentração',
      recommendation: 'Zona de domínio - aprofundamento e prática',
      color: Colors.blue,
    ),
    StudyTimeData(
      time: '1-2 horas',
      emoji: '🔥',
      title: '1-2 horas',
      subtitle: 'Modo intensivo',
      description:
          'Para quem quer acelerar o aprendizado e tem disponibilidade para sessões longas',
      recommendation: 'Modo intensivo - simulados e questões avançadas',
      color: Colors.orange,
    ),
    StudyTimeData(
      time: 'Mais de 2 horas',
      emoji: '🏆',
      title: 'Mais de 2h',
      subtitle: 'Preparação de elite',
      description:
          'Para conquistas extraordinárias e preparação intensiva para vestibulares',
      recommendation: 'Preparação de elite - aprovação garantida',
      color: Colors.purple,
    ),
    StudyTimeData(
      time: 'Varia conforme o dia',
      emoji: '📅',
      title: 'Tempo flexível',
      subtitle: 'IA personalizada',
      description:
          'Alguns dias mais tempo, outros menos - o app se adapta à sua rotina',
      recommendation: 'IA personalizada - otimiza seu tempo disponível',
      color: Colors.teal,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    // ✅ ANIMAÇÃO ESCALONADA PARA CARDS
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
            // ✅ PROGRESS HEADER PADRONIZADO (igual outras telas)
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
                        'Passo 6 de 9',
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

                    // ✅ HERO SECTION ANIMADO (padrão das outras telas)
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
                                    fontSize: 26, // ✅ H1 padrão
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Vamos personalizar sua jornada de acordo com seu tempo! 📚',
                                  style: TextStyle(
                                    fontSize: 16, // ✅ Body1 padrão
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
                    ),

                    const SizedBox(height: 32),

                    // ✅ LISTA DE OPÇÕES DE TEMPO COM MELHORIAS UX
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
                                            return state.copyWith(
                                              studyTime: timeData.time,
                                            );
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              // ✅ EMOJI + INDICADOR VISUAL MELHORADO
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

                                              // ✅ TEXTO PRINCIPAL COM HIERARQUIA MELHORADA
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      timeData.title,
                                                      style: TextStyle(
                                                        fontSize:
                                                            20, // ✅ Card title padrão
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
                                                        fontSize:
                                                            15, // ✅ Subtitle padrão
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
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      timeData.description,
                                                      style: TextStyle(
                                                        fontSize:
                                                            15, // ✅ UX: 13→15px (legibilidade)
                                                        color: Colors
                                                            .grey.shade600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // ✅ TAG DE RECOMENDAÇÃO VISUAL
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: timeData.color
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .lightbulb_outline,
                                                              color: timeData
                                                                  .color,
                                                              size: 16),
                                                          const SizedBox(
                                                              width: 6),
                                                          Flexible(
                                                            child: Text(
                                                              timeData
                                                                  .recommendation,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: timeData
                                                                    .color,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // ✅ RADIO BUTTON
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

                    // ✅ FEEDBACK VISUAL DE SUCESSO (padrão das outras telas)
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
                                shape: BoxShape.circle,
                              ),
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

            // ✅ BOTÃO FOOTER PADRONIZADO (igual outras telas)
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
// ===== TELA 6 DIFICULDADES - PROTÓTIPO SELEÇÃO DUPLA PREMIUM =====
// ✅ Seguindo padrões das Telas 1-5
// ✅ Sistema inovador de seleção dupla: Matéria + Comportamento
// ✅ Layout em seções separadas (chips + lista)
// ✅ Feedback dinâmico combinado
// ✅ fontSize melhorado: 11px → 13px (UX)

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

  // ✅ MATÉRIAS COM CORES DISTINTAS (CHIPS)
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

  // ✅ ASPECTOS COMPORTAMENTAIS COM DESCRIÇÕES (LISTA)
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    // ✅ ANIMAÇÃO PARA 2 SEÇÕES
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

  // ===== CORREÇÃO: SALVAR SELEÇÃO SEPARADA =====
  void _saveSelection() {
    // ✅ Normalizar matéria selecionada
    final selectedSubjectNormalized = selectedSubject != null
        ? _normalizeSubjectName(selectedSubject!)
        : null;

    // ✅ Normalizar aspecto comportamental selecionado
    final selectedBehaviorNormalized = selectedBehavior != null
        ? _normalizeBehaviorName(selectedBehavior!)
        : null;

    // ✅ Salvar SEPARADAMENTE no provider
    ref.read(onboardingProvider.notifier).update((state) {
      return state.copyWith(
        mainDifficulty: selectedSubjectNormalized, // SÓ a matéria
        behavioralAspect: selectedBehaviorNormalized, // SÓ o aspecto
      );
    });
  }

  // ===== MÉTODO AUXILIAR 1: Normalizar Matéria =====
  String _normalizeSubjectName(String subject) {
    const Map<String, String> materiaMapping = {
      'Português e Literatura': 'portugues',
      'Matemática': 'matematica',
      'Física': 'fisica',
      'Química': 'quimica',
      'Biologia': 'biologia',
      'História': 'historia',
      'Geografia': 'geografia',
      'Inglês': 'ingles',
      'Não tenho dificuldade específica em matérias': 'geral',
    };
    return materiaMapping[subject] ?? subject.toLowerCase();
  }

  // ===== MÉTODO AUXILIAR 2: Normalizar Aspecto Comportamental =====
  String _normalizeBehaviorName(String behavior) {
    const Map<String, String> aspectMapping = {
      'Foco e concentração': 'foco_concentracao',
      'Memorização e fixação': 'memorizacao_fixacao',
      'Motivação para estudar': 'motivacao_estudar',
      'Ansiedade em provas': 'ansiedade_provas',
      'Raciocínio lógico': 'raciocinio_logico',
      'Organização dos estudos': 'organizacao_estudos',
      'Interpretação de texto': 'interpretacao_texto',
      'Não tenho dificuldades comportamentais': 'sem_dificuldade',
    };
    return aspectMapping[behavior] ?? behavior.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedSubject != null && selectedBehavior != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER PADRONIZADO (igual outras telas)
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
                        'Passo 7 de 9',
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

                    // ✅ HERO SECTION ANIMADO (padrão das outras telas)
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
                                    fontSize: 26, // ✅ H1 padrão
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Escolha uma matéria e um aspecto comportamental! 🧠',
                                  style: TextStyle(
                                    fontSize: 16, // ✅ Body1 padrão
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
                    ),

                    const SizedBox(height: 32),

                    // ✅ SEÇÃO 1: MATÉRIAS (CHIPS)
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
                                  // Header da seção
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

                                  // ✅ CHIPS DE MATÉRIAS
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

                    // ✅ SEÇÃO 2: ASPECTOS COMPORTAMENTAIS (LISTA)
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
                                  // Header da seção
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

                                  // ✅ LISTA DE COMPORTAMENTOS
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
                                                          fontSize:
                                                              16, // ✅ UX: 14→16px
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
                                                          fontSize:
                                                              13, // ✅ UX: 11→13px
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

                    // ✅ FEEDBACK COMBINADO DINÂMICO
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
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.psychology,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hasSelection
                                    ? 'Perfeito! Combinação identificada: ${_getSubjectTitle(selectedSubject!)} + ${_getBehaviorTitle(selectedBehavior!)}! 🎯'
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

            // ✅ BOTÃO FOOTER PADRONIZADO (igual outras telas)
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
                            : 'Escolha matéria e aspecto', // ✅ CORRIGIDO: "e" minúsculo
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

  // ✅ HELPERS PARA FEEDBACK DINÂMICO
  String _getSubjectTitle(String subject) {
    final subjectData = _subjects.firstWhere((s) => s.subject == subject);
    return subjectData.title;
  }

  String _getBehaviorTitle(String behavior) {
    final behaviorData = _behaviors.firstWhere((b) => b.behavior == behavior);
    return behaviorData.title;
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

@immutable
class DescobertaNivelState {
  const DescobertaNivelState({
    this.metodoEscolhido,
    this.nivelManual,
    this.completado = false,
  });

  final MetodoNivelamento? metodoEscolhido;
  final NivelHabilidade? nivelManual;
  final bool completado;

  DescobertaNivelState copyWith({
    MetodoNivelamento? metodoEscolhido,
    NivelHabilidade? nivelManual,
    bool? completado,
  }) {
    return DescobertaNivelState(
      metodoEscolhido: metodoEscolhido ?? this.metodoEscolhido,
      nivelManual: nivelManual ?? this.nivelManual,
      completado: completado ?? this.completado,
    );
  }
}

final descobertaNivelProvider =
    StateNotifierProvider<DescobertaNivelNotifier, DescobertaNivelState>(
  (ref) => DescobertaNivelNotifier(),
);

class DescobertaNivelNotifier extends StateNotifier<DescobertaNivelState> {
  DescobertaNivelNotifier() : super(const DescobertaNivelState());

  void selecionarMetodo(MetodoNivelamento metodo) {
    state = state.copyWith(
      metodoEscolhido: metodo,
      nivelManual:
          metodo == MetodoNivelamento.descoberta ? null : state.nivelManual,
    );
  }

  void selecionarNivelManual(NivelHabilidade nivel) {
    state = state.copyWith(nivelManual: nivel);
  }

  void resetar() {
    state = const DescobertaNivelState();
  }
}

// TELA 7

class Tela7EstiloEstudo extends ConsumerStatefulWidget {
  const Tela7EstiloEstudo({super.key});

  @override
  ConsumerState<Tela7EstiloEstudo> createState() => _Tela7EstiloEstudoState();
}

class _Tela7EstiloEstudoState extends ConsumerState<Tela7EstiloEstudo>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late AnimationController _transitionController;
  late Animation<double> _heroAnimation;
  late List<Animation<double>> _cardAnimations;
  late Animation<Offset> _slideAnimation;

  // ✅ CONTROLE DE ETAPAS
  int etapaAtual = 1; // 1 = Estilo de Estudo, 2 = Modo Descoberta

  // ✅ ESTADO LOCAL PARA ESTILO DE ESTUDO
  String? estiloSelecionado;

  // ✅ DADOS DOS ESTILOS
  final List<StudyStyleData> _styles = [
    StudyStyleData(
      style: 'Sozinho(a) e no meu ritmo',
      emoji: '🧘‍♂️',
      title: 'Focado',
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
      description:
          'Tenho mais motivação quando comparo meu desempenho com outros',
      benefits: [
        'Estímulo da competição',
        'Networking',
        'Reconhecimento público'
      ],
      gameFeatures: 'Ranking global, desafios multiplayer, torneios',
      color: Colors.orange,
    ),
    StudyStyleData(
      style: 'Em grupos de estudo',
      emoji: '👥',
      title: 'Colaborativo',
      subtitle: 'Aprender Junto',
      description:
          'Aprendo melhor compartilhando conhecimento e tirando dúvidas em grupo',
      benefits: [
        'Troca de experiências',
        'Apoio mútuo',
        'Diferentes perspectivas'
      ],
      gameFeatures: 'Grupos de estudo, chat, projetos colaborativos',
      color: Colors.green,
    ),
    StudyStyleData(
      style: 'Com metas e desafios',
      emoji: '🎯',
      title: 'Desafiador',
      subtitle: 'Objetivos Claros',
      description:
          'Preciso de objetivos bem definidos e desafios para me manter motivado',
      benefits: ['Propósito claro', 'Senso de conquista', 'Evolução constante'],
      gameFeatures: 'Sistema de conquistas, badges, missões especiais',
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOut,
    ));

    // ✅ CORRIGIDO: Intervalos válidos para animações
    _cardAnimations = List.generate(
      _styles.length,
      (index) {
        final start = (index * 0.1).clamp(0.0, 0.6);
        final end = (0.4 + index * 0.1).clamp(start + 0.1, 1.0);

        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _cardsController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ));
      },
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _heroController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _cardsController.forward();
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _irParaProximaEtapa() {
    setState(() {
      etapaAtual = 2;
    });
    _transitionController.forward();
  }

  void _voltarEtapaAnterior() {
    if (etapaAtual == 2) {
      setState(() {
        etapaAtual = 1;
      });
      _transitionController.reverse();
    } else {
      context.go('/onboarding/6');
    }
  }

  @override
  Widget build(BuildContext context) {
    final descobertaState = ref.watch(descobertaNivelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ PROGRESS HEADER
            _buildProgressHeader(),

            // ✅ CONTEÚDO PRINCIPAL (TROCA ENTRE ETAPAS)
            Expanded(
              child: etapaAtual == 1
                  ? _buildEstiloEstudoPage()
                  : _buildModoDescobertaPage(descobertaState),
            ),

            // ✅ BOTÃO DINÂMICO
            _buildBottomCTA(_getBotaoHabilitado(descobertaState)),
          ],
        ),
      ),
    );
  }

  // ===== PROGRESS HEADER CORRIGIDO =====
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _voltarEtapaAnterior,
                icon: Icon(Icons.arrow_back_ios,
                    color: Colors.green[700]!, size: 20),
              ),
              Text(
                etapaAtual == 1
                    ? 'Passo 8 de 9'
                    : 'Passo 9 de 9', // ✅ CORRIGIDO
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
                width: MediaQuery.of(context).size.width *
                    (etapaAtual == 1 ? (7 / 9) : (8 / 9)) *
                    0.86, // ✅ CORRIGIDO
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

  // ===== ETAPA 1: ESTILO DE ESTUDO =====
  Widget _buildEstiloEstudoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ✅ HERO SECTION
          AnimatedBuilder(
            animation: _heroAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _heroAnimation.value,
                child: Opacity(
                  opacity: _heroAnimation.value,
                  child: const Column(
                    children: [
                      Text('🎓', style: TextStyle(fontSize: 50)),
                      SizedBox(height: 16),
                      Text(
                        'Qual seu estilo\nde estudo?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vamos personalizar sua experiência! 🚀',
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
          ),

          const SizedBox(height: 32),

          // ✅ LISTA DE ESTILOS
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _styles.length,
            itemBuilder: (context, index) {
              final styleData = _styles[index];
              final isSelected = estiloSelecionado == styleData.style;

              return AnimatedBuilder(
                animation: _cardAnimations[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(40 * (1 - _cardAnimations[index].value), 0),
                    child: Opacity(
                      opacity: _cardAnimations[index].value,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildEstiloCard(styleData, isSelected),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ===== ETAPA 2: MODO DESCOBERTA =====
  Widget _buildModoDescobertaPage(DescobertaNivelState descobertaState) {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ✅ HERO SECTION MODO DESCOBERTA
            const Column(
              children: [
                Text('🧭', style: TextStyle(fontSize: 50)),
                SizedBox(height: 16),
                Text(
                  'Como quer descobrir\nseu nível?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Para personalizar as questões das suas trilhas!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ✅ OPÇÃO MODO DESCOBERTA (RECOMENDADA)
            _buildModoDescobertaCard(
              metodo: MetodoNivelamento.descoberta,
              emoji: '🎮',
              titulo: 'Descobrir jogando!',
              subtitulo: 'Nivelamento automático',
              descricao: '5 questões rápidas do seu nível escolar',
              features: [
                '⚡ 2 minutos',
                '🎯 Súper preciso',
                '🏆 Badge especial'
              ],
              cor: Colors.orange[600]!,
              isRecomendado: true,
              isSelected: descobertaState.metodoEscolhido ==
                  MetodoNivelamento.descoberta,
              state: descobertaState,
            ),

            const SizedBox(height: 16),

            // ✅ OPÇÃO MANUAL
            _buildModoDescobertaCard(
              metodo: MetodoNivelamento.manual,
              emoji: '✋',
              titulo: 'Escolher manualmente',
              subtitulo: 'Autoavaliação simples',
              descricao: 'Você escolhe baseado no que sente',
              features: ['🤔 Reflexivo', '⚡ Rápido', '🔄 Pode mudar depois'],
              cor: Colors.blue[600]!,
              isRecomendado: false,
              isSelected:
                  descobertaState.metodoEscolhido == MetodoNivelamento.manual,
              state: descobertaState,
            ),

            const SizedBox(height: 24),

            // ✅ INTERFACE MANUAL (SE SELECIONADA)
            _buildInterfaceManual(descobertaState),

            // ✅ FEEDBACK DE SELEÇÃO
            _buildFeedbackSelecao(descobertaState),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ===== BUILD CARD ESTILO =====
  Widget _buildEstiloCard(StudyStyleData styleData, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          estiloSelecionado = styleData.style;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? styleData.color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? styleData.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? styleData.color : Colors.black)
                  .withOpacity(0.1),
              blurRadius: isSelected ? 10 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: styleData.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(styleData.emoji,
                      style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        styleData.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected ? styleData.color : Colors.grey[800],
                        ),
                      ),
                      Text(
                        styleData.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: styleData.color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              styleData.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: styleData.benefits
                  .map((benefit) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: styleData.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 12,
                            color: styleData.color.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ===== BUILD CARD MODO DESCOBERTA =====
  Widget _buildModoDescobertaCard({
    required MetodoNivelamento metodo,
    required String emoji,
    required String titulo,
    required String subtitulo,
    required String descricao,
    required List<String> features,
    required Color cor,
    required bool isRecomendado,
    required bool isSelected,
    required DescobertaNivelState state,
  }) {
    return GestureDetector(
      onTap: () =>
          ref.read(descobertaNivelProvider.notifier).selecionarMetodo(metodo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? cor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? cor : Colors.black).withOpacity(0.1),
              blurRadius: isSelected ? 10 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            titulo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? cor : Colors.grey[800],
                            ),
                          ),
                          if (isRecomendado) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[600],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Recomendado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: cor, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: features
                  .map((feature) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 12,
                            color: cor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ===== INTERFACE MANUAL =====
  Widget _buildInterfaceManual(DescobertaNivelState state) {
    if (state.metodoEscolhido != MetodoNivelamento.manual) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Escolha o nível que melhor representa onde você está agora:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...NivelHabilidade.values.map((nivel) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCardNivelManual(nivel, state.nivelManual == nivel),
              )),
        ],
      ),
    );
  }

  Widget _buildCardNivelManual(NivelHabilidade nivel, bool isSelected) {
    return GestureDetector(
      onTap: () => ref
          .read(descobertaNivelProvider.notifier)
          .selecionarNivelManual(nivel),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(nivel.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nivel.nome,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue[800] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nivel.descricao,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[600] : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ===== FEEDBACK DE SELEÇÃO =====
  Widget _buildFeedbackSelecao(DescobertaNivelState state) {
    final hasSelection = state.metodoEscolhido != null &&
        (state.metodoEscolhido == MetodoNivelamento.descoberta ||
            state.nivelManual != null);

    if (!hasSelection) return const SizedBox.shrink();

    String feedbackText;
    if (state.metodoEscolhido == MetodoNivelamento.manual &&
        state.nivelManual != null) {
      feedbackText =
          'Nível ${state.nivelManual!.nome} selecionado! Vamos personalizar suas questões! 🎯';
    } else if (state.metodoEscolhido == MetodoNivelamento.descoberta) {
      feedbackText =
          'Excelente escolha! O modo descoberta vai identificar seu nível com precisão! 🎮';
    } else {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: hasSelection ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green[50]!,
              Colors.green[100]!.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feedbackText,
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== VERIFICAR SE BOTÃO ESTÁ HABILITADO =====
  bool _getBotaoHabilitado(DescobertaNivelState descobertaState) {
    if (etapaAtual == 1) {
      // Etapa 1: Estilo de estudo deve estar selecionado
      return estiloSelecionado != null;
    } else {
      // Etapa 2: Método deve estar escolhido E se for manual, nível deve estar selecionado
      return descobertaState.metodoEscolhido != null &&
          (descobertaState.metodoEscolhido == MetodoNivelamento.descoberta ||
              descobertaState.nivelManual != null);
    }
  }

  // ===== BOTÃO BOTTOM CTA =====
  Widget _buildBottomCTA(bool botaoHabilitado) {
    String textoEtapa1 =
        botaoHabilitado ? 'Descobrir meu nível! 🧭' : 'Escolha seu estilo';
    String textoEtapa2 =
        botaoHabilitado ? 'Finalizar perfil! ✅' : 'Escolha um método';

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: botaoHabilitado ? _handleBotaoPrincipal : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  botaoHabilitado ? Colors.green[600]! : Colors.grey[400]!,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: botaoHabilitado ? 4 : 0,
              shadowColor: Colors.green[600]!.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  etapaAtual == 1 ? textoEtapa1 : textoEtapa2,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: botaoHabilitado ? 0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.arrow_forward, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBotaoPrincipal() {
    if (etapaAtual == 1) {
      // Salvar estilo de estudo selecionado no provider de onboarding
      ref.read(onboardingProvider.notifier).update((state) {
        return state.copyWith(
          studyStyle: estiloSelecionado,
        );
      });

      // Ir para etapa 2 (Modo Descoberta)
      _irParaProximaEtapa();
    } else {
      // Etapa 2: Finalizar baseado na escolha do método
      final descobertaState = ref.read(descobertaNivelProvider);
      final onboarding = ref.read(onboardingProvider);

      if (descobertaState.metodoEscolhido == MetodoNivelamento.descoberta) {
        // ✅ NAVEGAR PARA MODO DESCOBERTA INTRO
        context.push('/modo-descoberta/intro', extra: {
          'nivelEscolar': onboarding.educationLevel,
          'nomeUsuario': onboarding.name,
        });
      } else {
        // Modo manual - salva nível escolhido e vai para tela 8
        context.go('/onboarding/8');
      }
    }
  }
}

// ===== CLASSE DE DADOS PARA ESTILO =====
class StudyStyleData {
  final String style;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final List<String> benefits;
  final String gameFeatures;
  final Color color;

  const StudyStyleData({
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
                onPressed: () => context.go('/avatar-selection'),
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

// ✅ V8.2 - Sprint 8: Tela de Finalização com CONFETE + Nivelamento atualizado
// 📅 Atualizado: 17/02/2026
// 🎯 Foco: Clareza, motivação, confete celebratório e próximos passos

class Tela8FinalizacaoPremium extends ConsumerStatefulWidget {
  const Tela8FinalizacaoPremium({super.key});

  @override
  ConsumerState<Tela8FinalizacaoPremium> createState() =>
      _Tela8FinalizacaoPremiumState();
}

class _Tela8FinalizacaoPremiumState
    extends ConsumerState<Tela8FinalizacaoPremium>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 🎊 Confete
  final List<ConfettiPiece> _confettiPieces = [];
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();

    // Animação principal
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    // 🎊 Animação do confete
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Gerar peças de confete
    _generateConfetti();

    // Iniciar animações
    _mainController.forward();
    _confettiController.forward();

    // Esconder confete após 3 segundos
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  void _generateConfetti() {
    final random = math.Random();
    final colors = [
      Colors.green,
      Colors.amber,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
    ];

    for (int i = 0; i < 50; i++) {
      _confettiPieces.add(ConfettiPiece(
        x: random.nextDouble(),
        y: random.nextDouble() * -1, // Começa acima da tela
        rotation: random.nextDouble() * 360,
        color: colors[random.nextInt(colors.length)],
        size: 8 + random.nextDouble() * 8,
        speed: 0.5 + random.nextDouble() * 0.5,
        rotationSpeed: random.nextDouble() * 10 - 5,
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Stack(
        children: [
          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                // Header com progresso
                _buildHeader(context),

                // Conteúdo principal
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // 🎉 Card de Celebração
                            _buildCelebrationCard(
                                onboarding.name ?? 'Explorador'),

                            const SizedBox(height: 24),

                            // Layout responsivo
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _buildProfileCard(onboarding)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildNextStepsCard()),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildProfileCard(onboarding),
                                  const SizedBox(height: 20),
                                  _buildNextStepsCard(),
                                ],
                              ),

                            const SizedBox(height: 32),

                            // 🎁 Card de benefícios
                            _buildBenefitsCard(),

                            const SizedBox(height: 100), // Espaço para o botão
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Botão fixo no rodapé
                _buildBottomButton(context),
              ],
            ),
          ),

          // 🎊 Camada de confete
          if (_showConfetti)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: ConfettiPainter(
                    pieces: _confettiPieces,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => context.go('/onboarding/7'),
                icon: Icon(Icons.arrow_back_ios,
                    color: Colors.green[700], size: 20),
              ),
              Text(
                'Tudo Pronto! 🎉',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progresso 100%
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
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

  Widget _buildCelebrationCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade400,
            Colors.teal.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji animado
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: const Text('🎉', style: TextStyle(fontSize: 48)),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Parabéns, $name!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Seu perfil de estudos está completo!\nAgora é só escolher seu avatar e começar a jogar.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.95),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(OnboardingData onboarding) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline,
                    color: Colors.green[700], size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Seu Perfil de Estudos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileItem(
            '📚',
            'Nível',
            _getEducationLevelText(onboarding.educationLevel),
          ),
          _buildProfileItem(
            '🎯',
            'Objetivo',
            _getStudyGoalText(onboarding.studyGoal),
          ),
          _buildProfileItem(
            '🔬',
            'Área de Interesse',
            _getInterestAreaText(onboarding.interestArea),
          ),
          if (onboarding.studyTime != null)
            _buildProfileItem(
              '⏰',
              'Tempo de Estudo',
              onboarding.studyTime!,
            ),
          if (onboarding.mainDifficulty != null)
            _buildProfileItem(
              '💪',
              'Foco Principal',
              onboarding.mainDifficulty!,
            ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
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

  Widget _buildNextStepsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.rocket_launch,
                    color: Colors.amber[700], size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Próximos Passos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStepItem(
            1,
            '🦸',
            'Escolha seu Avatar',
            'Personalize seu personagem',
            true, // Próximo passo
          ),
          _buildStepItem(
            2,
            '🧭',
            'Nivelamento',
            'Rápido (5 questões) ou Manual',
            false,
          ),
          _buildStepItem(
            3,
            '🎮',
            'Primeira Missão',
            'Comece sua aventura!',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
      int number, String emoji, String title, String subtitle, bool isNext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNext ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border:
            isNext ? Border.all(color: Colors.green.shade300, width: 2) : null,
      ),
      child: Row(
        children: [
          // Número do passo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isNext ? Colors.green : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Emoji
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isNext ? Colors.green[800] : Colors.grey[700],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isNext ? Colors.green[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Indicador de próximo
          if (isNext)
            Icon(Icons.arrow_forward_ios, color: Colors.green[600], size: 16),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        children: [
          const Text(
            '✨ O que você vai encontrar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBenefitIcon('🏆', 'Conquistas'),
              _buildBenefitIcon('📈', 'Progresso'),
              _buildBenefitIcon('🎯', 'Desafios'),
              _buildBenefitIcon('🎮', 'Diversão'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitIcon(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/avatar-selection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🦸', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Text(
                  'Escolher meu Avatar!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === HELPER METHODS ===

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
        return 'Vestibular específico';
      case StudyGoal.exploreAreas:
        return 'Explorar áreas de conhecimento';
      case StudyGoal.undecided:
        return 'Ainda decidindo';
      default:
        return 'Não informado';
    }
  }

  String _getInterestAreaText(ProfessionalTrail? area) {
    switch (area) {
      case ProfessionalTrail.linguagens:
        return 'Linguagens e Códigos';
      case ProfessionalTrail.cienciasNatureza:
        return 'Ciências da Natureza';
      case ProfessionalTrail.matematicaTecnologia:
        return 'Matemática e Tecnologia';
      case ProfessionalTrail.humanas:
        return 'Ciências Humanas';
      case ProfessionalTrail.negocios:
        return 'Negócios e Gestão';
      case ProfessionalTrail.descobrindo:
        return 'Ainda descobrindo';
      default:
        return 'Não informado';
    }
  }
}

// ===== 🎊 CONFETTI SYSTEM =====

class ConfettiPiece {
  double x;
  double y;
  double rotation;
  Color color;
  double size;
  double speed;
  double rotationSpeed;

  ConfettiPiece({
    required this.x,
    required this.y,
    required this.rotation,
    required this.color,
    required this.size,
    required this.speed,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> pieces;
  final double progress;

  ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      final paint = Paint()
        ..color = piece.color.withOpacity((1 - progress).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      // Calcular posição atual
      final currentY = piece.y + (progress * piece.speed * 2);
      final currentX = piece.x + (math.sin(progress * math.pi * 4) * 0.05);

      // Só desenhar se estiver na tela
      if (currentY >= -0.1 && currentY <= 1.1) {
        canvas.save();

        // Posicionar
        canvas.translate(
          currentX * size.width,
          currentY * size.height,
        );

        // Rotacionar
        canvas.rotate((piece.rotation + progress * piece.rotationSpeed * 360) *
            math.pi /
            180);

        // Desenhar retângulo (confete)
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.6,
          ),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, paint);

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
