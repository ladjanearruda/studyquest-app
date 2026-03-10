// lib/features/questoes/providers/questao_personalizada_provider.dart
// ✅ V7.3 - ATUALIZADO com método voltarParaInicio para Checkpoint
// 📅 Atualizado: 10/02/2026

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/questao_personalizada.dart';
import '../../../shared/services/firebase_service.dart';
import '../../modo_descoberta/providers/modo_descoberta_provider.dart';
import '../../../core/models/user_model.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import 'sessao_usuario_provider.dart';
import 'recursos_provider_v71.dart';

// ===== CLASSE DE ESTADO DA SESSÃO =====
class SessaoQuestoes {
  final List<QuestaoPersonalizada> questoes;
  final int questaoAtual;
  final List<int> respostasUsuario;
  final List<bool> acertos;
  final DateTime inicioSessao;
  final bool sessaoFinalizada;
  /// Tempo restante salvo ao pausar (restaurado ao voltar)
  final int timeLeft;

  SessaoQuestoes({
    this.questoes = const [],
    this.questaoAtual = 0,
    this.respostasUsuario = const [],
    this.acertos = const [],
    required this.inicioSessao,
    this.sessaoFinalizada = false,
    this.timeLeft = 45,
  });

  SessaoQuestoes copyWith({
    List<QuestaoPersonalizada>? questoes,
    int? questaoAtual,
    List<int>? respostasUsuario,
    List<bool>? acertos,
    DateTime? inicioSessao,
    bool? sessaoFinalizada,
    int? timeLeft,
  }) {
    return SessaoQuestoes(
      questoes: questoes ?? this.questoes,
      questaoAtual: questaoAtual ?? this.questaoAtual,
      respostasUsuario: respostasUsuario ?? this.respostasUsuario,
      acertos: acertos ?? this.acertos,
      inicioSessao: inicioSessao ?? this.inicioSessao,
      sessaoFinalizada: sessaoFinalizada ?? this.sessaoFinalizada,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }

  /// Sessão ativa = tem questões carregadas e não foi finalizada
  bool get isAtiva => questoes.isNotEmpty && !sessaoFinalizada;

  // Getters úteis
  int get totalQuestoes => questoes.length;
  bool get temProximaQuestao => questaoAtual < questoes.length - 1;
  QuestaoPersonalizada? get questaoAtualObj =>
      questoes.isNotEmpty && questaoAtual < questoes.length
          ? questoes[questaoAtual]
          : null;
}

// ===== PROVIDER DO ESTADO DA SESSÃO DE QUESTÕES =====
final sessaoQuestoesProvider =
    StateNotifierProvider<SessaoQuestoesNotifier, SessaoQuestoes>(
  (ref) => SessaoQuestoesNotifier(ref),
);

class SessaoQuestoesNotifier extends StateNotifier<SessaoQuestoes> {
  final Ref ref;

  SessaoQuestoesNotifier(this.ref)
      : super(SessaoQuestoes(inicioSessao: DateTime.now()));

  // ===== INICIAR SESSÃO =====
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

      // 🔧 BUSCAR NÍVEL DO USUÁRIO DO ONBOARDING/MODO DESCOBERTA
      final descobertaState = ref.read(descobertaNivelProvider);
      String userLevel = _getUserLevelFromOnboarding(descobertaState);

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
        userLevel: userLevel,
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
      print('   Matéria com dificuldade: ${user.mainDifficulty}');
      print('   Área de interesse: ${user.interestArea}');
      print('   Nível do usuário: ${user.userLevel}');

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

      // ✅ V7.1: Iniciar sessão no provider de usuário
      ref.read(sessaoUsuarioProvider.notifier).iniciarSessao();

      // ✅ V7.1: Iniciar recursos
      ref.read(recursosPersonalizadosProvider.notifier).iniciarSessao();

      // Atualizar estado da sessão de questões
      state = SessaoQuestoes(
        questoes: questoesPersonalizadas,
        questaoAtual: 0,
        respostasUsuario: [],
        acertos: [],
        inicioSessao: DateTime.now(),
        sessaoFinalizada: false,
      );

