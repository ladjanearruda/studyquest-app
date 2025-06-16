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
      backgroundColor: const Color(0xFFE8F5E9), // Verde Amazônia claro
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

class Tela0Nome extends ConsumerStatefulWidget {
  const Tela0Nome({super.key});

  @override
  ConsumerState<Tela0Nome> createState() => _Tela0NomeState();
}

class _Tela0NomeState extends ConsumerState<Tela0Nome> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    final onboarding = ref.read(onboardingProvider);
    nameController = TextEditingController(text: onboarding.name ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);

    return OnboardingScaffold(
      canGoBack: false,
      onNext: (onboarding.name?.isNotEmpty ?? false)
          ? () => context.go('/onboarding/1')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qual seu nome?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Como você gostaria de ser chamado no StudyQuest?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Digite seu nome ou apelido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            onChanged: (value) {
              ref.read(onboardingProvider.notifier).update((state) {
                final newState = OnboardingData();
                newState.name = value.trim().isEmpty ? null : value.trim();
                newState.educationLevel = state.educationLevel;
                newState.studyGoal = state.studyGoal;
                newState.interestArea = state.interestArea;
                newState.dreamUniversity = state.dreamUniversity;
                newState.studyTime = state.studyTime;
                newState.mainDifficulty = state.mainDifficulty;
                newState.studyStyle = state.studyStyle;
                return newState;
              });
            },
          ),
        ],
      ),
    );
  }
}

class Tela1NivelEducacional extends ConsumerWidget {
  const Tela1NivelEducacional({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    return OnboardingScaffold(
      canGoBack: false,
      onNext: onboarding.educationLevel != null
          ? () => context.go('/onboarding/2')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qual seu nível de ensino atual?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Selecione em que ano você está estudando:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: EducationLevel.values.map((level) {
                  final label = _getEducationLevelLabel(level);
                  final isSelected = onboarding.educationLevel == level;

                  return InkWell(
                    onTap: () {
                      ref.read(onboardingProvider.notifier).update((state) {
                        final newState = OnboardingData();
                        newState.name = state.name;
                        newState.educationLevel = level;
                        newState.studyGoal = state.studyGoal;
                        newState.interestArea = state.interestArea;
                        newState.dreamUniversity = state.dreamUniversity;
                        newState.studyTime = state.studyTime;
                        newState.mainDifficulty = state.mainDifficulty;
                        newState.studyStyle = state.studyStyle;
                        return newState;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF2E7D32) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

class Tela2ObjetivoPrincipal extends ConsumerWidget {
  const Tela2ObjetivoPrincipal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    return OnboardingScaffold(
      onBack: () => context.go('/onboarding/1'),
      onNext: onboarding.studyGoal != null
          ? () => context.go('/onboarding/3')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qual seu objetivo principal?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Selecione o que mais combina com você:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: StudyGoal.values.map((goal) {
                final label = _getStudyGoalLabel(goal);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RadioListTile<StudyGoal>(
                    title: Text(
                      label,
                      style: const TextStyle(fontSize: 16),
                    ),
                    value: goal,
                    groupValue: onboarding.studyGoal,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (value) {
                      ref.read(onboardingProvider.notifier).update((state) {
                        final newState = OnboardingData();
                        newState.name = state.name;
                        newState.educationLevel = state.educationLevel;
                        newState.studyGoal = value;
                        newState.interestArea = state.interestArea;
                        newState.dreamUniversity = state.dreamUniversity;
                        newState.studyTime = state.studyTime;
                        newState.mainDifficulty = state.mainDifficulty;
                        newState.studyStyle = state.studyStyle;
                        return newState;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

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
          const Text(
            'Que área mais desperta seu interesse?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolha a área que mais combina com você:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
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
                              : Colors.grey.shade300,
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
// === TELAS 4 a 7 ===

class Tela4UniversidadeSonho extends ConsumerWidget {
  const Tela4UniversidadeSonho({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final universidades = [
      // Federais de Elite
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

      // Militares
      'ITA',
      'IME',

      // Estaduais
      'UERJ',

      // Privadas Elite
      'PUC-Rio',

      // Opções especiais
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
          const Text(
            'Tem alguma universidade dos sonhos?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolha a universidade que você gostaria de estudar:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: universidades
                    .map((uni) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: RadioListTile<String>(
                            title: Text(
                              uni,
                              style: const TextStyle(fontSize: 16),
                            ),
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
      // Disciplinas específicas
      'Matemática',
      'Português e Literatura',
      'Física',
      'Química',
      'Biologia',
      'História',
      'Geografia',
      'Inglês',

      // Competências transversais
      'Interpretação de texto',
      'Resolução de problemas',
      'Memorização de conteúdo',

      // Aspectos comportamentais
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
          const Text(
            'Qual sua maior dificuldade hoje?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolha o que mais te desafia nos estudos:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: dificuldades
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: RadioListTile<String>(
                            title: Text(
                              d,
                              style: const TextStyle(fontSize: 16),
                            ),
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
          const Text(
            'Como prefere estudar?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolha o estilo que mais combina com você:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: estilos
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: RadioListTile<String>(
                          title: Text(
                            e,
                            style: const TextStyle(fontSize: 16),
                          ),
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
            // Ícone de sucesso
            const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 100,
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              'Oi, ${onboarding.name}! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Seu perfil foi criado com sucesso!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            // Resumo personalizado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seu perfil StudyQuest:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

            // Botão para começar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/trail/forest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar minha aventura! 🌳',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
            // Header da trilha
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.forest,
                    size: 60,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Sobrevivência na Floresta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Você precisa sobreviver na Amazônia resolvendo desafios matemáticos!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Status de recursos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seus recursos vitais:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

            // Botão para começar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navegar para primeira questão
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Primeira questão em desenvolvimento! 🚧'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar Aventura! 🌳',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para barras de recursos
class _ResourceBar extends StatelessWidget {
  final String label;
  final double percentage;

  const _ResourceBar({
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ${percentage.toInt()}%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
