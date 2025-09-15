// lib/features/questoes/providers/questao_personalizada_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/questao_personalizada.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../shared/providers/personalization_provider.dart';
import '../../modo_descoberta/providers/modo_descoberta_provider.dart';
import '../../../core/models/user_model.dart';
import '../../onboarding/screens/onboarding_screen.dart';

// Provider do estado da sessão
final sessaoQuestoesProvider =
    StateNotifierProvider<SessaoQuestoesNotifier, SessaoQuestoes>(
  (ref) => SessaoQuestoesNotifier(ref),
);

class SessaoQuestoesNotifier extends StateNotifier<SessaoQuestoes> {
  final Ref ref;

  SessaoQuestoesNotifier(this.ref)
      : super(SessaoQuestoes(inicioSessao: DateTime.now()));

  // Iniciar sessão com algoritmo personalizado
  Future<void> iniciarSessao({String? modo}) async {
    try {
      // Obter dados do onboarding real
      final onboardingData = ref.read(onboardingProvider);

      print('🔍 Debug onboarding: ${onboardingData.name}');

      // Verificar se tem dados básicos
      if (onboardingData.name == null ||
          onboardingData.educationLevel == null) {
        throw Exception('Onboarding incompleto: faça o onboarding primeiro');
      }

      // Criar UserModel a partir do OnboardingData
      final user = UserModel(
        id: 'user_${onboardingData.name}',
        name: onboardingData.name!,
        schoolLevel: _convertEducationLevel(onboardingData.educationLevel!),
        mainGoal: _convertStudyGoal(onboardingData.studyGoal),
        interestArea: _convertInterestArea(onboardingData.interestArea),
        dreamUniversity: onboardingData.dreamUniversity ?? '',
        studyTime: onboardingData.studyTime ?? '1-2 horas',
        mainDifficulty: onboardingData.mainDifficulty ?? 'matematica',
        behavioralAspect: 'foco_concentracao',
        studyStyle: onboardingData.studyStyle ?? 'sozinho_meu_ritmo',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        totalXp: 0,
        currentLevel: 1,
        totalQuestions: 0,
        totalCorrect: 0,
        totalStudyTime: 0,
        longestStreak: 0,
        currentStreak: 0,
      );

      print('🎯 Usando usuário: ${user.name}');

      // Chamar algoritmo personalizado do Firebase
      final questoes =
          await FirebaseService.getPersonalizedQuestionsFromOnboarding(
        user: user,
        nivelConhecimento: null,
        limit: 10,
      );

      if (questoes.isEmpty) {
        throw Exception('Nenhuma questão encontrada para este perfil');
      }

      // Converter QuestionModel para QuestaoPersonalizada
      final questoesPersonalizadas = questoes
          .map((questionModel) => QuestaoPersonalizada(
                id: questionModel.id,
                subject: questionModel.subject,
                schoolLevel: questionModel.schoolLevel,
                difficulty: questionModel.difficulty,
                enunciado: questionModel.enunciado,
                alternativas: questionModel.alternativas,
                respostaCorreta: questionModel.respostaCorreta,
                explicacao: questionModel.explicacao,
                imagemEspecifica: questionModel.imagemEspecifica,
                tags: questionModel.tags,
                metadata: questionModel.metadata,
              ))
          .toList();

      // Atualizar estado
      state = SessaoQuestoes(
        questoes: questoesPersonalizadas,
        questaoAtual: 0,
        respostasUsuario: [],
        acertos: [],
        inicioSessao: DateTime.now(),
        sessaoFinalizada: false,
      );

      print('🎯 Sessão iniciada: ${questoesPersonalizadas.length} questões');
    } catch (e) {
      print('❌ Erro ao iniciar sessão: $e');
      rethrow;
    }
  }

  // Responder questão atual
  void responderQuestao(int respostaIndex) {
    final questaoAtual = state.questaoAtualObj;
    if (questaoAtual == null) return;

    final isCorreto = respostaIndex == questaoAtual.respostaCorreta;

    // Atualizar listas de respostas
    final novasRespostas = [...state.respostasUsuario, respostaIndex];
    final novosAcertos = [...state.acertos, isCorreto];

    state = state.copyWith(
      respostasUsuario: novasRespostas,
      acertos: novosAcertos,
    );
  }

  // Ir para próxima questão
  void proximaQuestao() {
    if (state.temProximaQuestao) {
      state = state.copyWith(questaoAtual: state.questaoAtual + 1);
    } else {
      // Finalizar sessão
      state = state.copyWith(sessaoFinalizada: true);
    }
  }

  // Reset para nova sessão
  void resetSessao() {
    state = SessaoQuestoes(inicioSessao: DateTime.now());
  }

  // Métodos de conversão
  String _convertEducationLevel(EducationLevel level) {
    switch (level) {
      case EducationLevel.fundamental6:
        return '6ano';
      case EducationLevel.fundamental7:
        return '7ano';
      case EducationLevel.fundamental8:
        return '8ano';
      case EducationLevel.fundamental9:
        return '9ano';
      case EducationLevel.medio1:
        return 'EM1';
      case EducationLevel.medio2:
        return 'EM2';
      case EducationLevel.medio3:
        return 'EM3';
      default:
        return 'EM1';
    }
  }

  String _convertStudyGoal(StudyGoal? goal) {
    switch (goal) {
      case StudyGoal.enemPrep:
        return 'enemPrep';
      case StudyGoal.specificUniversity:
        return 'specificUniversity';
      case StudyGoal.improveGrades:
        return 'improveGrades';
      default:
        return 'improveGrades';
    }
  }

  String _convertInterestArea(ProfessionalTrail? area) {
    switch (area) {
      case ProfessionalTrail.cienciasNatureza:
        return 'cienciasNatureza';
      case ProfessionalTrail.matematicaTecnologia:
        return 'matematicaTecnologia';
      case ProfessionalTrail.humanas:
        return 'humanas';
      case ProfessionalTrail.linguagens:
        return 'linguagens';
      default:
        return 'cienciasNatureza';
    }
  }
}

// Provider para recursos vitais da sessão atual
final recursosPersonalizadosProvider =
    StateNotifierProvider<RecursosPersonalizadosNotifier, Map<String, double>>(
  (ref) => RecursosPersonalizadosNotifier(),
);

class RecursosPersonalizadosNotifier
    extends StateNotifier<Map<String, double>> {
  RecursosPersonalizadosNotifier()
      : super({
          'energia': 100.0,
          'agua': 100.0,
          'saude': 100.0,
        });

  void atualizarRecursos(bool acertou) {
    final delta = acertou ? 5.0 : -10.0;

    state = {
      'energia': (state['energia']! + delta).clamp(0.0, 100.0),
      'agua': (state['agua']! + delta).clamp(0.0, 100.0),
      'saude': (state['saude']! + delta).clamp(0.0, 100.0),
    };
  }

  void resetRecursos() {
    state = {
      'energia': 100.0,
      'agua': 100.0,
      'saude': 100.0,
    };
  }

  bool get estaVivo => state.values.any((v) => v > 0);
}