      print('🎯 Sessão iniciada: ${questoesPersonalizadas.length} questões');
      print('🔧 Algoritmo V7.3: recursos e XP integrados');
    } catch (e) {
      print('❌ Erro ao iniciar sessão: $e');
      rethrow;
    }
  }

  // ===== RESPONDER QUESTÃO =====
  void responderQuestao(int respostaIndex, {bool isTimeout = false}) {
    final questaoAtual = state.questaoAtualObj;
    if (questaoAtual == null) return;

    final isCorreto =
        !isTimeout && respostaIndex == questaoAtual.respostaCorreta;

    // Atualizar listas de respostas
    final novasRespostas = [...state.respostasUsuario, respostaIndex];
    final novosAcertos = [...state.acertos, isCorreto];

    state = state.copyWith(
      respostasUsuario: novasRespostas,
      acertos: novosAcertos,
    );

    // ✅ V7.1: Registrar no provider de sessão do usuário
    final sessaoNotifier = ref.read(sessaoUsuarioProvider.notifier);
    final dificuldade = questaoAtual.difficulty;

    if (isTimeout) {
      sessaoNotifier.registrarTimeout();
    } else if (isCorreto) {
      // TODO: Implementar verificação de behavioralMatch
      sessaoNotifier.registrarAcerto(dificuldade, behavioralMatch: false);
    } else {
      // V7.1: Erro sem reflexão (Diário vem na Sprint 9)
      sessaoNotifier.registrarErro(dificuldade, comReflexao: false);
    }
  }

  // ===== PRÓXIMA QUESTÃO =====
  void proximaQuestao() {
    if (state.temProximaQuestao) {
      state = state.copyWith(questaoAtual: state.questaoAtual + 1);
    } else {
      // Finalizar sessão
      finalizarSessao();
    }
  }

  // ===== FINALIZAR SESSÃO =====
  void finalizarSessao() {
    state = state.copyWith(sessaoFinalizada: true);

    // ✅ V7.1: Finalizar sessão no provider de usuário
    ref.read(sessaoUsuarioProvider.notifier).finalizarSessao();
  }

  /// Salvar tempo restante ao pausar (para restaurar ao voltar)
  void salvarTimeLeft(int timeLeft) {
    state = state.copyWith(timeLeft: timeLeft);
  }

  // ===== RESET COMPLETO =====
  void resetSessao() {
    state = SessaoQuestoes(inicioSessao: DateTime.now());
  }

  // ===== V7.3: VOLTAR PARA INÍCIO (CHECKPOINT) =====
  /// Volta para o início da sessão SEM buscar novas questões
  /// Usado no Checkpoint para repetir as mesmas questões
  void voltarParaInicio() {
    // Mantém as mesmas questões, apenas reseta o índice e respostas
    state = state.copyWith(
      questaoAtual: 0,
      respostasUsuario: [],
      acertos: [],
      sessaoFinalizada: false,
    );

    print(
        '🔄 CHECKPOINT: Sessão resetada para questão 1 (mesmas ${state.questoes.length} questões)');
  }

  // ===== MÉTODOS AUXILIARES =====

  String _getUserLevelFromOnboarding(DescobertaNivelState descobertaState) {
    print('🔍 Extraindo nível do usuário...');

    if (descobertaState.metodoEscolhido == MetodoNivelamento.descoberta) {
      final modoDescobertaState = ref.read(modoDescobertaProvider);

      if (modoDescobertaState.resultado != null) {
        final nivelDetectado = modoDescobertaState.resultado!.nivelDetectado;
        print('   Modo Descoberta resultado: ${nivelDetectado.titulo}');

        switch (nivelDetectado) {
          case NivelDetectado.iniciante:
          case NivelDetectado.iniciantePlus:
            return 'facil';
          case NivelDetectado.intermediario:
          case NivelDetectado.intermediarioPlus:
            return 'medio';
          case NivelDetectado.avancado:
            return 'dificil';
        }
      } else {
        print(
            '   Modo Descoberta: resultado ainda não disponível, usando medio');
        return 'medio';
      }
    }

    if (descobertaState.nivelManual != null) {
      final nivel = descobertaState.nivelManual!;
      print('   Seleção manual: ${nivel.nome}');
      switch (nivel) {
        case NivelHabilidade.iniciante:
          return 'facil';
        case NivelHabilidade.intermediario:
          return 'medio';
        case NivelHabilidade.avancado:
          return 'dificil';
      }
    }

    print('   Fallback: nivel medio');
    return 'medio';
  }

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

// ===== PROVIDER DE RECURSOS (COMPATIBILIDADE) =====
// Exporta do arquivo recursos_provider_v71.dart
// O recursosPersonalizadosProvider já está definido lá
// Aqui apenas re-exportamos para manter compatibilidade de imports

// Se precisar importar em outros lugares, use:
// import 'package:studyquest/features/questoes/providers/questao_personalizada_provider.dart';
// ou
// import 'package:studyquest/features/questoes/providers/recursos_provider_v71.dart';
