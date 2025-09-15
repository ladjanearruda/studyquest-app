// lib/features/modos/screens/modo_selection_screen.dart
// StudyQuest V6.2 - ATUALIZADO COM NÍVEL DE CONHECIMENTO

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modo_card.dart';
import '../models/modo_jogo.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../core/models/avatar.dart';

class ModoSelectionScreen extends ConsumerStatefulWidget {
  const ModoSelectionScreen({super.key});

  @override
  ConsumerState<ModoSelectionScreen> createState() =>
      _ModoSelectionScreenState();
}

class _ModoSelectionScreenState extends ConsumerState<ModoSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  ModoJogo? _modoSelecionado;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleModoSelection(ModoJogo modo) async {
    setState(() {
      _modoSelecionado = modo;
    });

    print('🎯 Modo selecionado: ${modo.nome}');

    await Future.delayed(const Duration(milliseconds: 500));

    switch (modo.tipo) {
      case ModoJogoType.missaoInteligente:
        _navigateToQuestions();
        break;
      case ModoJogoType.focoTrilha:
        print('🛤️ Foco Trilha selecionado');
        _navigateToQuestions();
        break;
      case ModoJogoType.focoMateria:
        print('🔍 Foco Matéria selecionado');
        _navigateToQuestions();
        break;
    }
  }

  void _navigateToQuestions() {
    print('🚀 Navegando para questões...');
    if (mounted) {
      context.go('/questoes-personalizada');
    }
  }

  @override
  Widget build(BuildContext context) {
    final modos = ModoJogo.todosModos;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ HEADER ATUALIZADO COM NÍVEL DE CONHECIMENTO
            _buildHeaderComNivel(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildMainTitle(),
                    const SizedBox(height: 32),
                    ..._buildModoCards(modos),
                    const SizedBox(height: 24),
                    if (_modoSelecionado != null) _buildContinueButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderComNivel() {
    // ✅ DADOS DO ONBOARDING
    final onboardingData = ref.watch(onboardingProvider);
    final userName = onboardingData.name ?? "Aventureiro";

    // ✅ DADOS DO NÍVEL DE CONHECIMENTO
    final descobertaState = ref.watch(descobertaNivelProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Navegação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  // ✅ NAVEGAÇÃO SEGURA - Voltar para avatar selection
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/avatar-selection');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: Colors.green[700],
              ),
              // Progress bar
              Container(
                width: 120,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.95,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ PERFIL COMPLETO COM NÍVEL DE CONHECIMENTO
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.green[600]!],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Informações ATUALIZADAS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ NOME + TIPO AVATAR BASEADO NO PERFIL
                    Text(
                      '$userName, ${_getSelectedAvatarName()}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ✅ RESUMO COMPLETO COM NÍVEL DE CONHECIMENTO
                    Text(
                      _buildProfileSummaryComNivel(
                          onboardingData, descobertaState),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildProfileSummaryComNivel(
      OnboardingData data, DescobertaNivelState descobertaState) {
    final parts = <String>[];

    try {
      // ✅ SÉRIE ESCOLAR
      if (data.educationLevel != null) {
        parts.add(_getEducationLevelText(data.educationLevel!));
      }

      // ✅ OBJETIVO PRINCIPAL
      if (data.studyGoal != null) {
        parts.add(_getStudyGoalText(data.studyGoal!));
      }

      // ✅ ÁREA DE INTERESSE
      if (data.interestArea != null) {
        parts.add(_getInterestAreaText(data.interestArea!));
      }

      // 🎯 NÍVEL DE CONHECIMENTO (NOVO!)
      final nivel = _getNivelDeConhecimento(descobertaState);
      if (nivel.isNotEmpty) {
        parts.add('Nível: $nivel');
      }

      // ✅ ESTILO DE ESTUDO (se disponível)
      if (data.studyStyle != null) {
        final estilo = _getStudyStyleText(data.studyStyle!);
        if (estilo.isNotEmpty) {
          parts.add(estilo);
        }
      }
    } catch (e) {
      print('Erro ao construir perfil: $e');
      return 'Perfil personalizado • Pronto para a aventura!';
    }

    // ✅ RETORNO SEGURO
    if (parts.isEmpty) {
      return 'Perfil em construção • Nível detectado • Pronto para começar!';
    }

    return parts.take(4).join(' • '); // Máximo 4 itens para evitar overflow
  }

  // 🎯 NOVO MÉTODO: Extrair nível de conhecimento
  String _getNivelDeConhecimento(DescobertaNivelState descobertaState) {
    try {
      // Primeiro, verificar nível manual escolhido
      if (descobertaState.nivelManual != null) {
        return descobertaState.nivelManual!.nome;
      }

      // Se não tem nível manual, verificar se tem método descoberta selecionado
      if (descobertaState.metodoEscolhido == MetodoNivelamento.descoberta) {
        // Se escolheu descoberta mas ainda não fez o teste
        return 'A descobrir';
      }

      // Se não tem nenhum nível definido
      return '';
    } catch (e) {
      print('Erro ao extrair nível: $e');
      return '';
    }
  }

  String _getSelectedAvatarName() {
    final onboardingData = ref.watch(onboardingProvider);
    if (onboardingData.selectedAvatar != null) {
      return Avatar.fromType(onboardingData.selectedAvatar!).name;
    }
    return 'Aventureiro'; // Fallback se não tiver avatar selecionado
  }

  Widget _buildMainTitle() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              Text(
                'Escolha seu Modo de Jogo! 🎮',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.green[800],
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cada modo oferece uma experiência única personalizada para você',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildModoCards(List<ModoJogo> modos) {
    return modos.map((modo) {
      final isSelected = _modoSelecionado?.tipo == modo.tipo;

      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildModoCardCompact(modo, isSelected),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildModoCardCompact(ModoJogo modo, bool isSelected) {
    final primaryColor = Color(modo.corPrimariaInt);

    return GestureDetector(
      onTap: () => _handleModoSelection(modo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.green[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  modo.icone,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          modo.nome,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                      if (modo.isRecomendado)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'RECOMENDADO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (modo.isSessaoExtra)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'SESSÃO EXTRA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modo.algoritmo,
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    modo.descricao,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Indicador de seleção
            Icon(
              isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isSelected ? primaryColor : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return AnimatedOpacity(
      opacity: _modoSelecionado != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _navigateToQuestions,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.green[600]!.withOpacity(0.3),
          ),
          child: Text(
            '🚀 Iniciar ${_modoSelecionado?.nome ?? "Aventura"}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODOS AUXILIARES PARA CONVERSÃO DE DADOS
  String _getEducationLevelText(EducationLevel level) {
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
        return '1º EM';
      case EducationLevel.medio2:
        return '2º EM';
      case EducationLevel.medio3:
        return '3º EM';
      case EducationLevel.completed:
        return 'Formado';
    }
  }

  String _getStudyGoalText(StudyGoal goal) {
    switch (goal) {
      case StudyGoal.improveGrades:
        return 'Melhorar notas';
      case StudyGoal.enemPrep:
        return 'ENEM';
      case StudyGoal.specificUniversity:
        return 'Vestibular';
      case StudyGoal.exploreAreas:
        return 'Explorar áreas';
      case StudyGoal.undecided:
        return 'Definindo objetivos';
    }
  }

  String _getInterestAreaText(ProfessionalTrail area) {
    switch (area) {
      case ProfessionalTrail.linguagens:
        return 'Linguagens';
      case ProfessionalTrail.cienciasNatureza:
        return 'Ciências da Natureza';
      case ProfessionalTrail.matematicaTecnologia:
        return 'Matemática';
      case ProfessionalTrail.humanas:
        return 'Humanas';
      case ProfessionalTrail.negocios:
        return 'Negócios';
      case ProfessionalTrail.descobrindo:
        return 'Descobrindo';
    }
  }

  String _getStudyStyleText(String? style) {
    if (style == null) return '';
    if (style.toLowerCase().contains('competitiv')) return 'Competitivo';
    if (style.toLowerCase().contains('colaborativ')) return 'Colaborativo';
    if (style.toLowerCase().contains('sozinho')) return 'Focado';
    if (style.toLowerCase().contains('grupo')) return 'Colaborativo';
    return '';
  }
}
