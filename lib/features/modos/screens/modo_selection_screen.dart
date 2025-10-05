// lib/features/modos/screens/modo_selection_screen.dart
// ✅ CORRIGIDO V6.9: Header com avatar completo "nome, tipo e título"

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    setState(() => _modoSelecionado = modo);
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToQuestions();
  }

  void _navigateToQuestions() {
    if (mounted) context.go('/questoes-personalizada');
  }

  @override
  Widget build(BuildContext context) {
    final modos = ModoJogo.todosModos;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
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
    final onboardingData = ref.watch(onboardingProvider);
    final userName = onboardingData.name ?? "Aventureiro";
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/avatar-selection');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: Colors.green[700],
              ),
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
          Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSelectedAvatarDisplayName(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 4),
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
      if (data.educationLevel != null) {
        parts.add(_getEducationLevelText(data.educationLevel!));
      }
      if (data.studyGoal != null) {
        parts.add(_getStudyGoalText(data.studyGoal!));
      }
      if (data.interestArea != null) {
        parts.add(_getInterestAreaText(data.interestArea!));
      }
      final nivel = _getNivelDeConhecimento(descobertaState);
      if (nivel.isNotEmpty) {
        parts.add('Nível: $nivel');
      }
      if (data.studyStyle != null) {
        final estilo = _getStudyStyleText(data.studyStyle!);
        if (estilo.isNotEmpty) {
          parts.add(estilo);
        }
      }
    } catch (e) {
      return 'Perfil personalizado • Pronto para a aventura!';
    }
    if (parts.isEmpty) {
      return 'Perfil em construção • Nível detectado • Pronto para começar!';
    }
    return parts.take(4).join(' • ');
  }

  String _getNivelDeConhecimento(DescobertaNivelState descobertaState) {
    try {
      if (descobertaState.nivelManual != null) {
        return descobertaState.nivelManual!.nome;
      }
      if (descobertaState.metodoEscolhido == MetodoNivelamento.descoberta) {
        return 'A descobrir';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _getSelectedAvatarDisplayName() {
    final onboardingData = ref.watch(onboardingProvider);
    final userName = onboardingData.name ?? "Aventureiro";

    if (onboardingData.selectedAvatarType != null &&
        onboardingData.selectedAvatarGender != null) {
      final tipo = _getAvatarTipoMinusculo(
        onboardingData.selectedAvatarType!,
        onboardingData.selectedAvatarGender!,
      );
      final titulo = _getAvatarTituloMinusculo(
        onboardingData.selectedAvatarType!,
        onboardingData.selectedAvatarGender!,
      );
      return '$userName, $tipo e $titulo';
    }

    return userName;
  }

  String _getAvatarTipoMinusculo(AvatarType type, AvatarGender gender) {
    final isFeminino = gender == AvatarGender.feminino;
    switch (type) {
      case AvatarType.academico:
        return isFeminino ? 'a acadêmica' : 'o acadêmico';
      case AvatarType.competitivo:
        return isFeminino ? 'a competitiva' : 'o competitivo';
      case AvatarType.explorador:
        return isFeminino ? 'a exploradora' : 'o explorador';
      case AvatarType.equilibrado:
        return isFeminino ? 'a equilibrada' : 'o equilibrado';
    }
  }

  String _getAvatarTituloMinusculo(AvatarType type, AvatarGender gender) {
    final isFeminino = gender == AvatarGender.feminino;
    switch (type) {
      case AvatarType.academico:
        return isFeminino ? 'estudiosa' : 'estudioso';
      case AvatarType.competitivo:
        return isFeminino ? 'determinada' : 'determinado';
      case AvatarType.explorador:
        return isFeminino ? 'aventureira' : 'aventureiro';
      case AvatarType.equilibrado:
        return isFeminino ? 'sábia' : 'sábio';
    }
  }

  Widget _buildMainTitle() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => Opacity(
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
      ),
    );
  }

  List<Widget> _buildModoCards(List<ModoJogo> modos) {
    return modos.map((modo) {
      final isSelected = _modoSelecionado?.tipo == modo.tipo;
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildModoCardCompact(modo, isSelected),
            ),
          ),
        ),
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(modo.icone, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
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
                              horizontal: 8, vertical: 4),
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
                              horizontal: 8, vertical: 4),
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
